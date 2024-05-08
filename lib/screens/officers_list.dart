import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/api/skyflow/widgets/app.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/file_view.dart';

class OfficersList extends StatefulWidget {
  List<Map<String, dynamic>> data = [];
  String loading = 'progress';
  Function refreshTable;

  OfficersList(
      {super.key,
      required this.data,
      required this.loading,
      required this.refreshTable});

  @override
  State<OfficersList> createState() => _OfficersListState();
}

class _OfficersListState extends State<OfficersList> {
  bool isLoading = true;
  List<Map<String, dynamic>> originalData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  User? auth;

  var ofSetValue = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        // User is signed out
        print('User is currently signed out!');
      } else {
        // User is signed in
        setState(() {
          if (user != null) {
            auth = user;
          }
        });
      }
    });
  }

  void navigateToSecondPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => App()),
    );
  }

  String formatDate(String timestamp) {
    DateFormat customFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS Z');

    try {
      DateTime dateTime = customFormat.parse(timestamp);

      String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);

      return formattedDate;
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (auth?.displayName != null) {}

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Align(
          alignment: Alignment.topCenter, // Background color of the screen
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.white, // Background color of the table container
              width: screenWidth * 0.85,
              margin: EdgeInsets.only(
                top: screenWidth * 0.02,
                bottom: screenWidth * 0.02,
                left: screenWidth * 0.075,
                right: screenWidth * 0.075,
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.025,
                        ),
                        child: const Text(
                          'Applications Submitted',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          right: screenWidth * 0.038,
                          bottom: screenWidth * 0.015,
                          top: screenWidth * 0.015,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            widget.refreshTable();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF0E5EB6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Refresh',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  widget.loading == 'progress'
                      ? const Expanded(
                          child: LoadingWidget(
                              loadingText: "Fetching Application List..."),
                        )
                      : widget.loading == 'failed'
                          ? Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/no-records.png',
                                      width: 100,
                                      height: 100,
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "No Applications Found",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : widget.loading == 'success'
                              ? Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: DataTable2(
                                      fixedTopRows: 1,
                                      headingRowColor:
                                          MaterialStateProperty.all<Color>(
                                              const Color(0xFF0E5EB6)),
                                      columns: const <DataColumn>[
                                        DataColumn2(
                                          label: Text(
                                            'Application Number',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        DataColumn2(
                                          size: ColumnSize.L,
                                          label: Text('Applicant Name',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white)),
                                        ),
                                        DataColumn2(
                                          label: Text('Last Login',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white)),
                                        ),
                                        DataColumn2(
                                          label: Text('Application Status',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                      rows: List<DataRow>.generate(
                                          widget.data.length, (index) {
                                        var item = widget.data[index];
                                        return DataRow(
                                          color: MaterialStateProperty
                                              .resolveWith<Color?>(
                                                  (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.selected)) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.08);
                                            }
                                            if (index.isEven) {
                                              return const Color.fromARGB(
                                                      255, 221, 221, 233)
                                                  .withOpacity(0.3);
                                            }
                                            return null;
                                          }),
                                          cells: <DataCell>[
                                            DataCell(
                                              InkWell(
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: item["fields"][
                                                            "application_id"] ??
                                                        '',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  var appNo = item["fields"]
                                                      ["application_id"];
                                                  var appStatus = item["fields"]
                                                      ["application_status"];
                                                  var firstName = item["fields"]
                                                      ["first_name"];
                                                  var lastName = item["fields"]
                                                      ["last_name"];
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          file_view(
                                                        app_no: appNo,
                                                        app_status: appStatus,
                                                        firstName: firstName,
                                                        lastName: lastName,
                                                        // sessionStateStream:
                                                        //     sessionStateStream,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            DataCell(
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${item["fields"]["first_name"] ?? ''} ${item["fields"]["last_name"] ?? ''}',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    item["fields"]["email"] ??
                                                        '',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(
                                              Text((item["fields"]
                                                          ["last_login"] !=
                                                      null)
                                                  ? formatDate(item["fields"]
                                                      ["last_login"])
                                                  : ''),
                                            ),
                                            DataCell(
                                              Text(item["fields"]
                                                      ["application_status"] ??
                                                  ''),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
