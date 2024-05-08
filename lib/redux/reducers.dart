import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/Models/file_info_modal.dart';
import 'package:pauzible_app/redux/actions.dart';
 
AppState updateAuth(AppState state, dynamic action) {
  if (action is UpdateAuthAction) {
    return AppState(
        firstName: action.firstName,
        lastName: action.lastName,
        displayName: action.displayName,
        userEmail: action.userEmail,
        userId: action.userId,
        photoUrl: action.photoUrl,
        token: action.token,
        skyFlowToken: action.skyFlowToken);
  }
 
  // If action is not UpdateAuthAction, return the current state
  return state;
}
 
AppState updateAuthSkyFlow(AppState state, dynamic action) {
  if (action is UpdateAuthSkyFLowAction) {
    return AppState(skyFlowToken: action.skyFlowToken);
  }
 
  // If action is not UpdateAuthAction, return the current state
  return state;
}
 
AppState updateFileInfo(AppState state, dynamic action) {
  if (action is UpdateFileInfo) {
    List<FileInfo> updatedFileInfoList = List.from(state.fileInfoList ?? [])
      ..add(action.fileInfo);
    return AppState(
      // other fields in your state
      fileInfoList: updatedFileInfoList,
    );
  }
  return state;
}
 
AppState updateFileCategoryInfo(AppState state, dynamic action) {
  if (action is UpdateFileCategoryAction) {
    return AppState(
      category: action.category,
    );
  }
  return state;
}
 
AppState updateFileSubCategoryInfo(AppState state, dynamic action) {
  if (action is UpdateFileSubCategoryAction) {
    return AppState(
      subCategory: action.subCategory,
    );
  }
  return state;
}
 
AppState updateFileDescription(AppState state, dynamic action) {
  if (action is UpdateFileDescriptionAction) {
    return AppState(
      description: action.description,
    );
  }
  return state;
}
 
AppState updateFileRecordData(AppState state, dynamic action) {
  if (action is UpdateFileRecordData) {
    return AppState(data: action.data);
  }
 
  // If action is not UpdateAuthAction, return the current state
  return state;
}