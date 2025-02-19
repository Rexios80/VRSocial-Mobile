import 'package:bloc/bloc.dart';
import 'package:colibri/core/common/stream_validators.dart';
import 'package:colibri/core/common/uistate/common_ui_state.dart';
import 'package:colibri/core/common/validators.dart';
import 'package:colibri/features/authentication/domain/usecase/reset_password_use_case.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:colibri/extensions.dart';
import 'package:rxdart/rxdart.dart';
part 'reset_password_state.dart';

@injectable
class ResetPasswordCubit extends Cubit<CommonUIState> {
  final emailValidator=FieldValidators(null,null);
  Stream<bool> get enableButton=>Rx.combineLatest<String,bool>([emailValidator.stream], (values) => values[0].isNotEmpty);
  final ResetPasswordUseCase resetPasswordUseCase;
  ResetPasswordCubit(this.resetPasswordUseCase) : super(const CommonUIState.initial()){
    enableButton.listen((event) {
      print("value is $event");
    });
  }

  resetPassword()async{
    if(emailValidator.isEmpty){
      emailValidator.onChange("");
    }
    else {
      emit(const CommonUIState.loading());
      var response=await resetPasswordUseCase(emailValidator.text.trim());
      emit(response.fold(
              (l) => CommonUIState.error(l.errorMessage),
              (r) => const CommonUIState.success("Password link sent successfully")));
    }
  }
}
