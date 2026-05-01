import 'dart:io';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../helpers/toast_message_helper.dart';
import '../models/admin-model/profile_model.dart';


class ProfileController extends GetxController {

  RxBool getProfileLoading = false.obs;
  Rx<ProfileModel> profile = ProfileModel().obs;

  getProfile() async {
    getProfileLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getProfileEndPoint);

      if (response.statusCode == 200) {

        profile.value = ProfileModel.fromJson(response.body['data']['attributes']);
        getProfileLoading(false);
      } else if (response.statusCode == 404) {
        getProfileLoading(false);
      } else {
        getProfileLoading(false);
      }
    } catch (e) {
      getProfileLoading(false);
    }
  }





  RxBool updateProfileLoading = false.obs;

  profileUpdate({
    String? firstName,
    String? lastName,
    String? callingCode,
    String? phoneNumber,
    String? nidNumber,
    String? dateOfBirth,
    String? gender,
    String? maritalStatus,
    String? address,
    File? file,
    required String screenType,
  }) async {
    print('🔄 Starting profile update...');
    print('📝 firstName: $firstName, phoneNumber: $phoneNumber, address: $address');
    print('📷 File: ${file != null ? "Image selected" : "No image"}');

    updateProfileLoading(true);

    var body = {
      "firstName": firstName ?? "",
      "lastName": lastName ?? "",
      "callingCode": callingCode ?? "",
      "phoneNumber": phoneNumber ?? "",
      "nidNumber": nidNumber ?? "",
      "dateOfBirth": dateOfBirth ?? "",
      "gender": gender ?? "",
      "maritalStatus": maritalStatus ?? "",
      "address": address ?? "",
    };

    print('📦 Request body: $body');

    List<MultipartBody>? multipartBody;
    if (file != null) {
      multipartBody = [MultipartBody("image", file)];
      print('📎 Multipart body created with image');
    }

    try {
      print('🌐 Sending PATCH request to: ${ApiConstants.updateProfileEndPoint}');
      var response = await ApiClient.patchMultipartData(
        ApiConstants.updateProfileEndPoint,
        body,
        multipartBody: multipartBody,
      );

      print('📩 Response status: ${response.statusCode}');
      print('📩 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Profile update successful');
        ToastMessageHelper.showToastMessage(
          "Profile updated successfully",
        );
        // Refresh profile data after update
        await getProfile();
        updateProfileLoading(false);
      } else {
        print('❌ Profile update failed: ${response.body["message"]}');
        ToastMessageHelper.showToastMessage(
          "${response.body["message"]}",
          title: 'Failed',
        );
        updateProfileLoading(false);
      }
    } catch (e) {
      print('💥 Error during profile update: $e');
      ToastMessageHelper.showToastMessage(
        "An error occurred: $e",
        title: 'Error',
      );
      updateProfileLoading(false);
    }
  }

  // ── Timezone Update ──────────────────────────────────────────────────────
  RxBool updateTimezoneLoading = false.obs;

  updateTimezone(String timezone) async {
    updateTimezoneLoading(true);
    try {
      var response = await ApiClient.patchMultipartData(
        ApiConstants.updateProfileEndPoint,
        {"timezone": timezone},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await getProfile();
        ToastMessageHelper.showToastMessage("Timezone updated");
      } else {
        ToastMessageHelper.showToastMessage(
          "${response.body["message"]}",
          title: 'Failed',
        );
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage("Error: $e", title: 'Error');
    }
    updateTimezoneLoading(false);
  }

  // ── App Settings (Admin) ─────────────────────────────────────────────────
  RxBool appSettingsLoading = false.obs;
  RxBool gstEnabled = false.obs;
  RxDouble gstRate = 9.0.obs;

  getAppSettings() async {
    appSettingsLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.appSettingsEndPoint);
      if (response.statusCode == 200) {
        final attrs = response.body['data']?['attributes'];
        if (attrs != null) {
          gstEnabled.value = attrs['gst']?['enabled'] ?? false;
          gstRate.value = (attrs['gst']?['rate'] ?? 9).toDouble();
        }
      }
    } catch (_) {}
    appSettingsLoading(false);
  }

  updateAppSettings({required bool enabled, required double rate}) async {
    try {
      var response = await ApiClient.putData(
        ApiConstants.appSettingsEndPoint,
        {"gst": {"enabled": enabled, "rate": rate}},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        gstEnabled.value = enabled;
        gstRate.value = rate;
        ToastMessageHelper.showToastMessage(
            "GST ${enabled ? 'enabled' : 'disabled'}");
      } else {
        ToastMessageHelper.showToastMessage(
          "${response.body["message"]}",
          title: 'Failed',
        );
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage("Error: $e", title: 'Error');
    }
  }

  // Privacy Policy
  RxBool getPrivacyPolicyLoading = false.obs;
  Rx<String> privacyPolicyContent = ''.obs;

  getPrivacyPolicy() async {
    getPrivacyPolicyLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.privacyPolicyEndPoint);

      if (response.statusCode == 200) {
        if (response.body['data'] != null &&
            response.body['data']['attributes'] != null &&
            (response.body['data']['attributes'] as List).isNotEmpty) {
          privacyPolicyContent.value = response.body['data']['attributes'][0]['content'] ?? '';
        } else {
          privacyPolicyContent.value = 'No privacy policy content available.';
        }
        getPrivacyPolicyLoading(false);
      } else {
        getPrivacyPolicyLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to fetch privacy policy: ${response.body['message'] ?? 'Unknown error'}",
          title: 'Error',
        );
      }
    } catch (e) {
      getPrivacyPolicyLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred while fetching privacy policy: $e",
        title: 'Error',
      );
    }
  }

  // Terms & Conditions
  RxBool getTermsConditionsLoading = false.obs;
  Rx<String> termsConditionsContent = ''.obs;

  getTermsConditions() async {
    getTermsConditionsLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.termsConditionsEndPoint);

      if (response.statusCode == 200) {
        if (response.body['data'] != null &&
            response.body['data']['attributes'] != null &&
            (response.body['data']['attributes'] as List).isNotEmpty) {
          termsConditionsContent.value = response.body['data']['attributes'][0]['content'] ?? '';
        } else {
          termsConditionsContent.value = 'No terms and conditions content available.';
        }
        getTermsConditionsLoading(false);
      } else {
        getTermsConditionsLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to fetch terms and conditions: ${response.body['message'] ?? 'Unknown error'}",
          title: 'Error',
        );
      }
    } catch (e) {
      getTermsConditionsLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred while fetching terms and conditions: $e",
        title: 'Error',
      );
    }
  }

  // About Us
  RxBool getAboutUsLoading = false.obs;
  Rx<String> aboutUsContent = ''.obs;

  getAboutUs() async {
    getAboutUsLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.aboutUsEndPoint);

      if (response.statusCode == 200) {
        if (response.body['data'] != null &&
            response.body['data']['attributes'] != null &&
            (response.body['data']['attributes'] as List).isNotEmpty) {
          aboutUsContent.value = response.body['data']['attributes'][0]['content'] ?? '';
        } else {
          aboutUsContent.value = 'No about us content available.';
        }
        getAboutUsLoading(false);
      } else {
        getAboutUsLoading(false);
        ToastMessageHelper.showToastMessage(
          "Failed to fetch about us: ${response.body['message'] ?? 'Unknown error'}",
          title: 'Error',
        );
      }
    } catch (e) {
      getAboutUsLoading(false);
      ToastMessageHelper.showToastMessage(
        "An error occurred while fetching about us: $e",
        title: 'Error',
      );
    }
  }





  RxBool helpSupportLoading = false.obs;

  helpSupport({
    String? title,
    String? description,
    File? files,
    required String screenType,
  }) async {
    helpSupportLoading(true);

    var body = {
      "title": title ?? "",
      "description": description ?? "",
    };


    List<MultipartBody>? multipartBody;
    if (files != null) {
      multipartBody = [MultipartBody("image", files)];
    }

    try {
      var response = await ApiClient.patchMultipartData(
        ApiConstants.helpSupportEndPoint,
        body,
        multipartBody: multipartBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessageHelper.showToastMessage(
          "Help Support successfully",
        );


        helpSupportLoading(false);
      } else {
        ToastMessageHelper.showToastMessage(
          "${response.body["message"]}",
          title: 'Failed',
        );
        helpSupportLoading(false);
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        "An error occurred: $e",
        title: 'Error',
      );
      helpSupportLoading(false);
    }
  }






}

