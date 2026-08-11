import 'package:equatable/equatable.dart';

import '../data/call_model.dart';

sealed class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

final class CallIdle extends CallState {
  const CallIdle();
}

final class CallOutgoing extends CallState {
  const CallOutgoing(this.call, {this.isMuted = false, this.isSpeakerOn = false});

  final CallModel call;
  final bool isMuted;
  final bool isSpeakerOn;

  @override
  List<Object?> get props => [call, isMuted, isSpeakerOn];
}

final class CallIncoming extends CallState {
  const CallIncoming(this.call);

  final CallModel call;

  @override
  List<Object?> get props => [call];
}

final class CallConnecting extends CallState {
  const CallConnecting(this.call, {this.isMuted = false, this.isSpeakerOn = false});

  final CallModel call;
  final bool isMuted;
  final bool isSpeakerOn;

  @override
  List<Object?> get props => [call, isMuted, isSpeakerOn];
}

final class CallConnected extends CallState {
  const CallConnected(this.call, {this.isMuted = false, this.isSpeakerOn = false});

  final CallModel call;
  final bool isMuted;
  final bool isSpeakerOn;

  @override
  List<Object?> get props => [call, isMuted, isSpeakerOn];
}

final class CallFailure extends CallState {
  const CallFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
