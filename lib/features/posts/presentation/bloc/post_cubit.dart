import 'package:bloc/bloc.dart';
import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/pagination/custom_pagination.dart';
import 'package:colibri/core/common/pagination/pagination_helper.dart';
import 'package:colibri/core/common/pagination/text_model_with_offset.dart';
import 'package:colibri/core/common/uistate/common_ui_state.dart';
import 'package:colibri/core/common/usecase.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/features/feed/domain/usecase/like_unlike_use_case.dart';
import 'package:colibri/features/feed/domain/usecase/repost_use_case.dart';
import 'package:colibri/features/feed/presentation/widgets/feed_widgets.dart';
import 'package:colibri/features/posts/domain/usecases/add_remove_bookmark_use_case.dart';
import 'package:colibri/features/posts/domain/usecases/delete_post_use_case.dart';
import 'package:colibri/features/posts/presentation/bloc/like_unlike_mixin.dart';
import 'package:colibri/features/posts/presentation/pagination/show_likes_pagination.dart';
import 'package:colibri/features/search/domain/usecase/search_people_use_case.dart';
import 'package:colibri/features/search/domain/usecase/search_post_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:colibri/extensions.dart';
part 'post_state.dart';


@injectable
class PostCubit extends PostPaginatonCubit<PostEntity,CommonUIState> with PostSearchingMixin,PostInteractionMixin {

  // use cases
  final AddOrRemoveBookmarkUseCase addOrRemoveBookmarkUseCase;
  final LikeUnlikeUseCase likeUnlikeUseCase;
  final RepostUseCase repostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final SearchPostUseCase searchPostUseCase;

  // pagination
  final ShowLikesPagination showLikesPagination;


  PostCubit(
      this.addOrRemoveBookmarkUseCase,
      this.likeUnlikeUseCase,
      this.repostUseCase,
      this.deletePostUseCase,
      this.searchPostUseCase, this.showLikesPagination) : super(const CommonUIState.initial()){
    // helps to search items from post items
    enableSearch();
  }



  @override
  Future<Either<Failure, List<PostEntity>>> getItems(int pageKey) async => searchPostUseCase(TextModelWithOffset(queryText: searchedText,offset: pageKey.toString()));

  @override
  PostEntity getLastItemWithoutAd(List<PostEntity> item) => item.getItemWithoutAd;

  @override
  int getNextKey(PostEntity item) => item.offSetId??0;

  @override
  bool isLastPage(List<PostEntity> item) => item.isLastPage;

  @override
  Future<void> likeUnlikePost(int index) async{
    var either = await mLikeUnlike(index, likeUnlikeUseCase);
    either.fold((l) {
      emit(CommonUIState.error(l.errorMessage));
      emit(const CommonUIState.initial());
    }, (r) => {

    });
  }

  @override
  Future<void> repost(int index) async {
    await mRepost(index, repostUseCase);
  }

  @override
  Future<void> addOrRemoveBookmark(int index) async{
    await mAddRemoveBookmark(index, addOrRemoveBookmarkUseCase);
  }

  @override
  Future<void> deletePost(int index) async{
    await mDeletePost(index, deletePostUseCase);
  }
  @override
  Future<void> close() {
    disposeMixin();
    pagingController.dispose();
    return super.close();
  }

  @override
  Future onOptionItemSelected(PostOptionsEnum postOptionsEnum, int index) async{
    switch (postOptionsEnum) {

      case PostOptionsEnum.SHOW_LIKES:
        break;
      case PostOptionsEnum.BOOKMARK:
       await addOrRemoveBookmark(index);
        break;
      case PostOptionsEnum.DELETE:
        await deletePost(index);
        break;
    }
  }
}
