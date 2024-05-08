import 'package:pauzible_app/Models/file_info_modal.dart';

class UpdateUsernameAction {
  final String username;
  UpdateUsernameAction(this.username);
}

class UpdatePasswordAction {
  final String password;
  UpdatePasswordAction(this.password);
}

class LoginLoadingAction {}

class LoginSuccessAction {}

class LoginFailureAction {}

class UpdateFileInfo {
  final FileInfo fileInfo;

  UpdateFileInfo(this.fileInfo);
}

class UpdateAuthAction {
  String? firstName = 'Alan';
  String? lastName = '';
  String? displayName = '';
  String? userEmail = ' ';
  String? userId = '';
  String? photoUrl = '';
  String? token = '';
  String? skyFlowToken = '';

  UpdateAuthAction({
    this.firstName,
    this.lastName,
    this.displayName,
    this.userEmail,
    this.userId,
    this.photoUrl,
    this.token,
    this.skyFlowToken,
  });
}

class UpdateAuthSkyFLowAction {
  String? skyFlowToken = '';
  UpdateAuthSkyFLowAction({
    this.skyFlowToken,
  });
}

class UpdateFileCategoryAction {
  String? category = '';

  UpdateFileCategoryAction({
    this.category,
  });
}

class UpdateFileSubCategoryAction {
  String? subCategory = '';

  UpdateFileSubCategoryAction({
    this.subCategory,
  });
}

class UpdateFileDescriptionAction {
  String? description = '';

  UpdateFileDescriptionAction({
    this.description,
  });
}

class UpdateFormDescriptionAction {
  String? description = '';

  UpdateFormDescriptionAction({
    this.description,
  });
}

class UpdateFileRecordData {
  List<Map<String, dynamic>>? data = [];

  UpdateFileRecordData({
    this.data,
  });
}
