import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:koji/constants/app_color.dart';
import 'package:koji/core/app_constants.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import 'package:koji/services/api_client.dart';
import 'package:koji/services/api_constants.dart';
import 'package:koji/shared_widgets/custom_button.dart';
import 'package:koji/shared_widgets/custom_text.dart';

class AuthController extends GetxController {
  RxBool signUpLoading = false.obs;

  ///========================================== Sing up ==================================<>

  handleSignUp({
    String? name,
    email,
    password,
    filePath,
    required BuildContext context,
    required String screenType,
  }) async {
    String role = await PrefsHelper.getString(AppConstants.role);

    List<MultipartBody> multipartBody = filePath == null
        ? []
        : [MultipartBody("file", filePath)];

    signUpLoading(true);
    var body = {
      "firstName": "$name",
      "email": "$email",
      "password": "$password",
      "isAcceptPolicyTerms": "true",
    };

    var response = await ApiClient.postMultipartData(
      ApiConstants.signUpEndPoint,
      body,
      multipartBody: multipartBody,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await PrefsHelper.setString(
        AppConstants.bearerToken,
        response.body["data"]["verificationToken"],
      );
      //  if(screenType == "Sign Up"){
      //   context.pushNamed(AppRoutes.otpScreen, extra: {
      //     "screenType" : "user",
      //     "email" : ""
      //   });
      //  }

      ToastMessageHelper.showToastMessage(
        "Account create successful.\n \nNow you have an one time code your email",
      );
      signUpLoading(false);
    } else {
      ToastMessageHelper.showToastMessage(
        "${response.body["message"]}",
        title: 'Fail',
      );
      signUpLoading(false);
    }
  }

  RxBool mechanicSignUpLoading = false.obs;

  ///========================================Verify Email===========================================<>
  RxBool verfyLoading = false.obs;

  verfyEmail(
    String otpCode, {
    String screenType = '',
    String type = '',
    required BuildContext context,
  }) async {
    verfyLoading(true);
    var body = {"otp": otpCode};
    var response = await ApiClient.postData(
      ApiConstants.verifyEmailEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      verfyLoading(false);
      if (screenType == 'forgot') {
        debugPrint(
          "==========bearer token save done : ${response.body["data"]['token']}",
        );
        await PrefsHelper.setString(
          AppConstants.bearerToken,
          response.body["data"]['token'],
        );
      } else {
        debugPrint(
          "==========bearer token save done : ${response.body["data"]['accessToken']}",
        );
        await PrefsHelper.setString(
          AppConstants.bearerToken,
          response.body["data"]['accessToken'],
        );
      }

      if (type == 'Sign Up') {
        print(
          '================================ screenType received yjuikhujikgyhujvghg: $screenType',
        );
        if (screenType == "user") {
          // context.go(AppRoutes.logInScreen);
        }
      } else {
        // context.go(AppRoutes.resetPasswordScreen);
      }
      verfyLoading(false);
      ToastMessageHelper.showToastMessage("${response.body["message"]}");
    } else {
      verfyLoading(false);
      ToastMessageHelper.showToastMessage(
        "${response.body["message"]}",
        title: 'attention',
      );
      print(
        '================================ screenType received yjuikhujikgyhujvghg: $screenType',
      );
    }
  }

  ///============================================= Log in ===============================================<>
  RxBool logInLoading = false.obs;

  handleLogIn(
    String email,
    String password, {
    required BuildContext context,
  }) async {
    logInLoading.value = true;

    var headers = {'Content-Type': 'application/json'};
    var body = {"email": email, "password": password};

    var response = await ApiClient.postData(
      ApiConstants.loginUpEndPoint,
      jsonEncode(body),
      headers: headers,
    );

    print("========================${response.statusCode} \n ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.body['data']["attributes"]["user"];
      await PrefsHelper.setString(AppConstants.role, data['role']);
      await PrefsHelper.setString(
        AppConstants.bearerToken,
        response.body["data"]["attributes"]["tokens"]["accessToken"],
      );
      await PrefsHelper.setString(AppConstants.email, email);
      await PrefsHelper.setString(AppConstants.name, data['name']);
      await PrefsHelper.setString(AppConstants.userId, data['_id']);

      var role = data['role'];

      // context.go(AppRoutes.customerBottomNavBar);
      await PrefsHelper.setBool(AppConstants.isLogged, true);

      ToastMessageHelper.showToastMessage('You are logged in');
      logInLoading(false);
    } else {
      logInLoading(false);
      if (response.body["message"] ==
          "Email not verified. Please verify your email.") {
        context.go("", extra: {"screenType": "", "email": ""});
        await PrefsHelper.setString(
          AppConstants.bearerToken,
          response.body["data"]['tokens'],
        );
        ToastMessageHelper.showToastMessage(
          "We've sent an OTP to your email to verify your email.",
        );
      } else if (response.body["message"] == "⛔ Wrong password! ⛔") {
        ToastMessageHelper.showToastMessage(response.body["message"]);
      } else {
        ToastMessageHelper.showToastMessage(
          response.body['message'],
          title: 'attention',
        );
      }
    }
  }

