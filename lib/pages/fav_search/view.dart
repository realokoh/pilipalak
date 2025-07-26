import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/skeleton/video_card_h.dart';
import 'package:PiliPalaX/common/widgets/no_data.dart';
import 'package:PiliPalaX/pages/fav_detail/widget/fav_video_card.dart';

import 'controller.dart';

class FavSearchPage extends StatefulWidget {
  const FavSearchPage({super.key});

  @override
  State<FavSearchPage> createState() => _FavSearchPageState();
}

class _FavSearchPageState extends State<FavSearchPage> {
  final FavSearchController _favSearchCtr = Get.put(FavSearchController());
  late ScrollController scrollController;
  late int searchType;

  @override
  void initState() {
    super.initState();
    searchType = int.parse(Get.parameters['searchType']!);
    scrollController = _favSearchCtr.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300) {
          EasyThrottle.throttle('fav', const Duration(seconds: 1), () {
            _favSearchCtr.onLoad();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        actions: [
          IconButton(
              tooltip: '搜索',
              onPressed: () => _favSearchCtr.submit(),
              icon: const Icon(Icons.search_outlined, size: 22)),
          const SizedBox(width: 10)
        ],
        title: Obx(
          () => TextField(
            autofocus: true,
            focusNode: _favSearchCtr.searchFocusNode,
            controller: _favSearchCtr.controller.value,
            textInputAction: TextInputAction.search,
            onChanged: (value) => _favSearchCtr.onChange(value),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: _favSearchCtr.hintText,
              border: InputBorder.none,
              suffixIcon: IconButton(
                tooltip: '清空',
                icon: Icon(
                  Icons.clear,
                  size: 22,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => _favSearchCtr.onClear(),
              ),
            ),
            onSubmitted: (String value) => _favSearchCtr.submit(),
          ),
        ),
      ),
      body: Obx(
        () => _favSearchCtr.loadingStatus.value && _favSearchCtr.favList.isEmpty
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const VideoCardHSkeleton();
                },
              )
            : _favSearchCtr.favList.isNotEmpty
                ? ListView.builder(
                    controller: scrollController,
                    itemCount: _favSearchCtr.favList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _favSearchCtr.favList.length) {
                        return Container(
                          height: MediaQuery.of(context).padding.bottom + 60,
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom),
                        );
                      } else {
                        return FavVideoCardH(
                          videoItem: _favSearchCtr.favList[index],
                          searchType: searchType,
                          callFn: () => searchType != 1
                              ? _favSearchCtr
                                  .onCancelFav(_favSearchCtr.favList[index].id!)
                              : {},
                        );
                      }
                    },
                  )
                : const CustomScrollView(
                    slivers: <Widget>[
                      NoData(),
                    ],
                  ),
      ),
    );
  }
}
