part of 'fcm_cubit.dart';

@immutable
abstract class FcmState {}

class FcmInitial extends FcmState {}

class FcmLoadingState extends FcmState {}

class FcmLoadedState extends FcmState {}

class FcmErrorState extends FcmState {
  final String message;
  FcmErrorState(this.message);
}

class NoFcmState extends FcmState {}
