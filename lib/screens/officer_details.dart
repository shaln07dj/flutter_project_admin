import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauzible_app/Helper/assignStatusForOfficer.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/Helper/utility_helper_methods.dart';

class officerDetails extends StatefulWidget {
  List<Map<String, dynamic>> data = [];
  String loading = 'progress';
  Function refreshTable;
  officerDetails(
      {super.key,
      required this.data,
      required this.loading,
      required this.refreshTable});

  @override
  _officerDetailsState createState() => _officerDetailsState();
}

class _officerDetailsState extends State<officerDetails> {
  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> originalData = [];
  List<String> officerDropdownItems = [];
  var ofSetValue = 0;
  String? role;
  String? selectedOfficerUserId = '';
  Map<String, String> officerNameToUserIdMap = {};

  // void refreshTable() {
  //   // Reset the offset and fetch data again
  //    setState(() {
  //                           loading = 'progress';
  //                         });
  //   ofSetValue = 0;
  //   fetchData();
  // }

  // void handleLoading(status) {
  //   setState(() {
  //     loading = status;
  //   });
  // }

  String formatDate(String timestamp) {
    DateFormat customFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS Z');

    try {
      DateTime dateTime = customFormat.parse(timestamp);

      String formattedDate = DateFormat('MMM dd, yyyy HH:mm').format(dateTime);

      return formattedDate;
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return '';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'not approved':
        return Colors.blue;
      case 'disabled':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  String toCamelCase(String input) {
    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] =
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }
    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // const fontSizeHeaders = 14.0;
    const fontSizeTableData = 12.0;
    return Scaffold(
      body: Container(
          color: Colors.grey[200],
          child: Container(
            color: Colors.white, // Background color of the table container
            // width: screenWidth * 1,
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
                        'Officers To Assign',
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
                        child:
                            LoadingWidget(loadingText: "Fetching Details..."),
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
                                    "No Records Found",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
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
                                        size: ColumnSize.L,
                                        label: Text(
                                          'Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      DataColumn2(
                                        size: ColumnSize.L,
                                        label: Text('Role',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ),
                                      DataColumn2(
                                        size: ColumnSize.L,
                                        label: Text('Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ),
                                      DataColumn2(
                                        size: ColumnSize.L,
                                        label: Text('Last Login',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ),
                                      DataColumn2(
                                        size: ColumnSize.L,
                                        label: Text(
                                          'Actions',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
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
                                                        ["first_name"] ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 45, 44, 44),
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(children: [
                                            Image.asset(
                                              item["fields"]["role"] == 'admin'
                                                  ? 'assets/images/admin_avatar.png'
                                                  : 'assets/images/officer_avatar.png',
                                              width: 25,
                                              height: 25,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Text(
                                                toCamelCase(item["fields"]
                                                        ["role"] ??
                                                    ''),
                                              ),
                                            ),
                                          ]),
                                        ),
                                        DataCell(
                                          Container(
                                            width: screenWidth * 0.08,
                                            height: screenHeight * 0.036,
                                            decoration: BoxDecoration(
                                              color: item["fields"]["status"] ==
                                                      'active'
                                                  ? const Color(0xFFE7F9DE)
                                                  : item["fields"]["status"] ==
                                                          'not approved'
                                                      ? const Color.fromARGB(
                                                          255, 215, 216, 215)
                                                      : const Color.fromARGB(
                                                          255, 248, 215, 213),
                                              borderRadius: BorderRadius.circular(
                                                  2.0), // adjust the radius as needed
                                            ),
                                            child: item["fields"]["status"] ==
                                                    'active'
                                                ? Center(
                                                    child: Text(
                                                        toCamelCase(item[
                                                                    "fields"]
                                                                ["status"] ??
                                                            ''),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 2,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    129,
                                                                    227,
                                                                    76))),
                                                  )
                                                : Center(
                                                    child: item["fields"][
                                                                "status"] ==
                                                            'not approved'
                                                        ? Center(
                                                            child: Text(
                                                              toCamelCase(item[
                                                                          "fields"]
                                                                      [
                                                                      "status"] ??
                                                                  ''),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        116,
                                                                        116,
                                                                        116),
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            toCamelCase(item[
                                                                        "fields"]
                                                                    [
                                                                    "status"] ??
                                                                ''),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      244,
                                                                      124,
                                                                      124),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2),
                                                  ),
                                          ),
                                        ),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                (item["fields"]["last_login"] !=
                                                        null)
                                                    ? formatDate(item["fields"]
                                                        ["last_login"])
                                                    : '',
                                                style: const TextStyle(
                                                  fontSize: fontSizeTableData,
                                                ),
                                              ),
                                              Text(
                                                (item["fields"]["last_login"] !=
                                                        null)
                                                    ? lastLoginInDays(item[
                                                                "fields"]
                                                            ["last_login"]) +
                                                        " days ago"
                                                    : '',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              tooltipTheme:
                                                  const TooltipThemeData(
                                                decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        0, 229, 181, 22)),
                                              ),
                                            ),
                                            child: PopupMenuButton(
                                              tooltip: "Click to logout",
                                              surfaceTintColor: Colors.white,
                                              elevation: 10,
                                              icon: const Icon(Icons.more_vert),
                                              itemBuilder: (context) {
                                                return [
                                                  const PopupMenuItem<int>(
                                                    value: 0,
                                                    child: Text(
                                                      "Not Approved",
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                  const PopupMenuItem<int>(
                                                    value: 1,
                                                    child: Text(
                                                      "Active",
                                                      style: TextStyle(
                                                          color: Colors.green),
                                                    ),
                                                  ),
                                                  const PopupMenuItem<int>(
                                                    value: 2,
                                                    child: Text("Disabled",
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ];
                                              },
                                              onSelected: (value) async {
                                                if (value == 0) {
                                                  bool response =
                                                      await assignStatusForOfficer(
                                                          "not approved",
                                                          item["fields"]
                                                              ["skyflow_id"]);
                                                  if (response) {
                                                    widget.refreshTable();
                                                  }
                                                } else if (value == 1) {
                                                  bool response =
                                                      await assignStatusForOfficer(
                                                          "active",
                                                          item["fields"]
                                                              ["skyflow_id"]);
                                                  if (response) {
                                                    widget.refreshTable();
                                                  }
                                                } else if (value == 2) {
                                                  bool response =
                                                      await assignStatusForOfficer(
                                                          "disabled",
                                                          item["fields"]
                                                              ["skyflow_id"]);
                                                  if (response) {
                                                    widget.refreshTable();
                                                  }
                                                }
                                              },
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
