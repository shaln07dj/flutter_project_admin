import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/Models/category_subcategory.dart';
import 'package:pauzible_app/Models/file_record.dart';

class Dropdown extends StatefulWidget {
  final Function(String) callback;
  final bool resetCategory;
  final Function(bool) setCategory;

  const Dropdown({
    super.key,
    required this.callback,
    required this.resetCategory,
    required this.setCategory,
  });
  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  var screenWidth = 0.0;
  var screenHeight = 0.0;
  FileRecord? record;

  final List<String> categoryDropdownItems = [];

  String? selectedValue;
  @override
  void initState() {
    super.initState();

    for (var item in categorySubCategoryData) {
      if (!categoryDropdownItems.contains(item['category'])) {
        categoryDropdownItems.add(item['category']);
      }
      if (item['category'] == 'Identity') {}
    }
  }

  @override
  Widget build(BuildContext context) {
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
                isExpanded: true,
                value: widget.resetCategory ? null : selectedValue,
                underline: const SizedBox.shrink(),
                onChanged: (String? category) {
                  widget.callback(category!);
                  widget.setCategory(false);

                  setState(() {
                    selectedValue = category!;
                  });
                },
                items: categoryDropdownItems
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                          ),
                        ),
                      ));
                }).toList(),
                hint: const Text(
                  "Select Category",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w100),
                ),
              ),
            ),
          );
        });
  }
}
