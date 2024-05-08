import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/assign_officer_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/list_of_officers_helper.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/Helper/utility_helper_methods.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/file_view.dart';

class superAdminView extends StatefulWidget {
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> officerData = [];
  String loading = 'progress';
  Function refreshTable;
  superAdminView(
      {super.key,
      required this.data,
      required this.officerData,
      required this.loading,
      required this.refreshTable});

  @override
  _SuperAdminViewState createState() => _SuperAdminViewState();
}

class _SuperAdminViewState extends State<superAdminView> {
  bool isLoading = true;
  List<Map<String, dynamic>> originalData = [];
  List<String> officerDropdownItems = [];
  var ofSetValue = 0;
  String? role;
  String? selectedOfficerUserId = '';
  Map<String, String> officerNameToUserIdMap = {};

  @override
  void initState() {
    super.initState();
    officerNameToUserIdMap = {
      for (var officer in widget.officerData)
        if (officer['fields']['first_name'] != null)
          officer['fields']['first_name']: officer['fields']['user_id']
    };

    List<dynamic> officerNameList = widget.officerData
        .where(
            (officer) => officer['fields'].containsKey('first_name') != false)
        .map((map) => map['fields']['first_name'].toString())
        .toList();
    debugPrint('List of Officers first name ${widget.officerData}');
    debugPrint('List of Officers first name $officerNameList');

    List<String> name = officerNameList
        .where((value) => value != null)
        .map((dynamic value) => value.toString())
        .toList();

    setState(() {
      officerDropdownItems = name;
    });
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
    double screenHeight = MediaQuery.of(context).size.height;
    const fontSizeHeaders = 14.0;
    const fontSizeTableData = 12.0;

    return Scaffold(
      body: Container(
          color: Colors.grey[200],
          child: Container(
            color: Colors.white, // Background color of the table container
            margin: EdgeInsets.only(
              top: screenWidth * 0.02,
              bottom: screenWidth * 0.02,
              left: screenWidth * 0.02,
              right: screenWidth * 0.02,
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
                            loadingText:
                                "Fetching documents from secure, encrypted vaults..."),
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
                          ))
                        : widget.loading == 'success'
                            ? Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: DataTable2(
                                    fixedTopRows: 1,
                                    headingRowColor:
                                        MaterialStateProperty.all<Color>(
                                            const Color(0xFF0E5EB6)),
                                    columns: <DataColumn>[
                                      DataColumn2(
                                        fixedWidth: screenWidth * 0.065,
                                        // size: ColumnSize.S,
                                        label: const Text(
                                          'App ID',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      const DataColumn2(
                                        size: ColumnSize.L,
                                        // fixedWidth: screenWidth * 0.21,

                                        label: Text('Applicant Name',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSizeHeaders,
                                                color: Colors.white)),
                                      ),
                                      DataColumn2(
                                        // size: ColumnSize.M,
                                        fixedWidth: screenWidth * 0.125,
                                        label: const Text(
                                          'Last Login',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white),
                                        ),
                                      ),
                                      DataColumn2(
                                        // size: ColumnSize.L,
                                        fixedWidth: screenWidth * 0.171,
                                        label: const Text(
                                          'App Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white),
                                        ),
                                      ),
                                      DataColumn2(
                                        // size: ColumnSize.S,
                                        fixedWidth: screenWidth * 0.103,
                                        label: const Text(
                                          'Officer',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      DataColumn2(
                                        // size: ColumnSize.L,
                                        fixedWidth: screenWidth * 0.15,
                                        label: const Text(
                                          'Assign Officer',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      DataColumn2(
                                        // size: ColumnSize.S,
                                        fixedWidth: screenWidth * 0.088,
                                        label: const Text(
                                          'Assign',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                    rows: widget.data.map((item) {
                                      return DataRow(cells: <DataCell>[
                                        DataCell(
                                          InkWell(
                                            child: RichText(
                                              text: TextSpan(
                                                text: item["fields"]
                                                        ["application_id"] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontSize: fontSizeTableData,
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              var appNo = item["fields"]
                                                  ["application_id"];
                                              var appStatus = item["fields"]
                                                  ["application_status"];
                                              var firstName = item["fields"]
                                                  ["user_first_name"];
                                              var lastName = item["fields"]
                                                  ["user_last_name"];

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
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/avatar.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    // const SizedBox(height: 5),
                                                    Text(
                                                      '${item["fields"]["user_first_name"] ?? ''} ${item["fields"]["user_last_name"] ?? ''}',
                                                      style: const TextStyle(
                                                          fontSize:
                                                              fontSizeTableData),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                    Text(
                                                      item["fields"]["email"] ??
                                                          '',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.start,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/duration_icon.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      (item["fields"][
                                                                  "last_login"] !=
                                                              null)
                                                          ? formatDate(item[
                                                                  "fields"]
                                                              ["last_login"])
                                                          : '',
                                                      style: const TextStyle(
                                                        fontSize:
                                                            fontSizeTableData,
                                                      ),
                                                    ),
                                                    Text(
                                                      (item["fields"][
                                                                  "last_login"] !=
                                                              null)
                                                          ? lastLoginInDays(item[
                                                                      "fields"][
                                                                  "last_login"]) +
                                                              " days ago"
                                                          : '',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                appStatusIconMap
                                                        .where((element) =>
                                                            element['status'] ==
                                                            item["fields"][
                                                                "application_status"])
                                                        .map((element) =>
                                                            element['image'])
                                                        .firstOrNull ??
                                                    'assets/images/registration.png',
                                                width: 25,
                                                height: 25,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child: Text(
                                                  item["fields"][
                                                          "application_status"] ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize:
                                                          fontSizeTableData),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            // width: screenWidth * 0.082,
                                            height: screenHeight * 0.036,
                                            decoration: BoxDecoration(
                                              color: item["fields"]
                                                          ["first_name"] !=
                                                      null
                                                  ? const Color(0xFFE7F9DE)
                                                  : const Color.fromARGB(
                                                      255, 215, 216, 215),
                                              borderRadius:
                                                  BorderRadius.circular(2.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                item["fields"]["first_name"] ??
                                                    'Not Assigned',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: item["fields"][
                                                                "first_name"] !=
                                                            null
                                                        ? const Color.fromARGB(
                                                            255, 129, 227, 76)
                                                        : const Color.fromARGB(
                                                            255, 116, 116, 116),
                                                    fontSize: fontSizeTableData,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7, horizontal: 0),
                                            child: DropdownButton2<String>(
                                              buttonStyleData: ButtonStyleData(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                        255, 207, 205, 205),
                                                  ),
                                                ),
                                              ),
                                              menuItemStyleData:
                                                  const MenuItemStyleData(
                                                height: 50,
                                              ),
                                              value: item["assignedOfficer"] ==
                                                          null ||
                                                      item["assignedOfficer"]
                                                          .isEmpty
                                                  ? 'Select Officer'
                                                  : item["assignedOfficer"]!,
                                              items: [
                                                'Select Officer',
                                                ...officerDropdownItems
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(
                                                        fontSize:
                                                            fontSizeTableData),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  item["assignedOfficer"] =
                                                      newValue;
                                                  if (newValue != null &&
                                                      newValue !=
                                                          'Select Officer') {
                                                    selectedOfficerUserId =
                                                        officerNameToUserIdMap[
                                                            newValue];
                                                  } else {
                                                    selectedOfficerUserId =
                                                        null;
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Perform the update action here
                                              if (selectedOfficerUserId == "") {
                                                selectedOfficerUserId = null;
                                              }
                                              bool response =
                                                  await assignOfficer(
                                                      selectedOfficerUserId,
                                                      item["fields"]
                                                          ["skyflow_id"]);
                                              if (response) {
                                                widget.refreshTable();
                                                selectedOfficerUserId = null;
                                              }
                                            },
                                            child: const Text(
                                              'Update',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              )
                            : const SizedBox()
              ],
            ),
          )),
    );
  }
}
