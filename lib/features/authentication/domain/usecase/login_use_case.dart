import 'dart:collection';

import 'package:colibri/core/common/failure.dart';
import 'package:colibri/core/common/usecase.dart';
import 'package:colibri/features/authentication/domain/repo/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUseCase extends UseCase<dynamic,HashMap<String,dynamic>>{
  final AuthRepo authRepo;

  LoginUseCase(this.authRepo);
  @override
  Future<Either<Failure, dynamic>> call(HashMap<String, dynamic> params ) {
    return authRepo.signIn(params);
  }

}