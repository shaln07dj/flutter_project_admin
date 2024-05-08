import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:pauzible_app/Helper/get_record_helper.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/screens/file_web_view.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class UserDocument extends StatefulWidget {
  String? app_no;
  final StreamController<SessionState> sessionStateStream;

  UserDocument({
    super.key,
    this.app_no,
    required this.sessionStateStream,
  });

  @override
  State<UserDocument> createState() => _UserDocumentState();
}

class _UserDocumentState extends State<UserDocument> {
  final scrollController = ScrollController();
  var hasMore = true;
  bool isLoading = false;
  String loading = 'progress';
  List<Map<String, dynamic>> data = [];
  dynamic result;
  final columnTitle = [
    'Category',
    'Sub Category',
    'Description',
    'Submitted On',
    'Document'
  ];

  final List<String> expectedFields = [
    'category',
    'sub_category',
    'description',
    'updated_at',
    'skyflow_id',
  ];

  final grid = <List<dynamic>>[];
  final rowTitle = <String>[];

  var currentPage = 1;
  var nextPage;
  var rowPerPage = 25;

  bool isFirstCall = true;

  void handleLoading(status) {
    setState(() {
      loading = status;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(handleLoading, currentPage);

    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent) {
        fetchData(handleLoading, nextPage);
      }
    });

    // Start listening for session events when the widget is initialized
    sessionStateStream.add(SessionState.startListening);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void fetchData(Function(String status) handleLoading, var thisPage) async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);
    try {
      int offSetValue = (thisPage - 1) * rowPerPage;
      result = await postRecord(widget.app_no, handleLoading, offSetValue);
      if (isFirstCall) {
        isFirstCall = false;
        if (result.isEmpty) {
          setState(() {
            hasMore = false;
            loading = "failed";
            isLoading = false;
          });
          return;
        }
      } else {
        if (result.isEmpty || result.length < 25) {
          setState(() {
            hasMore = false;
          });
        }
      }

      for (var record in result) {
        rowTitle.add("");
        var fields = record['fields'];
        if (fields != null) {
          for (var key in expectedFields) {
            if (!fields.containsKey(key)) {
              fields[key] = "";
            }
          }
          grid.add([
            fields['category'] ?? "",
            fields['sub_category'] ?? "",
            fields['description'] ?? "",
            fields['updated_at'] != null
                ? formatDate(fields['updated_at'])
                : '',
            fields['skyflow_id'] ?? "",
          ]);
        } else {
          grid.add(["", "", "", "", ""]);
        }
      }
      debugPrint("Grid of 2nd tab===>>> $grid");

      setState(() {
        loading = "success";
        isLoading = false;
        nextPage = thisPage + 1;
        grid;
      });
    } catch (error) {
      debugPrint("Error in fetch Data: $error");
    }
  }

  Future<void> refreshData() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      grid.clear();
      rowTitle.clear();
    });

    fetchData(handleLoading, currentPage);
  }

  String formatDate(String timestamp) {
    if (timestamp == null || timestamp == "") {
      return "";
    }
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
    const fontSizeHeaders = 14.0;
    const fontSizeTableData = 12.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight,
      color: const Color(0xFFF5F5F5),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(
            right: screenWidth * 0.01,
            left: screenWidth * 0.01,
            top: screenHeight * 0.03,
            // bottom: screenHeight * 0.017
          ),
          width: screenWidth * 0.98,
          height: screenHeight * .69,
          color: Colors.white,
          // margin: const EdgeInsets.only(left: 8, right: 8, top: 20, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.01,
                    top: screenWidth * 0.01,
                    bottom: screenWidth * 0.01),
                child: RichText(
                  text: const TextSpan(
                    text: 'Documents Uploaded',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[],
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.60,
                width: screenWidth * 0.99,
                child: grid.isNotEmpty && loading == 'success'
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.005,
                            right: screenWidth * 0.005,
                            bottom: screenWidth * 0.005),
                        child: Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                RefreshIndicator(
                                  onRefresh: refreshData,
                                  child: StickyHeadersTable(
                                    scrollControllers: ScrollControllers(
                                        verticalBodyController:
                                            scrollController),
                                    columnsLength: columnTitle.length,
                                    rowsLength: rowTitle.length,
                                    columnsTitleBuilder: (i) => Container(
                                      color: const Color(0xFF0E5EB6),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            columnTitle[i],
                                            style: const TextStyle(
                                              fontSize: fontSizeHeaders,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    rowsTitleBuilder: (i) => const SizedBox(
                                      height: 0,
                                      width: 0,
                                    ),
                                    contentCellBuilder: (j, i) {
                                      String cellValue = grid[i][j];

                                      if (j == 4) {
                                        return Container(
                                          color: i.isEven
                                              ? const Color.fromARGB(
                                                      255, 221, 221, 233)
                                                  .withOpacity(0.3)
                                              : Colors.transparent,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: screenWidth * 0.01),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: InkWell(
                                                child: RichText(
                                                  text: const TextSpan(
                                                    text: 'View',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize:
                                                          fontSizeTableData,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () async {
                                                  sessionStateStream.add(
                                                      SessionState
                                                          .stopListening);

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          FileWebView(
                                                              grid[i][j]),
                                                    ),
                                                  ).then((_) => {
                                                        sessionStateStream.add(
                                                            SessionState
                                                                .startListening),
                                                      });
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Container(
                                        color: i.isEven
                                            ? const Color.fromARGB(
                                                    255, 221, 221, 233)
                                                .withOpacity(0.3)
                                            : Colors.transparent,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: screenWidth * 0.01),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              cellValue,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: const TextStyle(
                                                  fontSize: fontSizeTableData),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    cellAlignments: const CellAlignments.fixed(
                                      contentCellAlignment:
                                          Alignment.centerLeft,
                                      stickyColumnAlignment: Alignment.topLeft,
                                      stickyRowAlignment: Alignment.centerLeft,
                                      stickyLegendAlignment:
                                          Alignment.centerLeft,
                                    ),
                                    cellDimensions: CellDimensions.fixed(
                                      contentCellWidth: screenWidth * 0.191,
                                      contentCellHeight: screenHeight * 0.06,
                                      stickyLegendWidth: 0,
                                      stickyLegendHeight: 50,
                                    ),
                                    showVerticalScrollbar: false,
                                    showHorizontalScrollbar: false,
                                  ),
                                ),
                                isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      )
                    : loading == 'progress'
                        ? Container(
                            color: Colors.white,
                            margin: const EdgeInsets.only(
                                left: 8, right: 8, top: 20, bottom: 8),
                            child: const Center(
                                child: LoadingWidget(
                                    loadingText: "Fetching User Documents...")),
                          )
                        : loading == 'failed'
                            ? Container(
                                color: Colors.white,
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(
                                height: 0,
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
