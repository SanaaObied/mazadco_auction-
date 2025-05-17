import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

const String linkServerName = "http://10.0.2.2/user_profile";
const String linkGetItem = "$linkServerName/get_items.php";
const String linkGetItemFavorite = "$linkServerName/getFavorites.php";
const String linkUserProfile = "$linkServerName/getUser_Profile.php";
const String linkSearch2 = "$linkServerName/search2.php";

//getUser_Profile
const String linkgetPassword = "$linkServerName/getPassword.php";
const String linkupdatePassword = "$linkServerName/updatePassword.php";
//http://localhost/user_profile/login.php
const String linkLogIn="$linkServerName/login.php";
const String linkRiskEvaluator =
    "$linkServerName/risk_evaluator.php";
//127.0.0.1

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://127.0.0.1'; // Web
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2'; // Android emulator
  } else {
    return 'http://127.0.0.1'; // iOS or desktop
  }
}
