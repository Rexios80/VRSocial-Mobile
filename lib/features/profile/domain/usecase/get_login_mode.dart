import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/usecase.dart';
import 'package:colibri/features/profile/domain/entity/setting_entity.dart';
import 'package:colibri/features/profile/domain/repo/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetLoginMode extends UseCase<bool,Unit>{
  final ProfileRepo profileRepo;

  GetLoginMode(this.profileRepo);
  @override
  Future<Either<Failure, bool>> call(Unit params) {
    return profileRepo.getLoginMode();
  }

}