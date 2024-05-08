import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/update_app_status_helper.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/dashboard.dart';
import 'package:pauzible_app/screens/userDocument.dart';
import 'package:pauzible_app/screens/user_info.dart';
import 'package:pauzible_app/widgets/logout.dart';
import 'package:pauzible_app/widgets/user_name_icon.dart';

List<String> list = <String>[
  'Registration',
  'Pre-Qualification',
  'Personal Details',
  'Mortgage Details',
  'Documents Submission',
  'Contract Signed',
  'Disbursement',
  'Closure'
];

class file_view extends StatefulWidget {
  String? app_no;
  String? app_status;
  String? firstName;
  String? lastName;
  // final StreamController<SessionState> sessionStateStream;

  file_view({
    super.key,
    this.app_no,
    this.app_status,
    this.firstName,
    this.lastName,
    // required this.sessionStateStream,
  });
  @override
  _fileViewState createState() => _fileViewState();
}

class _fileViewState extends State<file_view> {
  User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> data = [];
  List<dynamic> applicationRecordList = [];
  String dropdownValue = list.first;
  String? userApplicationId;
  String? userApplicationStatus;
  String? userId;
  String? userEmail;
  String? skyflowId;

  bool isLoading = true;
  String loading = 'progress';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void handleLoading(status) {
    setState(() {
      loading = status;
    });
  }

  @override
  void initState() {
    super.initState();
    getApplictionRecordsList('applicationRecordList').then((result) {
      setState(() {
        applicationRecordList = result;
        String targetApplicationId = widget.app_no!;
        for (var record in applicationRecordList) {
          String applicationId = record['fields']['application_id'];

          if (applicationId == targetApplicationId) {
            // Display all fields for the matching application_id
            Map<String, dynamic> fields = record['fields'];
            fields.forEach((key, value) {
              if (key == 'user_id') {
                setState(() {
                  userId = value;
                });
                debugPrint("user_id inside file view set state $userId");
              }
              if (key == 'application_id') {
                setState(() {
                  userApplicationId = value;
                });
              }
              if (key == 'email') {
                setState(() {
                  userEmail = value;
                });
              }

              if (fields.containsKey('application_status')) {
                setState(() {
                  if (key == 'application_status' &&
                      value != null &&
                      value != "") {
                    userApplicationStatus = value;
                  }
                });
              }

              if (key == 'skyflow_id') {
                setState(() {
                  skyflowId = value;
                });
              }
            });
          }
        }
      });
    });

    // Start listening for session events when the widget is initialized
    sessionStateStream.add(SessionState.startListening);
  }

  void setApplicationStatus(status) {
    setState(() {
      userApplicationStatus = status;
    });
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
    String? nameInitial0;
    String? nameInitial;
    String? displayName = '';
    String? greetText = 'Welcome, ';
    int tabLength = 3;

    if (user?.displayName != null) {
      nameInitial0 = user?.displayName ?? '';
      nameInitial = nameInitial0[0].toUpperCase();
    }
    if (user?.email != null) {
      if (_auth.currentUser!.displayName != null) {
        displayName = _auth.currentUser!.displayName?.toUpperCase();
        greetText = greetText + displayName!;
      }
    }
    var applicationNo = widget.app_no;
    var firstName = widget.firstName;
    var lastName = widget.lastName;
    var dispName = '';
    firstName != null ? dispName = dispName + firstName : dispName = '';
    lastName != null ? dispName = "$dispName $lastName" : dispName = '';

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return ScreenUtilInit(
      designSize: Size(screenWidth, screenHeight),
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: const Color(0XFF0E5EB6),
            toolbarHeight: screenHeight * 0.089,
            title: Image.asset(
              'assets/images/logoo.png',
              width: screenWidth * 0.09,
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    greetText!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Viewing Application: ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: dispName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ($applicationNo)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    child: UserNameIcon(
                      nameInitial: nameInitial,
                    )),
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
                child: DefaultTabController(
                  length: tabLength,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 700.w,
                        child: const TabBar(
                          indicatorColor: Color(0XFF0E5EB6),
                          tabs: [
                            Tab(
                              icon: Row(
                                children: [
                                  Icon(Icons.info),
                                  SizedBox(
                                      width:
                                          5), // Adjust the spacing between icon and text as needed
                                  Text('User Information'),
                                ],
                              ),
                            ),
                            Tab(
                              icon: Row(
                                children: [
                                  Icon(Icons.document_scanner),
                                  SizedBox(
                                      width:
                                          5), // Adjust the spacing between icon and text as needed
                                  Text('Documents Uploaded'),
                                ],
                              ),
                            ),
                            Tab(
                              icon: Row(
                                children: [
                                  Icon(Icons.upload),
                                  SizedBox(
                                      width:
                                          5), // Adjust the spacing between icon and text as needed
                                  Text('Upload Documents'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Center(
                              child: FormRecords(
                                userApplicationId: widget.app_no,
                              ),
                            ),
                            Center(
                                child: UserDocument(
                              app_no: applicationNo,
                              sessionStateStream: sessionStateStream,
                            )),
                            Center(
                              child: DashBoard(
                                userId: userId,
                                userApplicationId: widget.app_no,
                                userEmail: userEmail,
                                userApplicationStatus: userApplicationStatus,
                                sessionStateStream: sessionStateStream,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Container(
                          color: const Color(0XFF0E5EB6),
                          width: screenWidth * .99,
                          height: screenHeight * 0.07,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(width: screenWidth * 0.01),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.account_box_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: screenWidth * 0.005),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Application: ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text: dispName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' ($applicationNo)',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.settings_applications,
                                      color: Colors.white,
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Status: ',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: userApplicationStatus,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Change Status",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.005),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                      ),
                                      child: DropdownButton2<String>(
                                        value: dropdownValue,
                                        underline: const SizedBox(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        buttonStyleData: ButtonStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            border: Border.all(
                                                width: 1, color: Colors.black),
                                            color: Colors.white,
                                          ),
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            dropdownValue = value!;
                                          });
                                        },
                                        items: list
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.005),
                                    ElevatedButton(
                                      onPressed: () {
                                        updateAppStatus(dropdownValue,
                                            skyflowId!, setApplicationStatus);
                                      },
                                      child: const Text('Update'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
