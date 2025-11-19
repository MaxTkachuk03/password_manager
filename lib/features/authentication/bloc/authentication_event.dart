part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class CheckYubiKeyConnection extends AuthenticationEvent {}

class GenerateTOTP extends AuthenticationEvent {}

class PerformHardwareConfirmation extends AuthenticationEvent {}

class Authenticate extends AuthenticationEvent {}