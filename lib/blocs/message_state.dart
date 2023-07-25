part of 'message_cubit.dart';

@immutable
abstract class MessageState {}

class MessageInitialState extends MessageState {}

class MessageLoadingState extends MessageState {}

class MessageLoadedState extends MessageState {}

class MessageErrorState extends MessageState {
  final String message;
  MessageErrorState(this.message);
}

class NoMessageState extends MessageState {}
