import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:password_manager/core/services/yubikey_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<CheckYubiKeyConnection>(_onCheckYubiKeyConnection);
    on<GenerateTOTP>(_onGenerateTOTP);
    on<PerformHardwareConfirmation>(_onPerformHardwareConfirmation);
    on<Authenticate>(_onAuthenticate);
  }

  Future<void> _onCheckYubiKeyConnection(
    CheckYubiKeyConnection event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    try {
      final isConnected = await YubiKeyService.isYubiKeyConnected();
      if (isConnected) {
        final yubiKeyInfo = await YubiKeyService.getYubiKeyInfo();
        emit(YubiKeyConnected(yubiKeyInfo ?? {}));
      } else {
        emit(YubiKeyDisconnected());
      }
    } catch (e) {
      emit(AuthenticationError('Failed to check YubiKey connection: $e'));
    }
  }

  Future<void> _onGenerateTOTP(
    GenerateTOTP event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    try {
      final totpCode = await YubiKeyService.generateTOTP();
      if (totpCode != null) {
        emit(TOTPGenerated(totpCode));
      } else {
        emit(AuthenticationError('Failed to generate TOTP code'));
      }
    } catch (e) {
      emit(AuthenticationError('TOTP generation failed: $e'));
    }
  }

  Future<void> _onPerformHardwareConfirmation(
    PerformHardwareConfirmation event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    try {
      final confirmed = await YubiKeyService.performHardwareConfirmation();
      if (confirmed) {
        emit(HardwareConfirmationSuccess());
      } else {
        emit(AuthenticationError('Hardware confirmation failed'));
      }
    } catch (e) {
      emit(AuthenticationError('Hardware confirmation error: $e'));
    }
  }

  Future<void> _onAuthenticate(
    Authenticate event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthenticationLoading());
    try {
      // Step 1: Check YubiKey connection
      final isConnected = await YubiKeyService.isYubiKeyConnected();
      if (!isConnected) {
        emit(YubiKeyDisconnected());
        return;
      }

      // Step 2: Generate TOTP
      final totpCode = await YubiKeyService.generateTOTP();
      if (totpCode == null) {
        emit(AuthenticationError('Failed to generate TOTP code'));
        return;
      }

      // Step 3: Perform hardware confirmation
      final confirmed = await YubiKeyService.performHardwareConfirmation();
      if (!confirmed) {
        emit(AuthenticationError('Hardware confirmation failed'));
        return;
      }

      // Step 4: Authentication successful
      emit(AuthenticationSuccess());
    } catch (e) {
      emit(AuthenticationError('Authentication failed: $e'));
    }
  }
}