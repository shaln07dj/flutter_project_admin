import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pauzible_app/Firebase/auth_helper.dart';
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/loading_widget.dart';
import 'package:pauzible_app/Helper/update_display_name_helper.dart';
import 'package:pauzible_app/screens/admin_view.dart';

class UserNameUpdateForm extends StatefulWidget {
  const UserNameUpdateForm({Key? key}) : super(key: key);

  @override
  _UserNameUpdateFormState createState() => _UserNameUpdateFormState();
}

class _UserNameUpdateFormState extends State<UserNameUpdateForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  String firstName = '';
  String lastName = '';
  RegExp get _name => RegExp(r'^[a-zA-Z]+$');
  double inputBoxHeight = 50;
  bool isNameUpdating = false;

  void getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
    } else {}
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void redirect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => admin_view(
          route: true,
        ),
      ),
    );
  }

  void handleNameUpdating(status) {
    setState(() {
      isNameUpdating = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: SizedBox(
        width: screenWidth * 0.4,
        height: screenHeight * 0.50,
        child: Container(
          margin: EdgeInsets.only(
              top: screenHeight * 0.05, left: screenWidth * 0.05),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 180, 179, 179),
              width: 0.5,
            ),
          ),
          child: isNameUpdating == true
              ? const Center(
                  child: LoadingWidget(loadingText: "Updating Name"),
                )
              : FormBuilder(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: screenHeight * 0.07),
                          width: 100,
                          height: 70,
                          color: const Color(0xFF0E5EB6),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset(
                                'assets/images/logo_icon.png',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "Please Provide Your Name",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * .011,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        SizedBox(
                          width: screenWidth * 0.25,
                          child: FormBuilderTextField(
                            name: 'First Name',
                            obscureText: false,
                            validator: FormBuilderValidators.compose(
                              [
                                FormBuilderValidators.required(),
                                (value) {
                                  if (!_name.hasMatch(value!)) {
                                    return 'Name is not in valid format';
                                  }
                                },
                              ],
                            ),
                            onChanged: (value) {
                              setState(() {
                                firstName = value!;
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'First Name ',
                              errorText: (firstName.isEmpty ||
                                      RegExp(r'^[a-zA-Z]+$')
                                          .hasMatch(firstName))
                                  ? null
                                  : 'Invalid input: Only alphabets are allowed',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50.0,
                          width: screenWidth * 0.25,
                          child: FormBuilderTextField(
                            name: 'Last Name',
                            obscureText: false,
                            validator: FormBuilderValidators.compose(
                              [
                                (value) {
                                  if (!_name.hasMatch(value!)) {
                                    return 'Name is not in valid format';
                                  }
                                },
                              ],
                            ),
                            onChanged: (value) {
                              setState(() {
                                lastName = value!;
                              });
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Last Name (Optional) ',
                              errorText: (lastName.isEmpty ||
                                      RegExp(r'^[a-zA-Z]+$').hasMatch(lastName))
                                  ? null
                                  : 'Invalid input: Only alphabets are allowed',
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: screenWidth * 0.176,
                              top: screenHeight * 0.07,
                            ),
                            width: screenWidth * 0.078,
                            height: screenHeight * 0.037,
                            color: const Color(0xFF0E5EB6),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        const Color(0xFF0E5EB6)),
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: firstName != ''
                                  ? () {
                                      handleNameUpdating(true);
                                      getFireBaseToken().then((token) {
                                        updateDisplayName(
                                            firstName, lastName, token,
                                            handleUpdating: handleNameUpdating);
                                      });
                                    }
                                  : () {},
                              child: Text(
                                "Update",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: screenWidth * .011,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
