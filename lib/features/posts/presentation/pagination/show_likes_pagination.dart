import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/mixins/follow_unfollow_mixin.dart';
import 'package:colibri/core/common/pagination/custom_pagination.dart';
import 'package:colibri/features/posts/data/model/request/like_request_model.dart';
import 'package:colibri/features/posts/domain/usecases/get_likes_use_case.dart';
import 'package:colibri/features/profile/domain/entity/follower_entity.dart';
import 'package:colibri/features/profile/domain/usecase/follow_unfollow_use_case.dart';
import 'package:colibri/features/search/domain/entity/people_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:infinite_scroll_pagination/src/core/paging_controller.dart';
import 'package:injectable/injectable.dart';

@injectable
class ShowLikesPagination extends CustomPagination<PeopleEntity> with FollowUnFollowMixin{
  final GetLikesUseCase getLikesUseCase;
  final FollowUnFollowUseCase followUnFollowUseCaseMixin;

  ShowLikesPagination(this.getLikesUseCase, this.followUnFollowUseCaseMixin);

  String _postId;

  setPostID(String value)=>_postId=value;

  @override
  Future<Either<Failure, List<PeopleEntity>>> getItems(int pageKey) async => await getLikesUseCase(LikesRequestModel(postId: _postId, offsetId: pageKey.toString()));

  @override
  PeopleEntity getLastItemWithoutAd(List<PeopleEntity> item) => item.last;

  @override
  int getNextKey(PeopleEntity item) => item.offsetId;

  @override
  bool isLastPage(List<PeopleEntity> item) => commonLastPage(item);

  @override
  PagingController<int, PeopleEntity> get pagingControllerMixin => pagingController;


}