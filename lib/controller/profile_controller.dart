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
    String? address,
    File? file,
    required String screenType,
  }) async {
    updateProfileLoading(true);

    var body = {
      "firstName": firstName ?? "",
      "lastName": lastName ?? "",
      "callingCode": callingCode ?? "",
      "phoneNumber": phoneNumber ?? "",
      "nidNumber": nidNumber ?? "",
      "dateOfBirth": dateOfBirth ?? "", // Fixed typo
      "address": address ?? "",
    };


    List<MultipartBody>? multipartBody;
    if (file != null) {
      multipartBody = [MultipartBody("image", file)];
    }

    try {
      var response = await ApiClient.patchMultipartData(
        ApiConstants.updateProfileEndPoint,
        body,
        multipartBody: multipartBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
          ToastMessageHelper.showToastMessage(
            "Profile updated successfully",
          );


        updateProfileLoading(false);
      } else {
        ToastMessageHelper.showToastMessage(
          "${response.body["message"]}",
          title: 'Failed',
        );
        updateProfileLoading(false);
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        "An error occurred: $e",
        title: 'Error',
      );
      updateProfileLoading(false);
    }
  }


}

