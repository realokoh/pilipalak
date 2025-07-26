import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/user.dart';
import 'package:PiliPalaX/models/user/fav_folder.dart';
import 'package:PiliPalaX/models/user/info.dart';
import 'package:PiliPalaX/utils/storage.dart';

class FavController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  Box userInfoCache = GStorage.userInfo;
  UserInfoData? userInfo;
  int currentPage = 1;
  int pageSize = 10;
  RxBool hasMore = true.obs;

  Future<dynamic> queryFavFolder({type = 'init'}) async {
    userInfo = userInfoCache.get('userInfoCache');
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录'};
    }
    if (!hasMore.value) {
      return;
    }
    var res = await UserHttp.userfavFolder(
      pn: currentPage,
      ps: pageSize,
      mid: userInfo!.mid!,
    );
    if (res['status']) {
      if (type == 'init') {
        favFolderData.value = res['data'];
      } else {
        if (res['data'].list.isNotEmpty) {
          favFolderData.value.list!.addAll(res['data'].list);
          favFolderData.update((val) {});
        }
      }
      hasMore.value = res['data'].hasMore;
      currentPage++;
      if (hasMore.value && type == 'init') {
        queryFavFolder(type: 'onload');
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  Future onLoad() async {
    queryFavFolder(type: 'onload');
  }
}
