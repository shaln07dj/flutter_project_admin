import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/admin_doc_view_helper.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/Helper/post_records_helper.dart';
import 'package:pauzible_app/Helper/recall_helper.dart';
import 'package:pauzible_app/Helper/send_file_info_helper.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/Helper/view_certificate_helper.dart';
import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/Models/category_subcategory.dart';
import 'package:pauzible_app/Models/file_data_model.dart';
import 'package:pauzible_app/Models/file_record.dart';
import 'package:pauzible_app/main.dart';
import 'package:pauzible_app/redux/actions.dart';
import 'package:pauzible_app/screens/admin_doc_view.dart';
import 'package:pauzible_app/widgets/drop_down.dart';
import 'package:pauzible_app/widgets/drop_zone_widget.dart';
import 'package:pauzible_app/widgets/wordLimitInputFormatter.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class DashBoard extends StatefulWidget {
  final userId;
  final userApplicationId;
  final userEmail;
  final userApplicationStatus;
  final StreamController<SessionState> sessionStateStream;

  const DashBoard({
    super.key,
    required this.userId,
    required this.userApplicationId,
    required this.userEmail,
    this.userApplicationStatus,
    required this.sessionStateStream,
  });
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final GlobalKey<_RightBlockState> _rightWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start listening for session events when the widget is initialized
    sessionStateStream.add(SessionState.startListening);
  }

  @override
  Widget build(BuildContext context) {
    void rightReload() {
      _rightWidgetKey.currentState?.fetchNewData();
    }

    void reloadCallBack() {
      rightReload();
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xFFF5F5F5),
      height: screenHeight,
      child: Container(
        // margin: EdgeInsets.only(top: screenHeight * 0.04),
        width: screenWidth,
        height: screenHeight,
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  LeftBlock(
                    callback: reloadCallBack,
                    userId: widget.userId,
                    userAppId: widget.userApplicationId,
                    userEmail: widget.userEmail,
                  ),
                  SizedBox(
                    width: screenWidth * 0.01,
                  ),
                  RightBlock(
                    key: _rightWidgetKey,
                    userApplicationId: widget.userApplicationId,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubDropdown extends StatefulWidget {
  final Function(String) callback;
  final bool resetSubCategory;
  final Function(bool) setSubCategory;
  List<String> subCategoryDropdownItems;

  SubDropdown({
    Key? key,
    required this.callback,
    required this.resetSubCategory,
    required this.setSubCategory,
    required this.subCategoryDropdownItems,
  }) : super(key: key);
  @override
  State<SubDropdown> createState() => _SubDropdownState();
}

List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class _SubDropdownState extends State<SubDropdown> {
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  FileRecord? record;

  List<String> subCategoryDropdownItems = [];

  String? selectedValue;
  void setSubCategoryList(category) {
    setState(() {
      selectedValue = null;
    });
    categorySubCategoryData.forEach((item) {
      if (item['category'] == category) {
        setState(() {
          subCategoryDropdownItems = item['sub-category'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool resetSubCat = widget.resetSubCategory;

    setState(() {
      screenWidth = (MediaQuery.of(context).size.width);
      screenHeight = (MediaQuery.of(context).size.height);
    });

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return Container(
          width: screenWidth * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: GestureDetector(
            onTap: () {
              print("Tap event prevented!");
            },
            child: DropdownButton2<String>(
              isExpanded:
                  true, // Allows the dropdown to take up the entire available width
              value: resetSubCat ? null : selectedValue,
              underline: const SizedBox.shrink(),

              onChanged: (String? newValue) {
                widget.callback(newValue!);
                widget.setSubCategory(false);
                setState(() {
                  selectedValue = newValue!;
                });
                setState(() {});
                resetSubCat = true;
              },
              items: subCategoryDropdownItems
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              hint: const Text(
                "Select Sub Category",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w100),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LeftBlock extends StatefulWidget {
  final Function() callback;
  final userId;
  final userAppId;
  final userEmail;

  const LeftBlock({
    super.key,
    required this.userId,
    required this.userAppId,
    required this.callback,
    required this.userEmail,
  });
  @override
  _LeftBlockState createState() => _LeftBlockState();
}

class _LeftBlockState extends State<LeftBlock> {
  final GlobalKey<_SubDropdownState> _subDropDownKey =
      GlobalKey<_SubDropdownState>();

  final TextEditingController _description = TextEditingController();
  final DropZoneController dropzoneViewController = DropZoneController();

  File_Data_Model? file;
  String? descp;

  String? category;
  String? subCategory;
  bool? isValidFileType = false;
  bool resetCategoryValue = false;
  bool resetSubCategoryValue = false;
  bool isResetFile = false;
  bool disableButton = false;
  bool success = false;
  bool categorySuccess = false;
  bool subCategorySuccess = false;
  bool fileSuccess = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> subCategoryDropdownItems = [];
  String? appId;
  String requestname = 'signing_request';
  String recipientName = 'Pauzible User';

  @override
  void initState() {
    super.initState();
    getAppId().then((result) {
      setState(() {
        result;
      });
    });
  }

  void resetSucessStatus() {
    setState(() {
      success = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String userAppID = widget.userAppId;

    void updateCategory(String cat) {
      setState(() {
        category = cat;
        categorySuccess = true;
        _subDropDownKey.currentState!.setSubCategoryList(cat);
        subCategory = null;
        subCategorySuccess = false;
        resetSucessStatus();
      });
    }

    void updateSubCategory(String subCat) {
      setState(() {
        subCategory = subCat;
        subCategorySuccess = true;
        resetSucessStatus();
      });
    }

    void checkValidFileType(bool isValidFile) {
      setState(() {
        isValidFileType = isValidFile;
      });
    }

    void fileReset(bool resetFile) {
      setState(() {
        isResetFile = resetFile;
      });
    }

    void resetfileSuccess() {
      setState(() {
        fileSuccess = false;
      });
    }

    void resetFileInfo() {
      setState(() {
        file = null;
      });
    }

    void resetCategory(bool resetCatVal) {
      setState(() {
        category = null;
        subCategory = null;
        resetCategoryValue = resetCatVal;
        categorySuccess = false;
        subCategorySuccess = false;
      });
      setState(() {
        disableButton = true;
      });
    }

    void resetSubCategory(bool resetSubCatVal) {
      setState(() {
        resetSubCategoryValue = resetSubCatVal;
      });
    }

    void setCategory(bool resetCatVal) {
      setState(() {
        resetCategoryValue = resetCatVal;
        success = true;
        categorySuccess = true;
      });
      setState(() {
        disableButton = false;
      });
    }

    void setSubCategory(bool resetSubCatVal) {
      setState(() {
        resetSubCategoryValue = resetSubCatVal;
        success = true;
      });
    }

    void resetDropZone() {
      dropzoneViewController.reset();
    }

    void resetTextField() {
      _description.clear();
    }

    void showToast(String msg) {
      showToastHelper(msg);
    }

    void isSuccessfull() {
      setState(() {
        success = !success;
        categorySuccess = false;
        subCategorySuccess = false;
        fileSuccess = false;
      });
    }

    void resetSubCategoryDefault() {
      setState(() {
        subCategory = null;
      });
    }

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        _auth.currentUser!.getIdToken().then((token) {
          token = token;
        }).catchError((error) {
          debugPrint('Error: $error');
        });

        return Container(
          margin: EdgeInsets.only(
              left: screenWidth * 0.01, top: screenHeight * 0.02),
          width: screenWidth * .39,
          height: screenHeight * .69,
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: screenWidth * 0.02, top: screenHeight * 0.020),
                child: const Text.rich(
                  TextSpan(
                    text: 'Upload Documents',
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    children: [
                      // TextSpan(
                      //   text: userAppID,
                      //   style: const TextStyle(color: Colors.blue),
                      // ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.027),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: screenWidth * 0.02),
                      width: screenWidth * 0.17,
                      height: screenHeight * 0.07,
                      child: Dropdown(
                        callback: updateCategory,
                        resetCategory: resetCategoryValue,
                        setCategory: setCategory,
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.01,
                    ),
                    SizedBox(
                      width: screenWidth * 0.17,
                      height: screenHeight * 0.07,
                      child: SubDropdown(
                        key: _subDropDownKey,
                        callback: updateSubCategory,
                        resetSubCategory: resetSubCategoryValue,
                        setSubCategory: setSubCategory,
                        subCategoryDropdownItems: subCategoryDropdownItems,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.027),
              Container(
                margin: EdgeInsets.only(left: screenWidth * 0.02),
                width: screenWidth * 0.35,
                child: SizedBox(
                  width: screenWidth * 0.242,
                  child: TextField(
                    maxLines: 2,
                    inputFormatters: [
                      WordLimitInputFormatter(descrptionMaxWords)
                    ],
                    onChanged: (value) {
                      setState(() {
                        descp = value;
                      });
                      StoreProvider.of<AppState>(context).dispatch(
                        UpdateFileDescriptionAction(
                          description: descp,
                        ),
                      );
                    },
                    style: const TextStyle(fontSize: 12),
                    controller: _description,
                    decoration: const InputDecoration(
                      hintText:
                          '     Please enter description( $descrptionMaxWords words )',
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFB8B8B8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                width: screenWidth * 0.232,
                height: screenHeight * 0.19,
                child: SizedBox(
                  width: screenWidth * 0.25,
                  child: DropZoneWidget(
                    onDroppedFile: (file) {
                      setState(() {
                        this.file = file;
                        fileSuccess = true;
                      });
                    },
                    isValidFileType: checkValidFileType,
                    isValidFile: isResetFile,
                    controller: dropzoneViewController,
                    resetFileInfo: resetFileInfo,
                    resetfileSuccess: resetfileSuccess,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Expanded(
                child: Row(
                  children: [
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.15),
                        width: screenWidth * 0.078,
                        height: screenHeight * 0.037,
                        color:
                            categorySuccess && subCategorySuccess && fileSuccess
                                ? Colors.lightBlueAccent
                                : Colors.grey,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  categorySuccess &&
                                          subCategorySuccess &&
                                          fileSuccess
                                      ? Colors.lightBlueAccent
                                      : Colors.grey),
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: categorySuccess &&
                                    subCategorySuccess &&
                                    fileSuccess
                                ? () {
                                    sendFileInfo(
                                        category,
                                        subCategory,
                                        descp,
                                        false,
                                        widget.userAppId,
                                        widget.userId,
                                        _auth.currentUser?.uid,
                                        file!.name,
                                        file!.size,
                                        file!.url,
                                        widget.callback,
                                        isSuccessfull,
                                        resetFileInfo,
                                        showToast,
                                        requestname,
                                        widget.userEmail,
                                        recipientName,
                                        resetCategory,
                                        resetSubCategory,
                                        resetTextField,
                                        fileReset,
                                        resetDropZone,
                                        resetSubCategoryDefault);
                                    resetCategory(true);
                                    resetSubCategory(true);
                                    resetTextField();
                                    fileReset(true);
                                    resetDropZone();
                                  }
                                : () {
                                    if (categorySuccess == false) {
                                      showToastHelper("Select Category");
                                    }
                                    if (categorySuccess == true &&
                                        subCategorySuccess == false) {
                                      showToastHelper("Select Sub Category");
                                    }
                                    if (categorySuccess == true &&
                                        subCategorySuccess == true &&
                                        fileSuccess == false) {
                                      showToastHelper("Select File");
                                    }
                                  },
                            child: Text("Upload",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: screenWidth * .011,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                )))),
                    subCategory != null
                        ? const SizedBox(
                            height: 0,
                          )
                        : Container()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RightBlock extends StatefulWidget {
  final userApplicationId;
  const RightBlock({Key? key, required this.userApplicationId})
      : super(key: key);
  @override
  _RightBlockState createState() => _RightBlockState();
}

class _RightBlockState extends State<RightBlock> {
  final scrollController = ScrollController();
  var hasMore = true;

  File_Data_Model? file;
  List<Map<String, dynamic>> data = [];
  String loading = 'progress';
  var isLoading = false;
  dynamic result;

  String? skyFlowToken;
  String? appId;

  final columnTitle = ['Category', 'Sent On', 'Status', 'Recall', 'Actions'];

  final List<String> expectedFields = [
    'category',
    'created_at',
    'status',
    'skyflow_id',
    'sub_category',
    'description',
    'updated_at',
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
      result = await getRecords(
          handleLoading, widget.userApplicationId, offSetValue);

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
            fields['created_at'] != null
                ? formatDate(fields['created_at'])
                : '',
            fields['status'] ?? "",
            fields['skyflow_id'] ?? "",
            fields['sub_category'] ?? "",
            fields['description'] ?? "",
            fields['updated_at'] != null
                ? formatDate(fields['updated_at'])
                : '',
          ]);
        } else {
          grid.add(["", "", "", "", "", "", ""]);
        }
      }
      debugPrint("Grid 3rd tab===>>> $grid");

      setState(() {
        loading = "success";
        isLoading = false;
        nextPage = thisPage + 1;
        grid;
      });
    } catch (error) {
      const snackBar =
          SnackBar(content: Text('Occur data loading error. Please try later'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      debugPrint('Loading error: $error');
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

  void fetchNewData() async {
    setState(() {
      isLoading = false;
      hasMore = true;
      grid.clear();
      rowTitle.clear();
      loading = 'progress';
    });
    fetchData(handleLoading, currentPage);
  }

  String formatDate(String timestamp) {
    if (timestamp == "") {
      return "";
    }

    debugPrint("Timestamp: $timestamp");
    DateFormat customFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS Z');

    try {
      DateTime dateTime = customFormat.parse(timestamp);

      String formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
      debugPrint("formattedDate: $formattedDate");

      return formattedDate;
    } catch (e) {
      debugPrint('Error parsing timestamp: $e');
      return 'Not Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const fontSizeStatus = 12.0;
    const fontSizeHeader = 14.0;

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Container(
            width: screenWidth * 0.58,
            height: screenHeight * 0.69,
            margin: EdgeInsets.only(
                right: screenWidth * 0.01, top: screenHeight * 0.02),
            color: Colors.white,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
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
                              children: <TextSpan>[
                                // TextSpan(
                                //   text: widget.userApplicationId,
                                //   style: const TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.blue,
                                //   ),
                                // )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: grid.isNotEmpty && loading == 'success'
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: screenHeight * 0.015,
                                  left: screenWidth * 0.01,
                                  right: screenWidth * 0.01,
                                  bottom: screenHeight * 0.015),
                              child: Scaffold(
                                body: Stack(
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
                                          color: Color(0XFF0E5EB6),
                                          child: SizedBox(
                                            width: screenWidth * 0.1119,
                                            height: screenHeight * 0.1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: Text(
                                                  columnTitle[i],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
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

                                          if (j == 2) {
                                            return Container(
                                              color: i.isEven
                                                  ? const Color.fromARGB(
                                                          255, 221, 221, 233)
                                                      .withOpacity(0.3)
                                                  : Colors.transparent,
                                              child: Center(
                                                child: Container(
                                                  width: screenWidth * 0.08,
                                                  height: screenHeight * 0.036,
                                                  decoration: BoxDecoration(
                                                    color: cellValue == 'SIGNED'
                                                        ? const Color.fromARGB(
                                                            255, 58, 162, 62)
                                                        : cellValue ==
                                                                'TOBESIGNED'
                                                            ? const Color
                                                                .fromARGB(255,
                                                                237, 194, 37)
                                                            : Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      cellValue,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: (cellValue ==
                                                                  'SIGNED' ||
                                                              cellValue ==
                                                                  'TOBESIGNED')
                                                          ? const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  fontSizeStatus,
                                                            )
                                                          : const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  fontSizeStatus,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          if (j == 3) {
                                            return Container(
                                              color: i.isEven
                                                  ? const Color.fromARGB(
                                                          255, 221, 221, 233)
                                                      .withOpacity(0.3)
                                                  : Colors.transparent,
                                              child: grid[i][2] == 'TOBESIGNED'
                                                  ? Center(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                icon:
                                                                    Image.asset(
                                                                  'assets/images/question_mark.png',
                                                                  width: 50,
                                                                  height: 50,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  "Are you sure?",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                content:
                                                                    const Text(
                                                                  "Do you really want to recall the document?",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            63,
                                                                            62,
                                                                            62),
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    style:
                                                                        const ButtonStyle(
                                                                      overlayColor:
                                                                          MaterialStatePropertyAll(
                                                                        Color.fromARGB(
                                                                            255,
                                                                            184,
                                                                            183,
                                                                            183),
                                                                      ),
                                                                      side:
                                                                          MaterialStatePropertyAll(
                                                                        BorderSide(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                33,
                                                                                148,
                                                                                241)),
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      // Close the dialog
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            "No"),
                                                                  ),
                                                                  TextButton(
                                                                    style:
                                                                        const ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStatePropertyAll(
                                                                        Colors
                                                                            .blue,
                                                                      ),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      // Close the dialog
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      // Call the recall API function
                                                                      recallDocument(
                                                                          grid[i]
                                                                              [
                                                                              3]);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Yes",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ); //showDialog of recall
                                                        },
                                                        child: const Text(
                                                          'Recall',
                                                          style: TextStyle(
                                                            color: Colors.blue,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Center(
                                                      child: ElevatedButton(
                                                        onPressed: (grid[i]
                                                                        [2] ==
                                                                    'RECALLED' ||
                                                                grid[i][2] ==
                                                                    'SIGNED')
                                                            ? null // Disable the button for 'RECALLED' and 'SIGNED'
                                                            : () {},
                                                        child: const Text(
                                                          'Recall',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            );
                                          }

                                          if (j == 4) {
                                            return Container(
                                              color: i.isEven
                                                  ? const Color.fromARGB(
                                                          255, 221, 221, 233)
                                                      .withOpacity(0.3)
                                                  : Colors.transparent,
                                              child: Center(
                                                child: PopupMenuButton<int>(
                                                    surfaceTintColor:
                                                        Colors.white,
                                                    elevation: 10,
                                                    tooltip: "",
                                                    icon: const Icon(
                                                        Icons.more_vert),
                                                    itemBuilder: (context) {
                                                      return [
                                                        const PopupMenuItem<
                                                            int>(
                                                          value: 0,
                                                          child:
                                                              Text("Details"),
                                                        ),
                                                        const PopupMenuItem<
                                                            int>(
                                                          value: 1,
                                                          child:
                                                              Text("View Doc"),
                                                        ),
                                                        const PopupMenuItem<
                                                            int>(
                                                          value: 2,
                                                          child: Text(
                                                              "Sign Cert."),
                                                        ),
                                                      ];
                                                    },
                                                    onSelected: (value) async {
                                                      if (value == 0) {
                                                        String category =
                                                            grid[i][0];
                                                        String subCategory =
                                                            grid[i][4];

                                                        String description =
                                                            grid[i][5];

                                                        String signedOn =
                                                            grid[i][6];

                                                        if (grid[i][2] ==
                                                            "TOBESIGNED") {
                                                          signedOn =
                                                              "Not Signed Yet";
                                                        } else if (grid[i][2] ==
                                                            "RECALLED") {
                                                          signedOn =
                                                              "Not Applicable";
                                                        } else if (grid[i][2] ==
                                                            "SIGNED") {
                                                          signedOn = grid[i]
                                                                  [6] ??
                                                              'Not Available';
                                                        }
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                "Details",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              scrollable: true,
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      "Category: $category",
                                                                      style: const TextStyle(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              63,
                                                                              62,
                                                                              62),
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                    Text(
                                                                      "Sub Category: $subCategory",
                                                                      style: const TextStyle(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              63,
                                                                              62,
                                                                              62),
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                    Text(
                                                                      "Description: $description",
                                                                      style: const TextStyle(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              63,
                                                                              62,
                                                                              62),
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                    Text(
                                                                      "Signed on: $signedOn",
                                                                      style: const TextStyle(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              63,
                                                                              62,
                                                                              62),
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  style:
                                                                      const ButtonStyle(
                                                                    overlayColor:
                                                                        MaterialStatePropertyAll(Color.fromARGB(
                                                                            255,
                                                                            184,
                                                                            183,
                                                                            183)),
                                                                    side:
                                                                        MaterialStatePropertyAll(
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.blue),
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          "OK"),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else if (value == 1) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return const Center(
                                                              child:
                                                                  LoadingWidget(),
                                                            );
                                                          },
                                                        );

                                                        try {
                                                          // Calling viewDocument to get PDF data
                                                          Uint8List pdfData =
                                                              await viewDocument(
                                                                  grid[i][3]);

                                                          Navigator.pop(
                                                              context);

                                                          sessionStateStream
                                                              .add(SessionState
                                                                  .stopListening);

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PdfViewerScreen(
                                                                      pdfData:
                                                                          pdfData),
                                                            ),
                                                          ).then((_) => {
                                                                sessionStateStream.add(
                                                                    SessionState
                                                                        .startListening),
                                                              });
                                                        } catch (e) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      } else if (value == 2) {
                                                        if (grid[i][2] ==
                                                            'SIGNED') {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return const Center(
                                                                child:
                                                                    LoadingWidget(),
                                                              );
                                                            },
                                                          );

                                                          try {
                                                            // Calling viewCertificate API
                                                            Uint8List pdfData =
                                                                await viewCertificate(
                                                                    grid[i][3]);

                                                            Navigator.pop(
                                                                context);

                                                            sessionStateStream
                                                                .add(SessionState
                                                                    .stopListening);

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PdfViewerScreen(
                                                                        pdfData:
                                                                            pdfData),
                                                              ),
                                                            ).then((_) => {
                                                                  sessionStateStream.add(
                                                                      SessionState
                                                                          .startListening),
                                                                });
                                                          } catch (error) {
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        } //if
                                                        else {
                                                          // Performing action for other statuses
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    "Information"),
                                                                content: const Text(
                                                                    "This document is not signed"),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            "OK"),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }
                                                    }),
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
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Center(
                                                child: Text(
                                                  cellValue,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                    fontSize: fontSizeStatus,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        cellAlignments:
                                            const CellAlignments.fixed(
                                          contentCellAlignment:
                                              Alignment.centerLeft,
                                          stickyColumnAlignment:
                                              Alignment.topLeft,
                                          stickyRowAlignment:
                                              Alignment.centerLeft,
                                          stickyLegendAlignment:
                                              Alignment.centerLeft,
                                        ),
                                        cellDimensions: CellDimensions.fixed(
                                          contentCellWidth:
                                              screenWidth * 0.1119,
                                          contentCellHeight:
                                              screenHeight * 0.08,
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
                            )
                          : loading == 'progress'
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 50),
                                  child: Center(
                                      child: LoadingWidget(
                                          loadingText:
                                              "Fetching Documents...")),
                                )
                              : loading == 'failed'
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 50),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                  : Container(),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
