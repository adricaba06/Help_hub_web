import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'create_opportunity_form_page_event.dart';
part 'create_opportunity_form_page_state.dart';

class CreateOpportunityFormPageBloc extends Bloc<CreateOpportunityFormPageEvent, CreateOpportunityFormPageState> {
  CreateOpportunityFormPageBloc() : super(CreateOpportunityFormPageInitial()) {
    on<CreateOpportunityFormPageEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
