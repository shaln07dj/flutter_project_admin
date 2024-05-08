import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pauzible_app/Helper/Constants/constant.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/Models/file_data_model.dart';

class FormDropZoneWidget extends StatefulWidget {
  final onDroppedFile;
  final Function(bool isValid) isValidFileType;
  final bool isValidFile;
  final FormDropZoneController controller;
  final Function resetFileInfo;
  final Function resetfileSuccess;

  const FormDropZoneWidget(
      {required this.controller,
      Key? key,
      required this.onDroppedFile,
      required this.isValidFileType,
      required this.isValidFile,
      required this.resetFileInfo,
      required this.resetfileSuccess})
      : super(key: key);
  @override
  _FormDropZoneWidgetState createState() =>
      _FormDropZoneWidgetState(controller);
}

class FormDropZoneController {
  late void Function() reset;
}

class _FormDropZoneWidgetState extends State<FormDropZoneWidget> {
  late DropzoneViewController controller;
  bool highlight = false;
  final List<String> dropdownItems = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  String? selectedValue;
  String fileName = '';
  bool allowedFileType = true;
  bool allowedSize = false;

  _FormDropZoneWidgetState(FormDropZoneController controller) {
    controller.reset = resetDropzoneView;
  }

  void resetDropzoneView() {
    setState(() {
      highlight = false;
    });
    setState(() {
      fileName = '';
    });
  }

  void resetData() {
    resetDropzoneView();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return buildDecoration(
      child: Stack(
        children: [
          DropzoneView(
            mime: const [
              'application/json',
            ],
            onCreated: (controller) => this.controller = controller,
            onDrop: uploadedFile,
            onHover: () => setState(() => highlight = true),
            onLeave: () => setState(() => highlight = false),
            onLoaded: () => debugPrint('Zone Loaded'),
            onError: (err) => debugPrint('run when error found : $err'),
            onDropInvalid: (ev) => debugPrint('Zone 2 invalid MIME: $ev'),
            onDropMultiple: (ev) async {
              debugPrint('Zone 2 drop multiple: $ev');
            },
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                final events = await controller.pickFiles(
                  multiple: false,
                  mime: [
                    'application/json',
                  ],
                );
                if (events.isEmpty) return;
                uploadedFile(events.first);
              },
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: const Color(0xFFF1F1F1),
                    child: fileName == ''
                        ? GestureDetector(
                            onTap: () async {
                              final events = await controller.pickFiles(
                                multiple: false,
                                mime: [
                                  'application/json',
                                ],
                              );
                              if (events.isEmpty) return;
                              uploadedFile(events.first);
                            },
                            child: Column(children: [
                              Container(
                                  margin:
                                      EdgeInsets.only(top: screenHeight * 0.01),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 30,
                                    color: Colors.black,
                                  )),
                              const Text(
                                'Drag & Drop your form here',
                                style: TextStyle(
                                  color: Color(0xFF8F8F8F),
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'or',
                                style: TextStyle(
                                  color: Color(0xFF8F8F8F),
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'Browse to upload form',
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.lightBlue),
                              ),
                              !allowedFileType
                                  ? const Text(
                                      '',
                                      // 'File Type Unsupported',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 249, 5, 5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal),
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                              allowedSize
                                  ? const Text(
                                      'Too large file',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 249, 5, 5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal),
                                    )
                                  : const Text(
                                      '',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 249, 5, 5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal),
                                    )
                            ]),
                          )
                        : Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    widget.resetFileInfo();
                                    widget.resetfileSuccess();
                                    setState(
                                      () {
                                        fileName = '';
                                        allowedFileType = true;
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color.fromARGB(255, 112, 112, 112),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: screenHeight * 0.02),
                              width: screenWidth * 0.120,
                              height: screenHeight * 0.08,
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  color: Color(0xFF8F8F8F),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future uploadedFile(dynamic event) async {
    List<String> allowedMime = [
      'application/json',
    ];
    final name = event.name;
    final mime = await controller.getFileMIME(event);

    final byteSize = await controller.getFileSize(event);

    if (byteSize < maxFileSize * 1024 * 1024) {
      setState(() {
        allowedSize = false;
      });
      if (allowedMime.contains(mime)) {
        setState(() {
          allowedFileType = true;
        });

        widget.isValidFileType(allowedFileType);
        setState(() {
          fileName = name;
        });
      } else {
        setState(() {
          allowedFileType = false;
          showToastHelper("File Type Unsupported");
        });

        setState(() {
          fileName = '';
        });
        widget.isValidFileType(allowedFileType);
      }

      if (allowedFileType == true) {
        debugPrint('Inside IF of Bytes');
      
        var droppedFile = await controller.getFileData(event);
      
        widget.onDroppedFile(droppedFile);

        setState(() {
          fileName = name;
          highlight = false;
        });
      }
    } else {
      setState(() {
        allowedSize = true;
      });
    }
  }



  Widget buildDecoration({required Widget child}) {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.all(1),
        color: const Color(0xFFF1F1F1),
        child: DottedBorder(
          borderType: BorderType.RRect,
          strokeWidth: 1,
          dashPattern: const [8, 4],
          padding: EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
