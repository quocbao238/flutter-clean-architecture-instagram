import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/core/functions/date_of_now.dart';
import 'package:instagram/core/resources/assets_manager.dart';
import 'package:instagram/core/resources/color_manager.dart';
import 'package:instagram/core/resources/strings_manager.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/core/utility/injector.dart';
import 'package:instagram/data/models/story.dart';
import 'package:instagram/data/models/user_personal_info.dart';
import 'package:instagram/presentation/customPackages/story_view/sory_controller.dart';
import 'package:instagram/presentation/customPackages/story_view/story_view.dart';
import 'package:instagram/presentation/customPackages/story_view/utils.dart';
import 'package:instagram/presentation/widgets/instagram_story_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryPage extends StatefulWidget {
  final UserPersonalInfo user;
  final List<UserPersonalInfo> storiesOwnersInfo;
  final String hashTag;

  const StoryPage({
    required this.user,
    required this.storiesOwnersInfo,
    this.hashTag = "",
    Key? key,
  }) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late PageController controller;

  @override
  void initState() {
    super.initState();

    final initialPage = widget.storiesOwnersInfo.indexOf(widget.user);
    controller = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.black,
      body: SafeArea(
        child: InstagramStorySwipe(
          controller: controller,
          children: widget.storiesOwnersInfo
              .map((user) => StoryWidget(
                    storiesOwnersInfo: widget.storiesOwnersInfo,
                    user: user,
                    controller: controller,
                    hashTag: widget.hashTag,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class StoryWidget extends StatefulWidget {
  final UserPersonalInfo user;
  final PageController controller;
  final List<UserPersonalInfo> storiesOwnersInfo;
  final String hashTag;

  const StoryWidget({
    Key? key,
    required this.user,
    required this.storiesOwnersInfo,
    required this.controller,
    required this.hashTag,
  }) : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  final SharedPreferences _sharePrefs = injector<SharedPreferences>();

  bool shownThem = true;
  final storyItems = <StoryItem>[];
  late StoryController controller;
  double opacityLevel = 1.0;
  Story? date;

  void addStoryItems() {
    for (final story in widget.user.storiesInfo!) {
      switch (story.isThatImage) {
        case true:
          storyItems.add(StoryItem.inlineImage(
            roundedBottom: false,
            roundedTop: false,
            url: story.storyUrl,
            controller: controller,
            caption: Text(story.caption),
            duration: const Duration(
              milliseconds: 5000,
            ),
          ));
          break;
        case false:
          storyItems.add(
            StoryItem.text(
              title: story.caption,
              backgroundColor: Colors.black,
              duration: const Duration(
                milliseconds: 5000,
              ),
            ),
          );
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    controller = StoryController();
    addStoryItems();
    date = widget.user.storiesInfo![0];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleCompleted() async {
    _sharePrefs.setBool(widget.user.userId, true);

    widget.controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    final currentIndex = widget.storiesOwnersInfo.indexOf(widget.user);
    final isLastPage = widget.storiesOwnersInfo.length - 1 == currentIndex;

    if (isLastPage) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onLongPressStart: (e) {
                setState(() {
                  controller.pause();
                  opacityLevel = 0;
                });
              },
              onLongPressEnd: (e) {
                setState(() {
                  opacityLevel = 1;
                  controller.play();
                });
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Material(
                    type: MaterialType.transparency,
                    child: StoryView(
                      inline: true,
                      opacityLevel: opacityLevel,
                      progressPosition: ProgressPosition.top,
                      storyItems: storyItems,
                      controller: controller,
                      onComplete: handleCompleted,
                      onVerticalSwipeComplete: (direction) {
                        if (direction == Direction.down ||
                            direction == Direction.up) {
                          Navigator.maybePop(context);
                        }
                      },
                      onStoryShow: (storyItem) {
                        final index = storyItems.indexOf(storyItem);
                        final isLastPage = storyItems.length - 1 == index;
                        if (isLastPage) {
                          _sharePrefs.setBool(widget.user.userId, true);
                        }
                        if (index > 0) {
                          setState(() {
                            date = widget.user.storiesInfo![index];
                          });
                        }
                      },
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: opacityLevel,
                    duration: const Duration(milliseconds: 250),
                    child: ProfileWidget(
                      user: widget.user,
                      storyInfo: date!,
                      hashTag: widget.hashTag,
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: opacityLevel,
                    duration: const Duration(milliseconds: 250),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(15.0),
                        child: widget.user.userId == myPersonalId
                            ? const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 25,
                              )
                            : Row(children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35),
                                      border: Border.all(
                                        color: Colors
                                            .white, //                   <--- border color
                                        width: 0.5,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    height: 40,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 8.0, end: 20),
                                      child: Center(
                                        child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          cursorColor: Colors.teal,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          onTap: () {
                                            setState(() {
                                              controller.pause();
                                            });
                                          },
                                          showCursor: true,
                                          maxLines: null,
                                          decoration:
                                              const InputDecoration.collapsed(
                                                  hintText: StringsManager
                                                      .sendMassage,
                                                  border: InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey)),
                                          autofocus: false,
                                          cursorWidth: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 25),
                                SvgPicture.asset(
                                  IconsAssets.loveIcon,
                                  width: .5,
                                  color: Colors.white,
                                  height: 25,
                                ),
                                const SizedBox(width: 25),
                                SvgPicture.asset(
                                  IconsAssets.send2Icon,
                                  color: Colors.white,
                                  height: 23,
                                ),
                              ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileWidget extends StatelessWidget {
  final UserPersonalInfo user;
  final Story storyInfo;
  final String hashTag;

  const ProfileWidget({
    required this.user,
    required this.storyInfo,
    required this.hashTag,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsetsDirectional.only(
              start: 16, end: 16, top: 20, bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (hashTag.isEmpty) ...[
                buildCircleAvatar()
              ] else ...[
                Hero(
                  tag: hashTag,
                  child: buildCircleAvatar(),
                ),
              ],
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 5),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      DateOfNow.commentsDateOfNow(storyInfo.datePublished),
                      style: const TextStyle(color: Colors.white38),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );

  CircleAvatar buildCircleAvatar() {
    return CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(user.profileImageUrl),
    );
  }
}
