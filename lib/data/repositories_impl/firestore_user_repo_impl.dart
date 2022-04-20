import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instegram/data/datasourses/remote/firebase_storage.dart';
import 'package:instegram/data/models/massage.dart';
import 'package:instegram/data/models/specific_users_info.dart';
import 'package:instegram/data/models/user_personal_info.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasourses/remote/firestore_user_info.dart';

class FirebaseUserRepoImpl implements FirestoreUserRepository {
  @override
  Future<void> addNewUser(UserPersonalInfo newUserInfo) async {
    try {
      return await FirestoreUser.createUser(newUserInfo);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<UserPersonalInfo> getPersonalInfo(String userId) async {
    try {
      return await FirestoreUser.getUserInfo(userId);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<UserPersonalInfo> updateUserInfo(
      {required UserPersonalInfo userInfo}) async {
    try {
      await FirestoreUser.updateUserInfo(userInfo);
      return getPersonalInfo(userInfo.userId);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<UserPersonalInfo> updateUserPostsInfo(
      {required String userId, required String postId}) async {
    try {
      await FirestoreUser.updateUserPosts(userId: userId, postId: postId);
      return await getPersonalInfo(userId);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage(
      {required File photo,
      required String userId,
      required String previousImageUrl}) async {
    try {
      String imageUrl =
          await FirebaseStoragePost.uploadFile(photo, 'personalImage');
      await FirestoreUser.updateProfileImage(
          imageUrl: imageUrl, userId: userId);
      await FirebaseStoragePost.deleteImageFromStorage(previousImageUrl);
      return imageUrl;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<FollowersAndFollowingsInfo> getFollowersAndFollowingsInfo(
      {required List<dynamic> followersIds,
      required List<dynamic> followingsIds}) async {
    try {
      List<UserPersonalInfo> followersInfo =
          await FirestoreUser.getSpecificUsersInfo(followersIds);
      List<UserPersonalInfo> followingsInfo =
          await FirestoreUser.getSpecificUsersInfo(followingsIds);
      return FollowersAndFollowingsInfo(
          followersInfo: followersInfo, followingsInfo: followingsInfo);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<void> followThisUser(
      String followingUserId, String myPersonalId) async {
    try {
      return await FirestoreUser.followThisUser(followingUserId, myPersonalId);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<void> removeThisFollower(
      String followingUserId, String myPersonalId) async {
    try {
      return await FirestoreUser.removeThisFollower(
          followingUserId, myPersonalId);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<List<UserPersonalInfo>> getSpecificUsersInfo(
      {required List<dynamic> usersIds}) async {
    try {
      return await FirestoreUser.getSpecificUsersInfo(usersIds);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<UserPersonalInfo?> getUserFromUserName(
      {required String userName}) async {
    try {
      return await FirestoreUser.getUserFromUserName(userName: userName);
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Future<Massage> sendMassage(
      {required Massage massageInfo, required String pathOfPhoto}) async {
    try {
      if(pathOfPhoto.isNotEmpty){
        String imageUrl =
        await FirebaseStoragePost.uploadFile(File(pathOfPhoto), "massagesImages");
        massageInfo.imageUrl = imageUrl;
      }

      Massage myMassageInfo = await FirestoreUser.sendMassage(
          userId: massageInfo.senderId,
          chatId: massageInfo.receiverId,
          massage: massageInfo);
      await FirestoreUser.sendMassage(
          userId: massageInfo.receiverId,
          chatId: massageInfo.senderId,
          massage: massageInfo);

      return myMassageInfo;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getMassages(
      {required String receiverId}) async* {
    // try {
    yield* FirestoreUser.getMassages(receiverId: receiverId);
    // }
    // catch (e) {
    //   yield* Stream.error(e.toString());
    // }
  }
}