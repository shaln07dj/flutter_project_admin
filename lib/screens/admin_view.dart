import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/application_record_join_admin_record.dart';
import 'package:pauzible_app/Helper/check_officer_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/get_records_helper.dart';
import 'package:pauzible_app/Helper/list_of_officers_helper.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/Helper/search_bar_admin_helper.dart';
import 'package:pauzible_app/Helper/search_bar_officer_helper.dart';
import 'package:pauzible_app/Helper/set_last_login.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/officer_details.dart';
import 'package:pauzible_app/screens/officers_list.dart';
import 'package:pauzible_app/screens/super_admin_view.dart';
import 'package:pauzible_app/screens/upload_new_form.dart';
import 'package:pauzible_app/widgets/footer.dart';
import 'package:pauzible_app/widgets/logout.dart';
import 'package:pauzible_app/widgets/user_name_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class admin_view extends StatefulWidget {
  bool? route;

  admin_view({
    Key? key,
    this.route,
  }) : super(key: key);

  @override
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<admin_view> {
  bool isLoading = true;
  String loading = 'progress';
  String loadingOfficer = 'progress';

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> officerDetailsData = [];

  List<Map<String, dynamic>> originalData = [];

  int _currentSearchOperation = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  User? auth;
  String? role;

  dynamic result;
  dynamic resultOfficerDetails;

  var ofSetValue = 0;
  final TextEditingController _searchController = TextEditingController();
  String _previousSearchValue = '';

  @override
  void initState() {
    super.initState();

    // Set last login time
    setLastLogin();

    // Fetch data
    fetchData();

    // Listen for authentication state changes
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        // User is signed out
        debugPrint('User is currently signed out!');
      } else {
        // User is signed in
        setState(() {
          if (user != null) {
            auth = user;
          }
        });
      }
    });

    // Start listening for session events when the widget is initialized
    sessionStateStream.add(SessionState.startListening);
  }

  void handleLoading(status) {
    setState(() {
      loading = status;
    });
  }

  void handleOfficerLoading(status) {
    setState(() {
      loadingOfficer = status;
    });
  }

  Future showAlertDialogBoxToUnauthorizedOfficer(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Image.asset(
            'assets/images/question.png',
            width: 100,
            height: 100,
            // color: Colors.blue,
          ),
          title: const Text(
            "Alert",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "You are not authorized yet",
            style:
                TextStyle(color: Color.fromARGB(255, 63, 62, 62), fontSize: 15),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SignOut();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void fetchData() async {
    String? firetoken = await getFirebaseIdToken();

    getRole().then((response) async {
      setState(() {
        role = response;
      });
      if (role == 'officer') {
        try {
          result = await checkOfficer(firetoken!);
          if (result['status'] == 'active' && result['role'] == 'officer') {
            result = await getRecords(firetoken, ofSetValue, handleLoading);
            setState(() {
              isLoading = false;
              data.clear();
              data.addAll(List<Map<String, dynamic>>.from(result));
              originalData = List<Map<String, dynamic>>.from(result);
            });
          } else {
            await showAlertDialogBoxToUnauthorizedOfficer(context);
          }
        } catch (error) {
          if (error is DioException && error.response?.statusCode == 404) {
            debugPrint(
                "Inside catch and error dioexception..loading is: $isLoading");
            setState(() {
              isLoading = false;
              loading = 'failed';
              data.clear();
            });
          }
        }
      } else if (role == "admin") {
        result = await applicationRecordJoinAdmin(firetoken!, handleLoading);
        resultOfficerDetails =
            await listOfOfficers(firetoken, handleOfficerLoading);

        setState(() {
          isLoading = false;
          data.clear();
          data.addAll(List<Map<String, dynamic>>.from(result));
          originalData = List<Map<String, dynamic>>.from(result);
          officerDetailsData.clear();
          officerDetailsData
              .addAll(List<Map<String, dynamic>>.from(resultOfficerDetails));
        });
      } else {
        await showAlertDialogBoxToUnauthorizedOfficer(context);
      }
    });

    if (result != null && result.length == 25) {
      ofSetValue = ofSetValue + 25;
      fetchData(); // Make the API call again
    }
  }

  void refreshTable() {
    // Reset the offset and fetch data again
    setState(() {
      loading = 'progress';
      loadingOfficer = 'progress';
    });
    ofSetValue = 0;
    fetchData();
  }

  Future<void> handleSearch(String currentSearchValue) async {
    List<Map<String, dynamic>> result = [];
    int currentOperation = ++_currentSearchOperation;

    if (currentSearchValue.isNotEmpty) {
      if (currentSearchValue.length >= 3 &&
          currentSearchValue != _previousSearchValue) {
        String token = await getSkyFlowToken();
        if (role == 'admin') {
          result = await searchAppNumberAdmin(currentSearchValue, token);
        } else if (role == 'officer') {
          result = await searchAppNumberOfficer(currentSearchValue, token);
        }

        if (currentOperation == _currentSearchOperation) {
          setState(() {
            data = List<Map<String, dynamic>>.from(result);
          });

          _previousSearchValue = currentSearchValue;
        }
      } else if (currentSearchValue.isEmpty) {
        if (currentOperation == _currentSearchOperation) {
          setState(() {
            data = List<Map<String, dynamic>>.from(originalData);
          });
        }
      }
    } else {
      if (currentOperation == _currentSearchOperation) {
        setState(() {
          data = List<Map<String, dynamic>>.from(originalData);
        });

        _previousSearchValue = '';
      }
    }
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                SignOut();
                Navigator.of(context).pop();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String? nameInitial0;
    String? nameInitial;
    String? displayName = '';
    String? greetText = 'Welcome, ';
    if (auth?.displayName != null) {
      nameInitial0 = auth?.displayName ?? '';
      nameInitial = nameInitial0[0].toUpperCase();
    }
    if (user?.email != null) {
      if (_auth.currentUser!.displayName != null) {
        displayName = _auth.currentUser!.displayName?.toUpperCase();
        greetText = greetText + displayName!;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0XFF0E5EB6),
        toolbarHeight: screenHeight * 0.089,
        title: Row(
          children: [
            SizedBox(
              width: screenWidth * 0.1,
              height: screenHeight * 0.06,
              child: Image.asset(
                'assets/images/logoo.png',
              ),
            ),
            const SizedBox(
                width:
                    10), // Adjust the spacing between the title and search box
            if (user!.displayName !=
                null) // Conditionally render the search bar
              Container(
                width: screenWidth * 0.16,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.005,
                    ),
                    const Icon(Icons.search),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search Application',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          handleSearch(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          Text(
            greetText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: screenWidth * 0.01,
          ),
          PopupMenuButton(
            tooltip: "Click to logout",
            surfaceTintColor: Colors.white,
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: UserNameIcon(nameInitial: nameInitial),
            ),
            onSelected: (value) {
              if (value == "logout") {
                showLogoutConfirmationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 1),
                      child: Icon(
                        Icons.logout,
                        color: Color.fromARGB(255, 101, 98, 98),
                      ),
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: role == 'officer'
                ? OfficersList(
                    data: data,
                    loading: loading,
                    refreshTable: refreshTable,
                  )
                : DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 400.w,
                          child: const TabBar(tabs: [
                            Tab(
                              child: Text(
                                'User Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                'Officer\'s Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Tab(
                            //   child: Text(
                            //     'Form Upload',
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                          ]),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              isLoading
                                  ? const LoadingWidget(
                                      loadingText:
                                          "Fetching documents from secure, encrypted vaults...")
                                  :
                                  // role == 'admin'   ?
                                  superAdminView(
                                      data: data,
                                      officerData: officerDetailsData,
                                      loading: loading,
                                      refreshTable: refreshTable,
                                    ),
                              // : role == 'officer'
                              //     ? OfficersList(
                              //         data: data,
                              //         loading: loading,
                              //         refreshTable: refreshTable,
                              //       )
                              //     : const SizedBox(),
                              // 1st tab ends
                              isLoading
                                  ? const LoadingWidget(
                                      loadingText:
                                          "Fetching documents from secure, encrypted vaults...")
                                  : officerDetails(
                                      data: officerDetailsData,
                                      loading: loadingOfficer,
                                      refreshTable: refreshTable,
                                    ),
                              // isLoading
                              //     ? const LoadingWidget(
                              //         loadingText:
                              //             "Fetching documents from secure, encrypted vaults...")
                              //     : uploadNewForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Footer(),
        ],
      ),
    );
  }
}
