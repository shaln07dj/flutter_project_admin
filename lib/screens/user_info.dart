import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/form_template_helper.dart';
import 'package:pauzible_app/Helper/get_form_records_helper.dart';
import 'package:pauzible_app/Helper/get_user_form_json.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

class FormRecords extends StatefulWidget {
  final userApplicationId;
  const FormRecords({super.key, required this.userApplicationId});

  @override
  State<FormRecords> createState() => _FormRecordsState();
}

class _FormRecordsState extends State<FormRecords> {
  Map<String, dynamic>? selectedFormData;
  Map<String, dynamic>? formTempData;

  bool isRightLoading = false;
  String loading = 'success';
  late String? firetoken;
  @override
  void initState() {
    super.initState();
    getFirebaseIdToken().then((tokenVal) {
      setState(() {
        firetoken = tokenVal;
      });
    });
  }

  Future<Map<String, dynamic>> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load JSON');
    }
  }

  Future<void> handleItemSelected(
      String skyflowId, String formIdentifier, int version) async {
    setState(() {
      isRightLoading = true;
      loading = 'progress';
    });

    var jsonData = await getUserFormJson(
        firetoken!, skyflowId); //provides form in json format

    debugPrint("jsonData: $jsonData");

    var formtemp = await formTemp(
      firetoken!,
      formIdentifier,
      version,
    );
    debugPrint("formTemp: $formtemp");

    if (jsonData == {} || jsonData == null) {
      debugPrint("Inside if handleItemSelected: $jsonData");
      setState(() {
        isRightLoading = false;
        loading = 'failed';
      });
    } else {
      setState(() {
        selectedFormData = jsonData;
        formTempData = formtemp;
        isRightLoading = false;
        loading = 'success';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      // margin: EdgeInsets.only(top: screenHeight * 0.02),
      width: screenWidth,
      height: screenHeight,
      color: const Color(0xFFF5F5F5),
      child: Column(children: [
        Row(
          children: [
            LeftFormBlock(
              handleItemSelected: handleItemSelected,
              userAppId: widget.userApplicationId,
            ),
            SizedBox(width: screenWidth * 0.01),
            RightFormBlock(
              selectedData: selectedFormData,
              formData: formTempData,
              rightLoader: isRightLoading,
              loading: loading,
            ),
          ],
        ),
      ]),
    );
  }
}

class LeftFormBlock extends StatefulWidget {
  dynamic handleItemSelected;
  dynamic userAppId;

  LeftFormBlock(
      {super.key, required this.handleItemSelected, required this.userAppId});

  @override
  _LeftFormBlockState createState() => _LeftFormBlockState();
}

class _LeftFormBlockState extends State<LeftFormBlock> {
  bool isLoading = true;
  List<Map<String, dynamic>> formData = [];
  String? userFormId;
  int selectedRowIndex = -1;
  String? firetoken;
  @override
  void initState() {
    super.initState();
    getFirebaseIdToken().then((tokenVal) {
      setState(() {
        firetoken = tokenVal;
        fetchFormData();
      });
    });
  }

  void fetchFormData() async {
    String userAppID = widget.userAppId;
    dynamic formResult = await getFormRecords(firetoken!, userAppID);

    setState(() {
      isLoading = false;
      if (formResult is List) {
        formData = List<Map<String, dynamic>>.from(formResult);
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return ScreenUtilInit(
      designSize: Size(screenWidth, screenHeight),
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: screenWidth * 0.01, top: screenHeight * 0.02),
                width: screenWidth * .39,
                height: screenHeight * .69,
                color: const Color(0xFFFFFFFF),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 150),
                        child: Center(
                          child: LoadingWidget(
                            loadingText: "Fetching User Information...",
                          ),
                        ),
                      )
                    : formData == [] || formData.isEmpty
                        ? SizedBox(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no-records.png',
                                    width: screenWidth * 0.1,
                                    height: screenHeight * 0.1,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No Information Submitted",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DataTable2(
                              columnSpacing: 30.0,
                              headingRowColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF0E5EB6)),
                              columns: const <DataColumn>[
                                DataColumn(
                                  label: Text(
                                      // 'User Forms for App ID: $userid',
                                      "Information Submitted",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                      )),
                                ),
                                DataColumn(
                                  label: Text('Submitted On',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                      )),
                                ),
                              ],
                              rows: List<DataRow>.generate(formData.length,
                                  (index) {
                                var item = formData[index];
                                return DataRow(
                                    color: MaterialStateProperty.resolveWith<
                                        Color?>(
                                      (Set<MaterialState> states) {
                                        if (index == selectedRowIndex) {
                                          return Colors.grey.withOpacity(0.3);
                                        } else if (states
                                            .contains(MaterialState.selected)) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.08);
                                        } else if (index.isEven) {
                                          return const Color.fromARGB(
                                                  255, 221, 221, 233)
                                              .withOpacity(0.3);
                                        }
                                        return null;
                                      },
                                    ),
                                    cells: <DataCell>[
                                      DataCell(
                                        InkWell(
                                          child: RichText(
                                            text: TextSpan(
                                              text: item["fields"]
                                                      ["form_identifier"] ??
                                                  '',
                                              style: TextStyle(
                                                color: index == selectedRowIndex
                                                    ? Colors.lightGreen
                                                    : Colors.blue,
                                                decoration: index ==
                                                        selectedRowIndex
                                                    ? TextDecoration.none
                                                    : TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            setState(() {
                                              selectedRowIndex = index;
                                            });
                                            widget.handleItemSelected(
                                                item["fields"]["skyflow_id"],
                                                item["fields"]
                                                    ["form_identifier"],
                                                item["fields"]["version"]);
                                          },
                                        ),
                                      ),
                                      DataCell(
                                        InkWell(
                                          child: RichText(
                                            text: TextSpan(
                                              text: (item["fields"]
                                                          ["updated_at"] !=
                                                      null)
                                                  ? formatDate(item["fields"]
                                                      ["updated_at"])
                                                  : '',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]);
                              }).toList(),
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

class RightFormBlock extends StatefulWidget {
  final Map<String, dynamic>? selectedData;
  final Map<String, dynamic>? formData;
  bool rightLoader;
  String loading;

  RightFormBlock({
    super.key,
    required this.selectedData,
    required this.formData,
    required this.rightLoader,
    required this.loading,
  });

  @override
  _RightFormBlockState createState() => _RightFormBlockState();
}

class _RightFormBlockState extends State<RightFormBlock> {
  Map<String, dynamic>? selectedFormData;
  Map<String, dynamic>? formTempData;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  @override
  void didUpdateWidget(covariant RightFormBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedData != oldWidget.selectedData) {
      _updateData();
    }
  }

  void _updateData() async {
    if (widget.selectedData != null) {
      setState(() {
        widget.rightLoader = true;
        widget.loading = 'progress';

        selectedFormData = widget.selectedData;
        formTempData = widget.formData;
        Map<String, dynamic> updatedFormData = {};
        Map<String, String> idToDisplayNameMap =
            {}; // Mapping of id to displayName

        // Extract id and displayName from formTempData
        if (formTempData != null && formTempData!['formTemplates'] != null) {
          var templatejson = formTempData!['formTemplates']['templatejson'];
          if (templatejson != null && templatejson['items'] != null) {
            for (var item in templatejson['items']) {
              var fields = item['fields'];
              if (fields != null) {
                // Extract id and displayName from fields
                for (var field in fields) {
                  String id = field['id'];
                  String displayName = field['displayName'];
                  idToDisplayNameMap[id] = displayName;
                  // debugPrint('EXTRACT METHOD1 $id $displayName ${idToDisplayNameMap[id]}');
                  // Check for subItems and extract them if present
                  if (field['config'] != null &&
                      field['config']['subItems'] != null) {
                    var subItems = field['config']['subItems'];
                    for (var subItemKey in subItems.keys) {
                      var subItemFields = subItems[subItemKey];
                      for (var subField in subItemFields) {
                        String subId = subField['id'];
                        String subDisplayName = subField['displayName'];
                        idToDisplayNameMap[subId] = subDisplayName;
                        // debugPrint('EXTRACT METHOD2 $subId $subDisplayName ${idToDisplayNameMap[subId]}');
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Use the idToDisplayNameMap to update the keys of selectedFormData
        selectedFormData!.forEach((key, value) {
          String newKey = idToDisplayNameMap[key] ?? key;
          updatedFormData[newKey] = value;
        });

        // Update selectedFormData with updatedFormData
        selectedFormData = updatedFormData;
        widget.rightLoader = false;
        widget.loading = 'success';
        debugPrint("selectedFormData: $selectedFormData");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double columnWidth = screenWidth * 0.5;
    double totalColumnWidth = columnWidth - 32;
    double availableColumnWidth = totalColumnWidth - (8 * 2);

    ScreenUtil.init(context);
    return ScreenUtilInit(
      designSize: Size(screenWidth, screenHeight),
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    right: screenWidth * 0.01,
                    // bottom: screenHeight * 0.02,
                    top: screenHeight * 0.02),
                width: screenWidth * .58,
                height: screenHeight * .69,
                color: const Color(0xFFFFFFFF),
                child: widget.loading == 'progress'
                    ? const Center(
                        child: LoadingWidget(
                          loadingText: "Fetching User Submission...",
                        ),
                      )
                    : widget.loading == 'failed'
                        ? SizedBox(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no-records.png',
                                    width: 120,
                                    height: 120,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Unable to load information, Please contact system administrator.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : widget.loading == 'success' &&
                                widget.selectedData == null
                            ? SizedBox(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/formClick.png',
                                        width: screenWidth * 0.1,
                                        height: screenHeight * 0.1,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Please select user submitted form to view information",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DataTable2(
                                  headingRowColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFF0E5EB6)),
                                  columns: [
                                    const DataColumn(
                                      label: Text(
                                        'Field',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                    DataColumn(
                                        label: Text(
                                      'Information',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: ScreenUtil().screenHeight > 600
                                          ? 2
                                          : 1,
                                    )),
                                  ],
                                  rows: selectedFormData!.entries
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    MapEntry<String, dynamic> data =
                                        entry.value;
                                    Color? rowColor = index % 2 == 0
                                        ? const Color.fromARGB(
                                                255, 221, 221, 233)
                                            .withOpacity(0.3)
                                        : null;
                                    double specificRowHeight =
                                        _calculateRowHeight(
                                            data.key,
                                            data.value?.toString() ?? '-',
                                            availableColumnWidth);
                                    debugPrint("$index : $specificRowHeight");

                                    return DataRow2(
                                      color: MaterialStateColor.resolveWith(
                                          (states) => rowColor ?? Colors.white),
                                      specificRowHeight: specificRowHeight,
                                      cells: [
                                        DataCell(
                                          Text(
                                            style: TextStyle(fontSize: 14.sp),
                                            data.key,
                                            maxLines: null,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: data.value?.toString() ==
                                                        "**Redacted**"
                                                    ? Colors.blue.shade800
                                                    : Colors.black),
                                            data.value?.toString() ?? '-',
                                            maxLines: null,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateRowHeight(
      String fieldText, String informationText, double availableColumnWidth) {
    final TextPainter fieldPainter = TextPainter(
        text: TextSpan(
          text: fieldText,
          style: TextStyle(fontSize: 16.sp),
        ),
        maxLines: null,
        textDirection: ui.TextDirection.ltr)
      ..layout(maxWidth: availableColumnWidth);

    final TextPainter informationPainter = TextPainter(
        text: TextSpan(
          text: informationText,
          style: TextStyle(fontSize: 16.sp),
        ),
        maxLines: null,
        textDirection: ui.TextDirection.ltr)
      ..layout(maxWidth: availableColumnWidth);

    return max(fieldPainter.size.height, informationPainter.size.height) + 32;
  }
}
