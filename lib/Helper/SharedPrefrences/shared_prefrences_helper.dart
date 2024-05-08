import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? prefs;
Future<void> initSharedPreferences() async {
  prefs = await SharedPreferences.getInstance();
}

Future<void> clearSharedPreferences() async {
  await prefs!.clear();
}

void saveSkyFowToken(token) async {
  prefs?.setString('skyFlowToken', token);
}

saveFireBaseToken(token) async {
  prefs?.setString('firebaseToken', token);
}

saveFireBaseRefreshToken(token) async {
  prefs?.setString('refreshToken', token);
}

saveAppId(String appId) async {
  prefs?.setString('appId', appId);
}

saveSkyflowId(String skyflowId) async {
  prefs?.setString('skyFlowId', skyflowId);
}

setRole(String role) async {
  prefs?.setString('role', role);
}

Future<void> savegetApplictionRecordsList(
    String key, List<dynamic> list) async {
  String jsonString = jsonEncode(list);
  prefs?.setString(key, jsonString);
}

getSkyFlowToken() async {
  String token = prefs?.getString('skyFlowToken') ?? 'defaultString';
  return token;
}

// refterdsgh toke jh

getFireBaseToken() async {
  String token = prefs?.getString('firebaseToken') ?? 'defaultString';
  return token;
}

getFireBaseRefreshToken() async {
  String token = prefs?.getString('refreshToken') ?? 'defaultString';
  return token;
}

getAppId() async {
  String appId = prefs?.getString('appId') ?? 'Test124';
  return appId;
}

getSkyflowId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String skyflowId = prefs?.getString('skyFlowId') ?? '';
  return skyflowId;
}

getRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String role = prefs?.getString('role') ?? '';
  return role;
}

Future<List<dynamic>> getApplictionRecordsList(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs?.getString(key);

  // If jsonString is null or empty, return an empty list
  if (jsonString == null || jsonString.isEmpty) {
    return [];
  }

  // Parse the JSON string to a list of maps
  List<dynamic> recordsList = List<dynamic>.from(jsonDecode(jsonString));

  return recordsList;
}
