import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitialState()) {
    on<AppEvent>((event, emit) {});

    on<AppInitialEvent>((event, emit) async {
      emit(AppInitializingState());
      try {
        await Firebase.initializeApp();
      } catch (e) {
        log(e.toString());
        emit(AppInitialFailureState());
      }
      User? user = FirebaseAuth.instance.currentUser;
      emit(AppInitialSuccessState(user: user));
    }, transformer: sequential());
  }
}
