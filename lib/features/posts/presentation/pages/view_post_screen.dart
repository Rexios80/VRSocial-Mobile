import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:colibri/core/common/media/media_data.dart';
import 'package:colibri/core/common/uistate/common_ui_state.dart';
import 'package:colibri/core/di/injection.dart';
import 'package:colibri/core/routes/routes.gr.dart';
import 'package:colibri/core/theme/app_icons.dart';
import 'package:colibri/core/theme/colors.dart';
import 'package:colibri/core/theme/images.dart';
import 'package:colibri/core/theme/strings.dart';
import 'package:colibri/core/widgets/MediaOpener.dart';
import 'package:colibri/core/widgets/loading_bar.dart';
import 'package:colibri/core/widgets/media_picker.dart';
import 'package:colibri/core/widgets/thumbnail_widget.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/features/feed/presentation/widgets/create_post_card.dart';
import 'package:colibri/features/feed/presentation/widgets/feed_widgets.dart';
import 'package:colibri/features/feed/presentation/widgets/no_data_found_screen.dart';
import 'package:colibri/features/posts/presentation/bloc/createpost_cubit.dart';
import 'package:colibri/features/posts/presentation/bloc/view_post_cubit.dart';
import 'package:colibri/features/posts/presentation/pages/show_likes_screen.dart';
import 'package:colibri/features/search/presentation/widgets/ThreadedPostItem.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:colibri/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:flutter_timeline/event_item.dart';
// import 'package:flutter_timeline/flutter_timeline.dart';
// import 'package:flutter_timeline/indicator_position.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:timelines/timelines.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ViewPostScreen extends StatefulWidget {
  final int threadID;
  final PostEntity postEntity;
  const ViewPostScreen({Key key, this.threadID, @required this.postEntity}) : super(key: key);

  @override
  _ViewPostScreenState createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  ViewPostCubit viewPostCubit;
  CreatePostCubit createPostCubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    viewPostCubit = getIt<ViewPostCubit>()
      ..getParentPost(widget.threadID.toString());
    createPostCubit = getIt<CreatePostCubit>();
  }

  @override
  Widget build(BuildContext context) {
    context.initScreenUtil();
    return WillPopScope(
      onWillPop: (){
        context.removeFocus();
        if(widget.postEntity==null){
          ExtendedNavigator.root.pop();
        }
        else {
          var item=viewPostCubit.items.firstWhere((element) => element.postId==widget.postEntity.postId);
          ExtendedNavigator.root.pop(item);
        }
        return Future.value(true);
      },
      child: Scaffold(

        appBar: AppBar(

          title: "Post"
              .toSubTitle1(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        body: BlocListener<ViewPostCubit, CommonUIState>(
          cubit: viewPostCubit,
          listener: (_, state) {
            state.maybeWhen(
                orElse: () {},
                error: (e) => context.showSnackBar(message: e, isError: true),
                success: (s) {
                  if (s != null && s is String && s.isNotEmpty) {
                    viewPostCubit.getParentPost(widget.threadID.toString());
                    context.showSnackBar(message: s, isError: false);
                  }
                });
          },
          child: BlocListener<CreatePostCubit, CommonUIState>(
            cubit: createPostCubit,
            listener: (_, state) {
              state.maybeWhen(
                  orElse: () {},
                  error: (e) => context.showSnackBar(message: e, isError: true),
                  success: (s) {
                    if (s is String && s != null && s.isNotEmpty) {
                      viewPostCubit.getParentPost(widget.threadID.toString());
                      context.showSnackBar(message: s, isError: false);
                    }
                  });
            },
            child: BlocBuilder<CreatePostCubit, CommonUIState>(
              cubit: createPostCubit,
              builder: (_, state) => state.when(
                    initial: buildHomeWithStream,
                    success: (s) => buildHomeWithStream(),
                    loading: () => LoadingBar(),
                    error: (e) => Container(
                          child: e.toText,
                        )),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHomeWithStream() => BlocBuilder<ViewPostCubit, CommonUIState>(
      cubit: viewPostCubit,
      builder: (_, state) => state.when(
          initial: () => StreamBuilder<List<PostEntity>>(
              stream: viewPostCubit.parentPostEntity,
              builder: (context, snapshot) {
                if (snapshot.data == null) return Container();
                return StreamBuilder<List<PostEntity>>(
                    stream: viewPostCubit.parentPostEntity,
                    builder: (context, items) => buildHomeScreen(items.data, 5));
              }),
          success: (c) => StreamBuilder<List<PostEntity>>(
              stream: viewPostCubit.parentPostEntity,
              builder: (context, snapshot) {
                if (snapshot.data == null) return Container();
                return StreamBuilder<List<PostEntity>>(
                    stream: viewPostCubit.parentPostEntity,
                    builder: (context, items) => buildHomeScreen(items.data, 5));
              }),
          loading: () => LoadingBar(),
          error: (e) => Center(
                child: e.toSubTitle1(),
              )),
    );

  Widget buildHomeScreen(List<PostEntity> postItems, int size) {
    if (postItems == null) return LoadingBar();
    return Stack(
      overflow: Overflow.visible,
      children: [
        // if there are replies and next or prev
        if (postItems.length > 1) [getTimeLineView(postItems),
        150.toSizedBox
        ].toColumn().makeScrollable(),

        if (postItems.length == 1)
          [
            PostItem(
              postEntity: postItems[0],
              detailedPost: true,
            ),
            40.toSizedBox,
            NoDataFoundScreen(
              title: "No replys yet!",
              buttonVisibility: false,
              icon: const Icon(
                Icons.comment_bank,
                color: AppColors.colorPrimary,
                size: 40,
              ),
              message:
                  "It seems that this publication does not yet have any comments."
                  " In order to respond to this publication from ${postItems[0].name}",
            )
          ].toColumn().makeScrollable(),
        // PostItem(postEntity: postEntity,),

        Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: StreamBuilder<List<MediaData>>(
                          stream: createPostCubit.images,
                          initialData: [],
                          builder: (context, snapshot) => Wrap(
                                runSpacing: 20.0,
                                spacing: 5.0,
                                children: List.generate(
                                  snapshot.data.length,
                                  (index) {
                                    switch (snapshot.data[index].type) {
                                      case MediaTypeEnum.IMAGE:
                                        return ThumbnailWidget (
                                          data: snapshot.data[index],
                                          onCloseTap: () async {
                                            await createPostCubit
                                                .removedFile(index);
                                          },
                                        ).onInkTap (
                                          () {
                                            Navigator.of(context)
                                                .push(CupertinoPageRoute(
                                                    builder: (c) => MediaOpener(
                                                          data: snapshot
                                                              .data[index],
                                                        )));
                                          },
                                        ).toContainer (
                                            width:
                                                context.getScreenWidth * .45);
                                        break;
                                      case MediaTypeEnum.VIDEO:
                                        return Stack (
                                          children: [
                                            ThumbnailWidget (
                                              data: snapshot.data[index],
                                              onCloseTap: () async {
                                                await createPostCubit
                                                    .removedFile(index);
                                              },
                                            ),
                                            const Positioned.fill (
                                                child: Icon(
                                              FontAwesomeIcons.play,
                                              color: Colors.white,
                                              size: 45,
                                            )),
                                          ],
                                        ).toHorizontalPadding(12).onInkTap(() {
                                          Navigator.of(context)
                                              .push(CupertinoPageRoute (
                                                  builder: (c) => MediaOpener(
                                                        data: snapshot
                                                            .data[index],
                                                      )));
                                        });
                                        break;
                                      case MediaTypeEnum.GIF:
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: GiphyWidget(
                                            path: snapshot.data[index].path,
                                            fun: () async {
                                              await createPostCubit
                                                  .removedFile(index);
                                            },
                                          ),
                                        );
                                        break;
                                      case MediaTypeEnum.EMOJI:
                                        return ThumbnailWidget(
                                            data: snapshot.data[index]);
                                        break;
                                      default:
                                        return Container();
                                    }
                                  },
                                )).toContainer()),
                    ),
                    5.toSizedBox,
                    [
                      "Replying to".toCaption(),
                      3.toSizedBoxHorizontal,
                      postItems[0].userName.toSubTitle1(
                        onTapMention: (mention){
                          ExtendedNavigator.root.push(Routes.profileScreen,arguments: ProfileScreenArguments(otherUserId: postItems[0].otherUserId));
                        },
                        fontSize: 14,
                          color: AppColors.colorPrimary,
                          fontWeight: FontWeight.bold)
                    ].toRow().toHorizontalPadding(16),
                    5.toSizedBox,
                    "Reply".toTextField().toStreamBuilder(
                        validators: createPostCubit.postTextValidator),
                    5.toSizedBox,
                    [
                      StreamBuilder<bool>(
                          stream: createPostCubit.imageButton,
                          initialData: true,
                          builder: (context, snapshot) => AppIcons.imageIcon(enabled: snapshot.data)
                                .onInkTap(() async {
                              if (snapshot.data)
                                await openMediaPicker(
                                  context,
                                  (image) {
                                    createPostCubit.addImage(image);
                                    // context.showSnackBar(message: image);
                                  },
                                  mediaType: MediaTypeEnum.IMAGE,
                                );
                            })),
                      20.toSizedBoxHorizontal,
                      StreamBuilder<bool>(
                          stream: createPostCubit.videoButton,
                          initialData: true,
                          builder: (_, snapshot) => AppIcons.videoIcon(enabled: snapshot.data)
                                .onInkTap(() async {
                              if (snapshot.data)
                                await openMediaPicker(context, (video) {
                                  createPostCubit.addVideo(video);
                                }, mediaType: MediaTypeEnum.VIDEO);
                            })),
                      20.toSizedBoxHorizontal,
                      AppIcons.smileIcon.onInkTap(() {
                        showModelSheet(context);
                      }),
                      20.toSizedBoxHorizontal,
                      StreamBuilder<bool>(
                          stream: createPostCubit.gifButton,
                          initialData: true,
                          builder: (context, snapshot) => AppIcons.gifIcon(enabled: snapshot.data)
                                .onInkTap(() async {
                              if (snapshot.data) {
                                final gif = await GiphyPicker.pickGif(
                                    context: context,
                                    apiKey: Strings.giphyApiKey);
                                if (gif?.images?.original?.url != null)
                                  createPostCubit
                                      .addGif(gif?.images?.original?.url);
                              }
                              // context.showModelBottomSheet(GiphyImage.original(gif: gif));
                            })),
                      [
                        "Reply"
                            .toCaption (
                                color: Colors.white,
                                fontWeight: FontWeight.bold)
                            .toMaterialButton(() {
                          createPostCubit.createPost(
                              threadId: widget.threadID.toString());
                        })
                      ]
                          .toRow(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end)
                          .toContainer(height: 30)
                          .toExpanded(),
                    ]
                        .toRow(crossAxisAlignment: CrossAxisAlignment.center)
                        .toSymmetricPadding(12, 8)
                        .toSteamVisibility(KeyboardVisibilityController().onChange)
                  ],
                )
                    .toPadding(4)
                    .box
                    .white
                    .border(color: Colors.black12, width: 1)
                    .make()).toVisibility(true)
      ],
    );
  }

  Widget buildPostItem(PostEntity postEntity, index) => PostItem(
        postEntity: postEntity,
        onTapRepost: () async {
          viewPostCubit.repost(index);
        },
        onLikeTap: () {
          viewPostCubit.likeUnLikePost(index);
        },
        onPostOptionItem: (value) async {
          // if (value == "Bookmark" || value == "UnBookmark") {
          //   await viewPostCubit.addRemoveBook(index);
          // } else if (value == "Delete") {
          //   context.showDeleteDialog(onOkTap: () async {
          //     await viewPostCubit.deletePost(index);
          //   });
          // }
          FocusManager.instance.primaryFocus.unfocus();

          final getOptionsEnum = value.getOptionsEnum;
          switch(getOptionsEnum){

            case PostOptionsEnum.SHOW_LIKES:
              showModalBottomSheet(context: context, builder: (c)=> ShowLikeScreen(postEntity.postId));
              break;
            case PostOptionsEnum.BOOKMARK:
              viewPostCubit.addRemoveBook(index);
              break;
            case PostOptionsEnum.DELETE:

              context.showDeleteDialog(onOkTap: ()async{
                await viewPostCubit.deletePost(index);
              });
              break;
          }

        });

  void showModelSheet(BuildContext context) {
    context.showModelBottomSheet(EmojiPicker (
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.CUPERTINO,
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        print(emoji.emoji);
        // print(emoji.emoji);
        createPostCubit.postTextValidator.textController.text =
            createPostCubit.postTextValidator.text + emoji.emoji;
      },
    ).toContainer(
        height: context.getScreenWidth > 600 ? 400 : 250,
        color: Colors.transparent));
  }

  Widget getTimeLineView(List<PostEntity> postEntity) => Padding(
      padding: const EdgeInsets.all(8.0),
      child: FixedTimeline.tileBuilder(
        builder: TimelineTileBuilder(
            nodePositionBuilder: (c, index) => 0.0,
            indicatorPositionBuilder: (c, index) => 0.0,
            startConnectorBuilder: (c, i) => Container(),
            indicatorBuilder: (c, index) =>
                postEntity[index].isConnected || postEntity[index].isReplyItem
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: postEntity[index]
                            .profileUrl
                            .toRoundNetworkImage(radius: 11),
                      )
                    : Container(),

            //  indicatorBuilder: (c,index)=>
            //      Padding(
            //          padding: const EdgeInsets.only(left:30.0),
            //          child: postEntity[index].profileUrl.toRoundNetworkImage(radius: 11),
            //        ),

            endConnectorBuilder: (c, index) =>
                postEntity[index].isConnected && postEntity[index].isReplyItem
                    ? const Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: SolidLineConnector(),
                      )
                    : Container(),
            itemCount: postEntity.length,
            contentsBuilder: (c, index) {
              final item = postEntity[index];
              return displayItem(item,index);
            }),
        theme: const TimelineThemeData.raw(
            direction: Axis.vertical,
            color: Colors.red,
            nodePosition: 0.0,
            nodeItemOverlap: true,
            indicatorPosition: 0.0,
            indicatorTheme: IndicatorThemeData(
              color: AppColors.placeHolderColor,
              size: 0,
              position: 0,
            ),
            connectorTheme: ConnectorThemeData(
              color: AppColors.placeHolderColor,
            )),
        verticalDirection: VerticalDirection.down,
      ),
    ).toFlexible();

  Widget displayItem(PostEntity item, int index) {
    if(item.showFullDivider)return const Divider(thickness: 2,color: AppColors.sfBgColor,);
        else if(item.parentPostTime.isNotEmpty)return [
      const Divider(thickness: 2,color: AppColors.sfBgColor,),
      item.parentPostTime
          .toCaption(fontWeight: FontWeight.bold)
          .toHorizontalPadding(16),
      const Divider(thickness: 2,color: AppColors.sfBgColor,),
    ].toColumn();
        return PostItem (
          replyCountIncreased: (value) {
            var item=viewPostCubit.items[index];
            if(value)
              viewPostCubit.items[index]=item.copyWith(commentCount: item.commentCount.inc.toString());
            viewPostCubit.changePostEntity(viewPostCubit.items);
          },
          postEntity: item,
          detailedPost: !item.isReplyItem,
          onPostOptionItem: (optionSelected)async{
            FocusManager.instance.primaryFocus.unfocus();

            final getOptionsEnum = optionSelected.getOptionsEnum;
            switch(getOptionsEnum){

              case PostOptionsEnum.SHOW_LIKES:
                showModalBottomSheet(context: context, builder: (c)=> ShowLikeScreen(item.postId));
                break;
              case PostOptionsEnum.BOOKMARK:
                viewPostCubit.addRemoveBook(index);
                break;
              case PostOptionsEnum.DELETE:

                context.showDeleteDialog(onOkTap: ()async{
                  // ExtendedNavigator.root.pop();
                  await viewPostCubit.deletePost(index);
                });
                break;
            }
          },onLikeTap: ()=> viewPostCubit.likeUnLikePost(index)
        ,onTapRepost: ()=>viewPostCubit.repost(index),
        );

  }
}

// helper class which will send data to previous screen
// so to that we can change the data locally and
// no need to call the api again to
// increase like, share, comment count
class ViewPostCallBack extends Equatable{
  final String commentsCount;
  final String repostCount;
  final String likeCount;

  const ViewPostCallBack._({
      @required this.commentsCount,
      @required this.repostCount,
      @required this.likeCount});

  factory ViewPostCallBack.fromPostItem({PostEntity postEntity})=> ViewPostCallBack._(commentsCount: postEntity.commentCount,
        repostCount: postEntity.repostCount, likeCount: postEntity.likeCount);

  @override
  List<String> get props => [commentsCount,repostCount,likeCount];
}