import 'package:pauzible_app/Models/app_state.dart';
import 'package:pauzible_app/redux/reducers.dart';
import 'package:redux/redux.dart';
 
final Reducer<AppState> appReducer = combineReducers<AppState>([
  updateAuth,
  updateFileCategoryInfo,
]);
 
final Store<AppState> store = Store<AppState>(
  appReducer, // Your reducer function
  initialState: AppState(
    // Initial state for your app
    firstName: 'Alan',
    lastName: '',
    displayName: '',
    userEmail: '',
    userId: '',
    photoUrl: '',
    token: '',
    skyFlowToken: '',
    fileName: '',
    fileSize: '',
    fileInfoList: [],
    category: '',
    subCategory: '',
    description: '',
    data: [],
  ),
);