  ///===========================================> Forgot Password ====================================================<>
  RxBool forgotLoading = false.obs;
  handleForgot(
    String email,
    screenType, {
    required BuildContext context,
  }) async {
    forgotLoading(true);
    var body = {"email": email};
    var response = await ApiClient.postData(
      ApiConstants.forgotPasswordEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token =
          response.body["data"]["resetPasswordToken"] ??
          response.body["data"]["verificationToken"];
      if (token != null) {
        await PrefsHelper.setString(AppConstants.bearerToken, token);
      } else {
        debugPrint("❌ Token missing in forgot response.");
      }

      if (screenType == "forgot") {
        context.pushNamed("", extra: {"screenType": "forgot", "email": email});
      }

      forgotLoading(false);
    } else {
      forgotLoading(false);
      ToastMessageHelper.showToastMessage(response.body["message"]);
    }
  }

  // handleForgot(String email, screenType, {required BuildContext context}) async {
  //   forgotLoading(true);
  //   var body = {"email": email};
  //   var response = await ApiClient.postData(
  //       ApiConstants.forgotPasswordEndPoint,
  //       jsonEncode(body),
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //
  //     PrefsHelper.setString(AppConstants.bearerToken, response.body["data"]["resetPasswordToken"]);
  //
  //
  //     if(screenType == "forgot"){
  //       context.pushNamed(AppRoutes.otpScreen, extra: {
  //         "screenType": "forgot", "email" : email});
  //     }
  //
  //     forgotLoading(false);
  //   }  else {
  //     forgotLoading(false);
  //     ToastMessageHelper.showToastMessage(response.body["message"]);
  //   }
  // }

  ///===============Set Password================<>

  RxBool setPasswordLoading = false.obs;

  setPassword(
    String password,
    confirmPassword, {
    required BuildContext context,
  }) async {
    setPasswordLoading(true);
    var body = {
      "password": password.toString().trim(),
      "confirmPassword": confirmPassword.toString().trim(),
    };

    var response = await ApiClient.postData(
      ApiConstants.resetPasswordEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      context.pushNamed("");
      ToastMessageHelper.showToastMessage('${response.body["message"]}');
      print("======>>> successful");
      setPasswordLoading(false);
    } else if (response.statusCode == 1) {
      setPasswordLoading(false);
      ToastMessageHelper.showToastMessage("Server error! \n Please try later");
    } else {
      setPasswordLoading(false);
      ToastMessageHelper.showToastMessage(
        '${response.body["message"]}',
        title: 'attention',
      );
    }
  }

  ///===============Resend================<>

  RxBool resendLoading = false.obs;

  reSendOtp() async {
    resendLoading(true);
    String token = await PrefsHelper.getString(AppConstants.bearerToken);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = {};
    var response = await ApiClient.postData(
      "ApiConstants.resendOtpEndPoint",
      jsonEncode(body),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final newToken =
          response.body["data"]["resetPasswordToken"] ??
          response.body["data"]["verificationToken"];
      if (newToken != null) {
        await PrefsHelper.setString(AppConstants.bearerToken, newToken);
      } else {
        debugPrint("❌ Token missing in resendOtp response.");
      }

      ToastMessageHelper.showToastMessage(
        'You have got an one time code to your email',
      );
      print("======>>> successful");
      resendLoading(false);
    } else {
      ToastMessageHelper.showToastMessage("${response.body["message"]}");
      resendLoading(false);
    }
  }

  // reSendOtp() async {
  //   resendLoading(true);
  //   String token = await PrefsHelper.getString(AppConstants.bearerToken);
  //   var headers = {
  //     'Content-Type': 'application/json',
  //   'Authorization': 'Bearer $token',
  //   };
  //   var body = {};
  //   var response = await ApiClient.postData(
  //       ApiConstants.resendOtpEndPoint,
  //       jsonEncode(body),
  //   headers: headers
  //   );
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     PrefsHelper.setString(AppConstants.bearerToken, response.body["data"]["verificationToken"]);
  //     ToastMessageHelper.showToastMessage(
  //         'You have got an one time code to your email');
  //     print("======>>> successful");
  //     resendLoading(false);
  //   }else{
  //     ToastMessageHelper.showToastMessage("${response.body["message"]}");
  //     resendLoading(false);
  //   }
  // }

  ///===============Change Password================<>

  RxBool changePasswordLoading = false.obs;
  changePassword(String currentPassword, password, confirmPassword) async {
    changePasswordLoading(true);
    var body = {
      "currentPassword": "$currentPassword",
      "password": "$password",
      "confirmPassword": "$confirmPassword",
    };

    var response = await ApiClient.postData(
      ApiConstants.changePassword,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ToastMessageHelper.showToastMessage('Password Changed Successful');
      print("======>>> successful");
      changePasswordLoading(false);
    } else if (response.statusCode == 1) {
      changePasswordLoading(false);
      ToastMessageHelper.showToastMessage("Server error! \n Please try later");
    } else {
      ToastMessageHelper.showToastMessage(response.body['message']);
      changePasswordLoading(false);
    }
  }

  ///=============== Delete Account ================<>

  var deleteLoading = false.obs;
  userDelete(BuildContext context) async {
    deleteLoading(true);
    var response = await ApiClient.deleteData("ApiConstants.deleteEndPoint");
    if (response.statusCode == 200) {
      ToastMessageHelper.showToastMessage('Account Delete Successfully');
      // context.pushNamed(AppRoutes.logInScreen);
    } else {
      deleteLoading(false);
    }
  }

  final RxInt countdown = 180.obs;
  final RxBool isCountingDown = false.obs;

  void startCountdown() {
    isCountingDown.value = true;
    countdown.value = 180;
    update();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
        update();
      } else {
        timer.cancel();
        isCountingDown.value = false;
        update();
      }
    });
  }
}
