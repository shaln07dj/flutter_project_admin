import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pauzible_app/Helper/SharedPrefrences/shared_prefrences_helper.dart';
import 'package:pauzible_app/Helper/firebase_token_helper.dart';
import 'package:pauzible_app/Helper/get_token_helper.dart';
import 'package:pauzible_app/Helper/toast_helper.dart';
import 'package:pauzible_app/widgets/logout.dart';

Dio dio = Dio();
bool isRefreshing = false;
Dio tokenDio = Dio();
bool isInterceptorAdded = false;

class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null && err.response?.statusCode == 401 ||
        err.response?.statusCode == 403) {
      // Token is expired or invalid
      debugPrint("Inside onError");
      try {
        debugPrint("Inside Try onError");

        // Refresh the token
        String? firebaseToken = await getFirebaseIdToken();
        Response skyflowResponse = await getToken(firebaseToken!);
        String? skyflowToken = skyflowResponse.data['token'];
        // skyflowResponse.statusCode = 401;

        if (skyflowResponse.statusCode == 401) {
          debugPrint("Inside If of Try onError");

          SignOut();
          saveSkyFowToken('');
          saveFireBaseToken('');
          saveAppId('');
          handler.next(err);
          return;
        }

        // Update the Authorization header with the new token
        err.requestOptions.headers["Authorization"] = "Bearer $skyflowToken";

        // Retry the request with the new token
        final response = await dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );

        // If the request is successful, resolve the original request
        handler.resolve(response);
      } catch (e) {
        // If the token refresh fails, propagate the original error
        debugPrint("Inside Catch onError");

        SignOut();
        saveSkyFowToken('');
        saveFireBaseToken('');
        saveAppId('');
        handler.next(err);
      }
    } else {
      // If the error is not related to token expiration, propagate the error
      handler.next(err);
    }
  }
}

void addInterceptor() {
  if (!isInterceptorAdded) {
    dio.interceptors.add(TokenRefreshInterceptor());
    isInterceptorAdded = true;
  }
}

makeNetworkRequest(
  String method,
  String token,
  String baseUrl, {
  String? subUrl,
  String? vaultId,
  String? endpoint,
  String? tableName,
  dynamic queryparams,
  String? queryString,
  String? skyflowId,
  dynamic body,
  String? blobUrl,
  String? fileName,
  int attempts = 0,
}) async {
  addInterceptor();
  var options = Options(
    // Pass the custom headers, including the token
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
  );
  var multipartHeaders = Options(
    headers: {
      HttpHeaders.contentTypeHeader: 'multipart/form-data',
      'Authorization': 'Bearer $token'
    },
  );
  var getFileHeader = Options(
    headers: {
      'Authorization': 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/pdf'
    },
    responseType: ResponseType.bytes,
  );
  if (method == 'GET') {
    dynamic response = subUrl != null
        ? await fetchData(dio, method, baseUrl,
            subUrl: subUrl,
            vaultId: vaultId!,
            tableName: tableName!,
            skyflowId: skyflowId,
            queryparams: queryparams,
            options: options)
        : await fetchData(dio, method, baseUrl, options: options);
    return response;
  }

  if (method == 'GETTOKEN') {
    dynamic response =
        await fetchData(tokenDio, method, baseUrl, options: options);
    return response;
  }

  if (method == "GET_FILE") {
    dynamic response =
        await getFile(dio, method, baseUrl, options: getFileHeader);
    return response;
  }

  if (method == "POST") {
    dynamic response = await postData(
      dio,
      baseUrl,
      subUrl: subUrl,
      vaultId: vaultId,
      endpoint: endpoint,
      tableName: tableName,
      body: body,
      options: options,
    );
    return response;
  }

  if (method == "MULTIPART_POST") {
    dynamic response = await postMultipartData(dio, baseUrl,
        subUrl: subUrl,
        vaultId: vaultId,
        tableName: tableName,
        blobUrl: blobUrl,
        endpoint: endpoint,
        fileName: fileName,
        skyflowId: skyflowId,
        options: multipartHeaders);
    return response;
  }

  if (method == "PUT") {
    dynamic response = await putData(dio, baseUrl,
        subUrl: subUrl,
        vaultId: vaultId,
        queryString: queryString,
        tableName: tableName,
        skyflowId: skyflowId,
        body: body,
        options: options);
    return response;
  }
}

