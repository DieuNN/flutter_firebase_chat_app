part of 'page_bloc.dart';

@immutable
abstract class PageState {}

class PageCurrentState extends PageState {
  final int currentPageIndex;

  PageCurrentState({this.currentPageIndex = 0});
}
