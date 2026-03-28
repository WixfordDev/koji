import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:koji/core/app_constants.dart';
import 'package:koji/helpers/prefs_helper.dart';
import 'package:koji/helpers/toast_message_helper.dart';
import 'package:koji/routes/route_helper.dart';
import 'package:koji/services/api_client.dart';
import 'package:koji/services/api_constants.dart';
import 'package:koji/services/firebase_notification_service.dart';
import 'package:koji/services/socket_services.dart';

class AuthController extends GetxController {
  RxBool signUpLoading = false.obs;

  ///========================================== Sing up ==================================<>

  handleSignUp({
    String? firstName,
    email,
    password,
    required bool isAcceptPolicyTerms,
    required BuildContext context,
    required String screenType,
  }) async {
    signUpLoading(true);
    var body = {
      "firstName": firstName,
      "email": email,
      "password": password,
      "isAcceptPolicyTerms": isAcceptPolicyTerms,
    };

    var response = await ApiClient.postData(
      ApiConstants.signUpEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (screenType == "Sign Up") {
        RouteHelper.goToVerifyScreen(
          context,
          email: email.toString(),
          screenType: "user",
        );
      }

      ToastMessageHelper.showToastMessage(
        "Account create successful.\n \nNow you have an one time code your email",
      );
      signUpLoading(false);

      await PrefsHelper.setString(
        AppConstants.bearerToken,
        response.body["data"]["verificationToken"],
      );
    } else {
      ToastMessageHelper.showToastMessage(
        "${response.body["message"]}",
        title: 'Fail',
      );
      signUpLoading(false);
    }
  }

  RxBool mechanicSignUpLoading = false.obs;
  RxBool resendOtpLoading = false.obs;

  Future<void> handleResendOtp({
    required String email,
    required BuildContext context,
  }) async {
    resendOtpLoading(true);
    try {
      var body = {"email": email};

      var response = await ApiClient.postData(
        ApiConstants.forgotPasswordEndPoint,
        jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessageHelper.showToastMessage(
          "Verification code sent successfully",
        );
      } else {
        ToastMessageHelper.showToastMessage(
          "${response.body["message"]}",
          title: 'Failed',
        );
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        "Failed to send verification code",
        title: 'Error',
      );
    } finally {
      resendOtpLoading(false);
    }
  }

  ///========================================Verify Email===========================================<>
  RxBool verfyLoading = false.obs;

  verfyEmail({
    required String email,
    required String code,
    String screenType = '',
    String type = '',
    required BuildContext context,
  }) async {
    verfyLoading(true);
    var body = {"email": email, "code": code};
    var response = await ApiClient.postData(
      ApiConstants.verifyEmailEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      verfyLoading(false);

      if (screenType == "forgot") {
        RouteHelper.goToResetPassword(context);
      } else if (screenType == "user") {
        RouteHelper.goToSignIn(context);
      } else {
        RouteHelper.goToAdminBottomNav(context);
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

    await FirebaseNotificationService.printFCMToken();
    String fcmToken = await PrefsHelper.getString(AppConstants.fcmToken);

    var headers = {'Content-Type': 'application/json'};
    var body = {
      "email": "$email",
      "password": "$password",
      "fcmToken": fcmToken,
    };

    var response = await ApiClient.postData(
      ApiConstants.loginUpEndPoint,
      body,
      headers: headers,
    );

    print("========================${response.statusCode} \n ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.body['data']["attributes"]["user"];
      await PrefsHelper.setString(AppConstants.role, data['role']);
      await PrefsHelper.setString(
        AppConstants.bearerToken,
        response.body["data"]["attributes"]["tokens"]["access"]["token"],
      );
      await PrefsHelper.setString(AppConstants.email, email);
      await PrefsHelper.setString(AppConstants.name, data['fullName'] ?? '');
      await PrefsHelper.setString(AppConstants.userId, data['id'] ?? data['_id'] ?? '');
      await PrefsHelper.setString(AppConstants.image, data['image'] ?? '');

      var role = data['role'];

      await PrefsHelper.setBool(AppConstants.isLogged, true);

      // Init socket with token + userId so server accepts the connection
      final accessToken = response.body["data"]["attributes"]["tokens"]["access"]["token"];
      await SocketServices().init(
        userId: data['id'],
        fcmToken: fcmToken,
        bearerToken: accessToken,
      );

      if (role == "employee") {
        RouteHelper.goToEmployeeBottomNav(context);
      } else {
        RouteHelper.goToAdminBottomNav(context);
      }

      ToastMessageHelper.showToastMessage('You are logged in');
      logInLoading(false);
    } else {
      logInLoading(false);

      // Handle different error messages
      final message = response.body["message"];

      print("Login Error: $message");
      print("Full Response: ${response.body}");

      if (message == "Email not verified") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("We've sent an OTP to your email to verify your email."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        RouteHelper.goToVerifyScreen(
          context,
          email: email.toString(),
          screenType: "user",
        );

        await PrefsHelper.setString(
          AppConstants.bearerToken,
          response.body["data"]['tokens'],
        );
      } else if (message == "⛔ Wrong password! ⛔") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Incorrect password. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (message == "No users found with this email") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No account found with this email. Please sign up first.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (message == "Admin not approved your account yet. Please contact to admin") {
        // Show error using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your account is pending admin approval. Please wait or contact support.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to login. Please check your credentials.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
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

      // Save the email to prefs so reset screen can use it
      await PrefsHelper.setString(AppConstants.email, email);

      if (screenType == "forgot") {
        RouteHelper.goToVerifyScreen(
          context,
          email: email,
          screenType: "forgot",
        );
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

    try {
      final String? email = await PrefsHelper.getString(AppConstants.email);

      if (email == null || email.isEmpty) {
        // If email isn't in prefs, inform the user and abort.
        ToastMessageHelper.showToastMessage(
          'Email not found. Please enter your email and try again.',
          title: 'Error',
        );
        setPasswordLoading(false);
        return;
      }

      var body = {"email": email, "password": password.toString().trim()};

      var headers = {'Content-Type': 'application/json'};

      var response = await ApiClient.postData(
        ApiConstants.resetPasswordEndPoint,
        jsonEncode(body),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to sign in screen after successful reset
        RouteHelper.goToSignIn(context);
        ToastMessageHelper.showToastMessage(
          response.body["message"] ?? 'Password reset successful',
        );
      } else {
        // Show server-provided message when available
        final msg = response.body?['message'] ?? 'Failed to reset password';
        ToastMessageHelper.showToastMessage(msg, title: 'Error');
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        'Unexpected error: $e',
        title: 'Error',
      );
    } finally {
      setPasswordLoading(false);
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

  ///===============Change Password================<>

  RxBool changePasswordLoading = false.obs;
  changePassword(String oldPassword, newPassword) async {
    changePasswordLoading(true);
    var body = {
      "oldPassword": "$oldPassword",
      "newPassword": "$newPassword",
    };

    var response = await ApiClient.postData(
      ApiConstants.changePasswordEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ToastMessageHelper.showToastMessage('Password Changed Successful');
      Get.back();
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
