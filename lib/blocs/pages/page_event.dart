part of 'page_bloc.dart';

@immutable
abstract class PageEvent {

}

class ChangePageEvent extends PageEvent {
  final int screenIndex;

  ChangePageEvent({required this.screenIndex});
}
