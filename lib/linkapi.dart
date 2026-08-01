import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

final String linkServerName = "${getBaseUrl()}/user_profile";
final String linkGetItem = "$linkServerName/get_items.php";
final String linkGetItemFavorite = "$linkServerName/getFavorites.php";
final String linkUserProfile = "$linkServerName/getUser_Profile.php";
final String linkSearch2 = "$linkServerName/search2.php";
final String linkgetPassword = "$linkServerName/getPassword.php";
final String linkupdatePassword = "$linkServerName/updatePassword.php";
final String linkLogIn = "$linkServerName/login.php";
final String linkRiskEvaluator = "$linkServerName/risk_evaluator.php";
final String linkGetRiskLevel = "$linkServerName/get_risk_level.php";
final String linkItemDetails = "$linkServerName/iteam_deaiteld_from_dp.php";
final String linkAddProduct = "$linkServerName/add-product.php";
final String linktsamn = "$linkServerName/tsamn.php";
final String getAuctions = "$linkServerName/get_auctions.php";
final String getRecent = "$linkServerName/get-recent.php";
final String getData = "$linkServerName/get_data.php";
final String delete = "$linkServerName/delete.php";
final String linkSaveUser = "$linkServerName/save_user.php";
final String linkCart = "$linkServerName/user_participation.php";
final String reportUrl = "$linkServerName/report_seller.php";
final String cancelBid = "$linkServerName/cancel_bid.php";

String getBaseUrl() {
  if (kIsWeb) {
    return 'http://192.168.1.51'; // Web
  } else if (Platform.isAndroid) {
    return 'http://192.168.1.18'; // Android emulator
  } else {
    return 'http://192.168.1.51'; // iOS or desktop
  }
}

// 192.168.1.17
Widget buildImage(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return Image.asset("images/default1.png", fit: BoxFit.cover);
  }

  // If it's already a full URL (web or backend-generated), use it
  if (imagePath.startsWith("http")) {
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) =>
              Image.asset("images/default3.png", fit: BoxFit.cover),
    );
  }

  String baseUrl;

  if (kIsWeb) {
    // Web already gets full URLs
    baseUrl = ""; // Don't use baseUrl for web
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) =>
              Image.asset("images/default2.png", fit: BoxFit.cover),
    );
  } else if (Platform.isAndroid) {
    baseUrl = 'http://192.168.1.51/user_profile';
  } else {
    baseUrl = 'http://127.0.0.1/user_profile';
  }

  final fullUrl = "$baseUrl/$imagePath";

  return Image.network(
    fullUrl,
    fit: BoxFit.cover,
    errorBuilder:
        (context, error, stackTrace) =>
            Image.asset("images/default4.png", fit: BoxFit.cover),
  );
}
