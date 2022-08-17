import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/config/routes/app_routes.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/presentation/cubit/firestoreUserInfoCubit/myPersonalInfo/my_personal_info_bloc.dart';
import 'package:instagram/presentation/pages/messages/ringing_page.dart';
import 'package:instagram/presentation/screens/mobile_screen_layout.dart';

class PopupCalling extends StatefulWidget {
  final String userId;

  const PopupCalling(
    this.userId, {
    Key? key,
  }) : super(key: key);

  @override
  State<PopupCalling> createState() => _PopupCallingState();
}

class _PopupCallingState extends State<PopupCalling> {
  bool isHeMoved = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyPersonalInfoBloc, MyPersonalInfoState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state is MyPersonalInfoLoaded &&
              !amICalling &&
              state.myPersonalInfoInReelTime.channelId.isNotEmpty) {
            if (!isHeMoved) {
              pushToPage(context,
                  page: CallingRingingPage(
                      channelId: state.myPersonalInfoInReelTime.channelId,
                      clearMoving: clearMoving),
                  withoutRoot: false);
              isHeMoved = true;
            }
          }
        });
        return MobileScreenLayout(widget.userId);
      },
    );
  }

  clearMoving() {
    isHeMoved = false;
  }
}