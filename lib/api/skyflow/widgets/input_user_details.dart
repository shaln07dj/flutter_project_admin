import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pauzible_app/api/skyflow/widgets/responsive.dart';

class InputUserDetails extends StatefulWidget {
  InputUserDetails({Key? key});

  @override
  State<InputUserDetails> createState() {
    return _InputUserDetails();
  }
}

class _InputUserDetails extends State<InputUserDetails> {
  String dropdownValue = 'Option 1';
  String textValue = '';
  String? _fileName = '';

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'png',
        'mp4',
        'webm',
      ],
      withData: false,
      withReadStream: true,
    );
    List<PlatformFile> files = result!.files;

    if (files.isNotEmpty) {
      PlatformFile selectedFile = files.first;
      String fileName = selectedFile.name;
      int fileSize = selectedFile.size;

      setState(() {
        _fileName = selectedFile.name;
      });
    }

    if (result != null) {}
  }

  void _selectFile() {
    // Add file selection logic here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButton<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Expanded(
                child: !Responsive.isDesktop(context)
                    ? Container(
                        width: 10,
                        margin: const EdgeInsets.all(5),
                        child: TextField(
                          style: const TextStyle(fontSize: 12),
                          onChanged: (value) {
                            setState(() {
                              textValue = value;
                            });
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            hintText: 'Enter some text',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      )
                    : Container(
                        width: 10,
                        margin: const EdgeInsets.all(5),
                        child: TextField(
                          style: const TextStyle(fontSize: 12),
                          onChanged: (value) {
                            setState(() {
                              textValue = value;
                            });
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            hintText: 'Enter some text',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _openFileExplorer,
                child: const Text('Open File Selector'),
              ),
              const SizedBox(height: 20),
              if (_fileName != null && _fileName!.isNotEmpty)
                Text(
                  'Selected File Name: $_fileName',
                  style: const TextStyle(fontSize: 16),
                ),
              if (_fileName == null || _fileName!.isEmpty)
                const Text(
                  'No file selected',
                  style: TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
