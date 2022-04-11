import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instegram/data/models/post.dart';
import 'package:instegram/domain/usecases/postUseCase/get_all_posts.dart';
import 'package:instegram/domain/usecases/postUseCase/get_post_info.dart';
import '../../../domain/usecases/postUseCase/create_post.dart';
part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final CreatePostUseCase _createPostUseCase;
  final GetPostsInfoUseCase _getPostsInfoUseCase;
  final GetAllPostsInfoUseCase _getAllPostInfoUseCase;

  String? postId;
  List<Post>? myPostsInfo;
  List<Post>? userPostsInfo;

  List<Post>? allPostsInfo;

  PostCubit(this._createPostUseCase, this._getPostsInfoUseCase,
      this._getAllPostInfoUseCase)
      : super(CubitPostLoading());

  static PostCubit get(BuildContext context) => BlocProvider.of(context);

  Future<String?> createPost(
      Post postInfo, File photo) async {
    emit(CubitPostLoading());
    await _createPostUseCase
        .call(params: [postInfo, photo]).then((postId) {
      this.postId = postId;
      emit(CubitPostLoaded());
    }).catchError((e) {
      emit(CubitPostFailed(e));
    });
    return postId;
  }

  Future<List<Post>?> getPostsInfo(
      {required List<dynamic> postIds, required bool isThatForMyPosts}) async {
    List<Post>w=[];
    emit(CubitPostLoading());
    await _getPostsInfoUseCase.call(params: postIds).then((postsInfo) {
      if (isThatForMyPosts) {
        myPostsInfo = postsInfo;

        emit(CubitMyPersonalPostsLoaded(postsInfo));
      } else {
        userPostsInfo = postsInfo;
        emit(CubitPostsInfoLoaded(postsInfo));
      }
      w=postsInfo;
    }).catchError((e) {
      emit(CubitPostFailed(e));
    });
    return w;
  }

  Future<List<Post>?> getAllPostInfo() async {
    emit(CubitPostLoading());
    await _getAllPostInfoUseCase.call(params: null).then((allPostsInfo) {
      this.allPostsInfo = allPostsInfo;
      emit(CubitAllPostsLoaded(allPostsInfo));
    }).catchError((e) {
      emit(CubitPostFailed(e));
    });
    return myPostsInfo;
  }

}