import 'package:flutter_dotenv/flutter_dotenv.dart';

//
const double maxFileSize = 5;
const skyFlowTokenErrorStatusCode = 401;
const skyFlowToKenErrorMessage = "";
const fileUploadMsg = "Document Uploaded Successfully";
const invalidFileMsg = "File Type Unsupported";
const String jsonUploadMsg = "Form Uploaded Successfully";
const String jsonFailMsg = "Error Uploading Document.\nPlease Try Again";
const footerCopywriteText =
    "Copyright 2024 © Pauzible UK Limited, All rights reserved.";
const int descrptionMaxWords = 50;

//  .env imports
String baseUrl = "${dotenv.env['Base_URL']}"; //  devapi.pauzible.com
String subUrl = "${dotenv.env['Sub_URL']}"; //  /v1/api
String domainUrl = "${dotenv.env['Domain_URL']}";
String skyFlowBaseUrl =
    "${dotenv.env['Skyflow_Base_URL']}"; // a370a9658141.vault.skyflowapis-preview.com
String sfSubUrl = "${dotenv.env['Sf_Sub_URL']}"; //   /v1/vaults
String vaultId = "${dotenv.env['Vault_ID']}";
String vaultURL = "https://$skyFlowBaseUrl$sfSubUrl/$vaultId";
String applicationRecordsTable = "${dotenv.env['App_Records_Table']}";
String fileRecordsTable = "${dotenv.env['File_Records_Table']}";
String signRecordsTable = "${dotenv.env['Sign_Records_Table']}";
String userRecordsTable = "${dotenv.env['User_Records_Table']}";
String formRecordsTable = "${dotenv.env['Form_Records_Table']}";
String adminRecordsTable = "${dotenv.env['Admin_Records_Table']}";

// table name and query string
const String formTemplateTable = "formTemplates";
const String signUrl = 'getSignUrl';
const String queryEndpoint = "query";
const String files = "files";
const String tokenEndPoint = 'getTokenAdmin';
const String filteredStringForSignedRecord = "RECALLED";
const String createDoc = "createDocument";
const String docView = "viewDocument";
const String viewCert = "viewCertificate";
const String docRecall = 'recallDocument';
const String emailSmsEndpoint = "sendEmailSMS";
const String getTimeStamp = "timestamps";
const String updateName = "updateOfficerName";
const String createForm = "createFormTemplate";
const String formTemplatebyVersion = "formTemplateByVersion";
const String jsonForm = "getFormJSON";
// UI styles or conditional checks

const appStatusIconMap = [
  {"status": 'Registration', "image": "assets/images/registration.png"},
  {
    "status": 'Pre-Qualification',
    "image": "assets/images/pre_qualification.png"
  },
  {"status": 'Personal Details', "image": "assets/images/presonal_details.png"},
  {"status": 'Mortgage Details', "image": "assets/images/mortgage_details.png"},
  {
    "status": 'Documents Submission',
    "image": "assets/images/douments_submission.png"
  },
  {"status": 'Contract Signed', "image": "assets/images/contract_signed.png"},
  {"status": 'Disbursement', "image": "assets/images/disbursement.png"},
  {"status": 'Closure', "image": "assets/images/closure.png"},
];

const uploadedByCategoryIconMap = [
  {"category": 'Identity', "image": "assets/images/category_identity.png"},
  {
    "category": 'Income proof',
    "image": "assets/images/category_income_proof.png"
  },
  {
    "category": 'Residence proof',
    "image": "assets/images/category_residence_proof.png"
  },
  {
    "category": 'Property and mortgage information',
    "image": "assets/images/category_property_mortgage_info.png"
  },
  {"category": 'Credit', "image": "assets/images/category_credit.png"},
];

const uploadedForCategoryIconMap = [
  {"category": 'Approval', "image": "assets/images/category_approval.png"},
  {
    "category": 'Disbursement',
    "image": "assets/images/category_disbursement.png"
  },
  {"category": 'Closure', "image": "assets/images/category_colsure.png"},
];

//session

int inActivitySessionTimeoutDuration = 600;
