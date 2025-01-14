import 'package:colibri/core/common/api/api_constants.dart';
import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/pagination/custom_pagination.dart';
import 'package:colibri/features/feed/domain/entity/post_entity.dart';
import 'package:colibri/features/posts/presentation/bloc/like_unlike_mixin.dart';
import 'package:colibri/features/profile/data/models/request/profile_posts_model.dart';
import 'package:colibri/features/profile/domain/usecase/get_profile_posts.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfilePostPagination extends CustomPagination<PostEntity> with PostInteractionMixinOnCustomPagination{

  final GetProfilePostsUseCase getProfilePostsUseCase;
  // String userId;


  ProfilePostPagination(this.getProfilePostsUseCase);

  @override
  Future<Either<Failure, List<PostEntity>>> getItems(int pageKey) async{
    // return await getProfilePostsUseCase(PostCategoryModel(pageKey.toString(),PostCategory.POSTS,userId));
  }

  @override
  PostEntity getLastItemWithoutAd(List<PostEntity> item) {
    if(item.last.isAdvertisement)return item[item.length-2];
    return item.last;
  }

  @override
  int getNextKey(PostEntity item) {
    return item.offSetId??0;
  }

  @override
  bool isLastPage(List<PostEntity> item) {
    if(item.last.isAdvertisement&&item.length==ApiConstants.pageSize+1)return false;
    else if(!item.last.isAdvertisement&&item.length==ApiConstants.pageSize)return false;
    return true;
  }

  @override
  onClose() {
    super.onClose();
    pagingController.dispose();
  }



}