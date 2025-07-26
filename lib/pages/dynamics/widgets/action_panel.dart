// 操作栏
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/dynamics.dart';
import 'package:PiliPalaX/models/dynamics/result.dart';
import 'package:PiliPalaX/pages/dynamics/index.dart';
import 'package:PiliPalaX/utils/feed_back.dart';

class ActionPanel extends StatefulWidget {
  const ActionPanel({
    super.key,
    this.item,
  });
  // ignore: prefer_typing_uninitialized_variables
  final item;

  @override
  State<ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  final DynamicsController _dynamicsController = Get.put(DynamicsController());
  late ModuleStatModel stat;
  bool isProcessing = false;
  void Function()? handleState(Future Function() action) {
    return isProcessing
        ? null
        : () async {
            setState(() => isProcessing = true);
            await action();
            setState(() => isProcessing = false);
          };
  }

  @override
  void initState() {
    super.initState();
    stat = widget.item!.modules.moduleStat;
  }

  // 动态点赞
  Future onLikeDynamic() async {
    feedBack();
    var item = widget.item!;
    String dynamicId = item.idStr!;
    // 1 已点赞 2 不喜欢 0 未操作
    Like like = item.modules.moduleStat.like;
    int count = like.count == '点赞' ? 0 : int.parse(like.count ?? '0');
    bool status = like.status!;
    int up = status ? 2 : 1;
    var res = await DynamicsHttp.likeDynamic(dynamicId: dynamicId, up: up);
    if (res['status']) {
      SmartDialog.showToast(!status ? '点赞成功' : '取消赞');
      if (up == 1) {
        item.modules.moduleStat.like.count = (count + 1).toString();
        item.modules.moduleStat.like.status = true;
      } else {
        if (count == 1) {
          item.modules.moduleStat.like.count = '点赞';
        } else {
          item.modules.moduleStat.like.count = (count - 1).toString();
        }
        item.modules.moduleStat.like.status = false;
      }
      setState(() {});
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).colorScheme.outline;
    var primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: TextButton.icon(
            onPressed: () {
                SmartDialog.showToast('暂不支持');
            },
            icon: const Icon(
              FontAwesomeIcons.shareFromSquare,
              size: 16,
              semanticLabel: "转发",
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              foregroundColor: Theme.of(context).colorScheme.outline,
            ),
            label: Text(stat.forward!.count ?? ''),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextButton.icon(
            onPressed: () => _dynamicsController.pushDetail(widget.item, 1,
                action: 'comment'),
            icon: const Icon(
              FontAwesomeIcons.comment,
              size: 16,
              semanticLabel: "评论",
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              foregroundColor: Theme.of(context).colorScheme.outline,
            ),
            label: Text(stat.comment!.count ?? ''),
          ),
        ),
        Expanded(
          flex: 1,
          child: TextButton.icon(
            onPressed: handleState(onLikeDynamic),
            icon: Icon(
              stat.like!.status!
                  ? FontAwesomeIcons.solidThumbsUp
                  : FontAwesomeIcons.thumbsUp,
              size: 16,
              color: stat.like!.status! ? primary : color,
              semanticLabel: stat.like!.status! ? "已赞": "点赞",
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              foregroundColor: Theme.of(context).colorScheme.outline,
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                stat.like!.count ?? '',
                key: ValueKey<String>(stat.like!.count ?? '点赞'),
                style: TextStyle(
                  color: stat.like!.status! ? primary : color,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
