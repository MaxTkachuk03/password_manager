part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {}

class YubiKeyConnected extends AuthenticationState {
  final Map<String, dynamic> yubiKeyInfo;

  const YubiKeyConnected(this.yubiKeyInfo);

  @override
  List<Object> get props => [yubiKeyInfo];
}

class YubiKeyDisconnected extends AuthenticationState {}

class TOTPGenerated extends AuthenticationState {
  final String totpCode;

  const TOTPGenerated(this.totpCode);

  @override
  List<Object> get props => [totpCode];
}

class HardwareConfirmationSuccess extends AuthenticationState {}

class AuthenticationError extends AuthenticationState {
  final String message;

  const AuthenticationError(this.message);

  @override
  List<Object> get props => [message];
}