import 'package:colibri/core/common/api/api_constants.dart';
import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/pagination/custom_pagination.dart';
import 'package:colibri/features/posts/domain/usecases/get_followers_use_case.dart';
import 'package:colibri/features/profile/data/models/request/profile_posts_model.dart';
import 'package:colibri/features/profile/domain/entity/follower_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class FollowerPagination extends CustomPagination<FollowerEntity>{
  final GetFollowersUseCase  getFollowersUseCase;
  String userId;
  FollowerPagination(this.getFollowersUseCase);
  @override
  Future<Either<Failure, List<FollowerEntity>>> getItems(int pageKey) async{
    return getFollowersUseCase(PostCategoryModel(pageKey.toString(),null,userId));
  }

  @override
  FollowerEntity getLastItemWithoutAd(List<FollowerEntity> item) {
    return item[item.length-1];
  }

  @override
  int getNextKey(FollowerEntity item) {
    return item.offsetId;
  }

  @override
  bool isLastPage(List<FollowerEntity> item) {

    return commonLastPage(item);
  }

  @override
  onClose() {
    super.onClose();
    pagingController.dispose();
  }

}