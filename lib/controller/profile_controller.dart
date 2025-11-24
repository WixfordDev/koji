import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../../services/api_client.dart';
import '../../../services/api_constants.dart';
import '../models/admin-model/profile_model.dart';


class ProfileController extends GetxController {

  RxBool getProfileLoading = false.obs;
  Rx<ProfileModel> profile = ProfileModel().obs;

  getProfile() async {
    getProfileLoading(true);
    try {
      var response = await ApiClient.getData(ApiConstants.getTaskSummaryEndPoint);

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



}

