import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/form_json_upload.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/Models/form_cat_subcat.dart';
import 'package:pauzible_app/redux/actions.dart';
import 'package:pauzible_app/widgets/form_cat_dropdown.dart';
import 'package:pauzible_app/widgets/form_drop_zone_widget.dart';
import 'package:pauzible_app/widgets/wordLimitInputFormatter.dart';

class FormSubcatDropdown extends StatefulWidget {
  final Function(String) callback;
  final bool resetSubCategory;
  final Function(bool) setSubCategory;

  FormSubcatDropdown({
    Key? key,
    required this.callback,
    required this.resetSubCategory,
    required this.setSubCategory,
  }) : super(key: key);
  @override
  State<FormSubcatDropdown> createState() => _FormSubcatDropdownState();
}

class _FormSubcatDropdownState extends State<FormSubcatDropdown> {
  var screenWidth = 0.0;
  var screenHeight = 0.0;

  List<String> formSubcatDropdownItems = [];

  String? selectedValue;

  void setFormSubCategoryList(category) {
    setState(() {
      selectedValue = null;
    });
    for (var item in formCatSubcatData) {
      if (item['category'] == category) {
        setState(() {
          formSubcatDropdownItems = item['sub-category'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool resetSubCat = widget.resetSubCategory;

    screenWidth = (MediaQuery.of(context).size.width);
    screenHeight = (MediaQuery.of(context).size.height);

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
              debugPrint("Tap event prevented!");
            },
            child: DropdownButton2<String>(
              isExpanded: true,
              value: resetSubCat ? null : selectedValue,
              underline: const SizedBox.shrink(),
              onChanged: (String? newValue) {
                widget.callback(newValue!);
                widget.setSubCategory(false);
                setState(() {
                  selectedValue = newValue;
                });
                resetSubCat = true;
              },
              items: formSubcatDropdownItems
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
                "Select Form Sub-Cat.",
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

class uploadNewForm extends StatefulWidget {
  String loading = 'success';

  uploadNewForm({super.key});

  @override
  State<uploadNewForm> createState() => _uploadNewFormState();
}

class _uploadNewFormState extends State<uploadNewForm> {
  String? category;
  String? subCategory;
  bool categorySuccess = false;
  bool subCategorySuccess = false;
  bool success = false;
  bool resetCategoryValue = false;
  bool resetSubCategoryValue = false;
  String? descp;
  bool disableButton = false;
  bool fileSuccess = false;
  bool isResetFile = false;
  var file;
  bool? isValidFileType = false;

  final GlobalKey<_FormSubcatDropdownState> _subDropDownKey =
      GlobalKey<_FormSubcatDropdownState>();
  final TextEditingController _description = TextEditingController();
  final FormDropZoneController dropzoneViewController =
      FormDropZoneController();

  @override
  void initState() {
    super.initState();

    // fetchForm();
  }

  // void fetchForm() async {
  //   String? firetoken = await getFirebaseIdToken();
  // }

  void isSuccessfull() {
    setState(() {
      success = !success;
      categorySuccess = false;
      subCategorySuccess = false;
      fileSuccess = false;
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

    void updateCategory(String cat) {
      setState(() {
        category = cat;
        categorySuccess = true;
        _subDropDownKey.currentState!.setFormSubCategoryList(cat);
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

    void checkValidFileType(bool isValidFile) {
      setState(() {
        isValidFileType = isValidFile;
      });
    }

    void resetfileSuccess() {
      setState(() {
        fileSuccess = false;
      });
    }

    void fileReset(bool resetFile) {
      setState(() {
        isResetFile = resetFile;
      });
    }

    void resetDropZone() {
      dropzoneViewController.reset();
    }

    void resetTextField() {
      _description.clear();
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
        disableButton = true;
      });
    }

    void showToast(String msg) {
      showToastHelper(msg);
    }

    void resetSubCategoryDefault() {
      setState(() {
        subCategory = null;
      });
    }

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Container(
          color: Colors.white,
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
                      right: screenWidth * 0.038,
                      bottom: screenWidth * 0.02,
                      top: screenWidth * 0.015,
                    ),
                    child: const Text(
                      'Upload New User Form',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              widget.loading == 'progress'
                  ? const Expanded(
                      child: LoadingWidget(loadingText: "Fetching Details..."),
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
                          ? Center(
                              child: Container(
                                width: screenWidth * .39,
                                // height: screenHeight * .69,
                                color: const Color(0xFFFFFFFF),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            // margin: EdgeInsets.only(
                                            //   left: screenWidth * 0.02,
                                            // ),
                                            width: screenWidth * 0.17,
                                            height: screenHeight * 0.07,
                                            child: FormCatDropdown(
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
                                            child: FormSubcatDropdown(
                                              key: _subDropDownKey,
                                              callback: updateSubCategory,
                                              resetSubCategory:
                                                  resetSubCategoryValue,
                                              setSubCategory: setSubCategory,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.027),
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: screenWidth * 0.04,
                                        ),
                                        width: screenWidth * 0.40,
                                        child: TextField(
                                          maxLines: 2,
                                          inputFormatters: [
                                            WordLimitInputFormatter(
                                                descrptionMaxWords)
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              descp = value;
                                            });
                                            StoreProvider.of<AppState>(context)
                                                .dispatch(
                                              UpdateFormDescriptionAction(
                                                description: descp,
                                              ),
                                            );
                                          },
                                          style: const TextStyle(fontSize: 12),
                                          controller: _description,
                                          decoration: const InputDecoration(
                                            hintText:
                                                '     Please enter description ( $descrptionMaxWords words )',
                                            hintStyle: TextStyle(fontSize: 14),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFB8B8B8)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.03),
                                    Center(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          right: screenWidth * 0.04,
                                        ),
                                        width: screenWidth * 0.232,
                                        height: screenHeight * 0.19,
                                        child: SizedBox(
                                          width: screenWidth * 0.25,
                                          child: FormDropZoneWidget(
                                            onDroppedFile: (file) {
                                              debugPrint(
                                                  "Inside dropped file above setstate");
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
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    Container(
                                      margin: EdgeInsets.only(
                                        right: screenWidth * 0.04,
                                      ),
                                      width: screenWidth * 0.078,
                                      height: screenHeight * 0.037,
                                      color: categorySuccess &&
                                              subCategorySuccess &&
                                              fileSuccess
                                          ? Colors.lightBlueAccent
                                          : Colors.grey,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  categorySuccess &&
                                                          subCategorySuccess &&
                                                          fileSuccess
                                                      ? Colors.lightBlueAccent
                                                      : Colors.grey),
                                          textStyle: MaterialStateProperty.all<
                                              TextStyle>(
                                            const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        onPressed: categorySuccess &&
                                                subCategorySuccess &&
                                                fileSuccess
                                            ? () {
                                                formJsonUpload(
                                                  file: file,
                                                  isSuccessfull: isSuccessfull,
                                                  resetFileInfo: resetFileInfo,
                                                  showToast: showToast,
                                                  resetCategory: resetCategory,
                                                  resetSubCategory:
                                                      resetSubCategory,
                                                  fileReset: fileReset,
                                                  resetDropZone: resetDropZone,
                                                  resetTextField:
                                                      resetTextField,
                                                  resetSubCategoryDefault:
                                                      resetSubCategoryDefault,
                                                );
                                              }
                                            : () {
                                                if (categorySuccess == false) {
                                                  showToastHelper(
                                                      "Select Category");
                                                }
                                                if (categorySuccess == true &&
                                                    subCategorySuccess ==
                                                        false) {
                                                  showToastHelper(
                                                      "Select Sub Category");
                                                }
                                                if (categorySuccess == true &&
                                                    subCategorySuccess ==
                                                        true &&
                                                    fileSuccess == false) {
                                                  showToastHelper(
                                                      "Select File");
                                                }
                                              },
                                        child: Text(
                                          "Upload",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: screenWidth * .011,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container()
            ],
          ),
        ),
      ),
    );
  }
}