fetchData(Dio dio, String method, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? tableName,
    String? skyflowId,
    dynamic queryparams,
    required Options options}) async {
  try {
    var response = await dio.get(
      tableName != null
          ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName').toString()
          : baseUrl,
      queryParameters: queryparams != '' ? queryparams : {},
      options: options,
    );
    return response;
  } catch (e) {
    if (e is DioException) {
      debugPrint("Error type: ${e.type}");

      if (e.response != null && e.response?.statusCode == 404) {
        return e.response;
      } else if (e.response?.statusCode == 503) {
        debugPrint('Error receiveTimeout occured(connection):  $e');
        showToastHelper("Connection Timed Out. Please try again.");
      } else {
        debugPrint('Error in else of catch of fetchData: $e');
      }
    }
  }
}

postData(
  Dio dio,
  String baseUrl, {
  String? subUrl,
  String? vaultId,
  String? queryString,
  String? tableName,
  String? endpoint,
  dynamic body,
  bool? isMultipartRequest,
  required Options options,
}) async {
  try {
    var response = await dio.post(
      vaultId != null && queryString != null && endpoint == null
          ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName/$queryString')
              .toString()
          : vaultId != null && endpoint != null
              ? Uri.https(baseUrl, '$subUrl/$vaultId/$endpoint').toString()
              : Uri.https(baseUrl, '$subUrl/$endpoint').toString(),
      data: body,
      options: options,
    );
    debugPrint("type of response inside POST: ${response.runtimeType}");
    return response;
  } catch (e) {
    if (e is DioException) {
      debugPrint("Error type: ${e.type}");

      if (e.response != null && e.response?.statusCode == 404) {
        return e.response;
      } else if (e.response?.statusCode == 503) {
        debugPrint('Error receiveTimeout occured(connection):  $e');
        showToastHelper("Connection Timed Out. Please try again.");
      } else {
        debugPrint('Error in else of catch of postData: $e');
        return e.response;
      }
    }
  }
}

getFile(Dio dio, String method, String baseUrl,
    {required Options options}) async {
  try {
    var response = await dio.get(baseUrl, options: options);
    return response;
  } catch (e) {
    if (e is DioException) {
      debugPrint("Error type: ${e.type}");

      if (e.response != null && e.response?.statusCode == 404) {
        return e.response;
      } else if (e.response?.statusCode == 503) {
        debugPrint('Error receiveTimeout occured(connection):  $e');
        showToastHelper("Connection Timed Out. Please try again.");
      } else {
        debugPrint('Error in else of catch of getFile: $e');
      }
    }
  }
}

postMultipartData(Dio dio, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? queryString,
    String? tableName,
    String? skyflowId,
    String? endpoint,
    String? blobUrl,
    String? fileName,
    required Options options}) async {
  if (blobUrl != null) {
    final response = await http.get(Uri.parse(blobUrl));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      try {
        FormData formData = FormData.fromMap(
            {'file': MultipartFile.fromBytes(bytes, filename: fileName)});
        var response = await dio.post(
          'https://$baseUrl$subUrl/$vaultId/$tableName/$skyflowId/$endpoint',
          data: formData,
          options: options,
        );

        return response;
      } catch (e) {
        if (e is DioException) {
          debugPrint("Error type: ${e.type}");

          if (e.response != null && e.response?.statusCode == 404) {
            return e.response;
          } else if (e.response?.statusCode == 503) {
            debugPrint('Error receiveTimeout occured(connection):  $e');
            showToastHelper("Connection Timed Out. Please try again.");
          } else {
            debugPrint('Error in else of catch of postMultipartData: $e');
          }
        }
      }
    }
  }
}

putData(Dio dio, String baseUrl,
    {String? subUrl,
    String? vaultId,
    String? queryString,
    String? tableName,
    String? skyflowId,
    dynamic body,
    required Options options}) async {
  try {
    var response = await dio.put(
        vaultId != null && queryString != null
            ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName/$queryString')
                .toString()
            : vaultId != null
                ? Uri.https(baseUrl, '$subUrl/$vaultId/$tableName/$skyflowId')
                    .toString()
                : Uri.https(baseUrl, '$tableName').toString(),
        data: body,
        options: options);
    return response;
  } catch (e) {
    if (e is DioException) {
      debugPrint("Error type: ${e.type}");

      if (e.response != null && e.response?.statusCode == 404) {
        return e.response;
      } else if (e.response?.statusCode == 503) {
        debugPrint('Error receiveTimeout occured(connection):  $e');
        showToastHelper("Connection Timed Out. Please try again.");
      } else {
        debugPrint('Error in else of catch of putData: $e');
      }
    }
  }
}
