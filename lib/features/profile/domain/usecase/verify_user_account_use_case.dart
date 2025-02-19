import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/usecase.dart';
import 'package:colibri/features/profile/data/models/request/verify_request_model.dart';
import 'package:colibri/features/profile/domain/repo/profile_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class VerifyUserAccountUseCase extends UseCase<dynamic,VerifyRequestModel>{
  final ProfileRepo profileRepo;

  VerifyUserAccountUseCase(this.profileRepo);
  @override
  Future<Either<Failure, dynamic>> call(VerifyRequestModel params) {
    return profileRepo.verifyUserAccount(params);
  }

}