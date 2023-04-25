
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:meta/meta.dart';

part 'page_event.dart';

part 'page_state.dart';

class PageBloc extends Bloc<PageEvent, PageState> {
  PageBloc() : super(PageCurrentState()) {
    on<PageEvent>((event, emit) {});
    on<ChangePageEvent>((event, emit) {
      emit(PageCurrentState(currentPageIndex: event.screenIndex));
    }, transformer: sequential());
  }
}
