part of 'app_bloc.dart';

@immutable
abstract class AppState {}

class AppInitialState extends AppState {}

class AppInitializingState extends AppState {}

class AppInitialSuccessState extends AppState {
  final User? user;

  AppInitialSuccessState({required this.user});
}

class AppInitialFailureState extends AppState {}
