import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'register_page_event.dart';
part 'register_page_state.dart';

class RegisterPageBloc extends Bloc<RegisterPageEvent, RegisterPageState> {
  RegisterPageBloc() : super(RegisterPageInitial()) {
    on<RegisterPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
