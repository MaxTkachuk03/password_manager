# Architecture

## Executive Summary

SecureVault is an offline-first password manager implementing hardware-based authentication through YubiKey tokens. This architecture document defines the system design, technology choices, and implementation patterns for building a secure, cross-platform mobile application using Flutter with Clean Architecture principles.

**Key Architectural Decisions:**
- Clean Architecture with BLoC pattern for scalable, testable code
- Device-only storage with SQLCipher for maximum privacy
- Platform Channels for native YubiKit SDK integration
- Defense-in-depth security strategy with hardware-backed cryptography
- Manual backup system for data portability

## Project Initialization

### Flutter Project Setup
```bash
# Create new Flutter project
flutter create secure_vault
cd secure_vault

# Add required dependencies
flutter pub add flutter_bloc
flutter pub add sqflite_common_ffi
flutter pub add sqlcipher
flutter pub add pointycastle
flutter pub add flutter_secure_storage
flutter pub add local_auth
flutter pub add path_provider
flutter pub add equatable
```

### Platform Configuration

#### iOS (Podfile)
```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # YubiKit iOS SDK
  pod 'YubiKit', '~> 4.0'
  
  # SQLCipher
  pod 'SQLCipher', '~> 4.5'
end
```

#### Android (app/build.gradle)
```gradle
dependencies {
    implementation 'org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version'
    
    # YubiKit Android SDK
    implementation 'com.yubico:yubikit-android:2.2.0'
    
    # SQLCipher
    implementation 'io.github.zman:sqlcipher-android:4.5.4'
}
```

## Decision Summary

| Category | Decision | Version | Affects Epics | Rationale |
|-----------|----------|---------|---------------|-----------|
| **Architecture** | Clean Architecture + BLoC | 3.x | All | Clear separation, testability, Flutter ecosystem support |
| **Database** | SQLCipher | 2.1.0 | Password Storage | AES-256 encryption, ACID compliance, Flutter support |
| **YubiKey** | Platform Channels + Native SDKs | Latest | Authentication | Full functionality, performance, official support |
| **Storage** | Device-Only + Manual Backup | 1.0 | Data Management | Maximum privacy, offline-first, user control |
| **Security** | Defense in Depth | 1.0 | All | Multi-layered protection, hardware-backed |
| **State Management** | BLoC Pattern | 8.1.0 | All UI | Scalable state management, testing support |
| **Dependency Injection** | get_it | 7.6.0 | All | Simple DI, no code generation |
| **Navigation** | Go Router | 12.1.0 | All | Declarative routing, deep linking |

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SecureVault App                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   Presentation  │  │    Domain       │  │    Data      │ │
│  │                 │  │                 │  │             │ │
│  │ - UI Screens    │  │ - Entities      │  │ - Repositories │ │
│  │ - BLoC Controllers│ │ - Use Cases     │  │ - Data Sources │ │
│  │ - Navigation    │  │ - Repositories  │  │ - Models      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Platform Layer                           │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │   iOS           │              │   Android       │      │
│  │                 │              │                 │      │
│  │ - YubiKit iOS   │              │ - YubiKey       │      │
│  │ - Keychain      │              │   Android      │      │
│  │ - SQLCipher     │              │ - Keystore      │      │
│  │ - File System   │              │ - SQLCipher     │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Screens    │───▶│   BLoC Controllers│───▶│   Use Cases     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       │                       │
         │                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Navigation    │◀───│    States       │◀───│   Entities      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources   │◀───│  Repositories   │◀───│ Repository Impl │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SQLCipher     │    │   YubiKey SDK   │    │   File System  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Project Structure

### Flutter Project Organization

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── database_constants.dart
│   │   └── yubikey_constants.dart
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   ├── services/
│   │   ├── encryption_service.dart
│   │   ├── storage_service.dart
│   │   └── yubikey_service.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── widgets/
│       ├── custom_text_field.dart
│       ├── loading_widget.dart
│       └── error_widget.dart
├── features/
│   ├── authentication/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── authentication_local_datasource.dart
│   │   │   │   └── yubikey_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── authentication_model.dart
│   │   │   │   └── yubikey_model.dart
│   │   │   └── repositories/
│   │   │       └── authentication_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── authentication.dart
│   │   │   │   └── yubikey_info.dart
│   │   │   ├── repositories/
│   │   │   │   └── authentication_repository.dart
│   │   │   └── usecases/
│   │   │       ├── authenticate_with_yubikey.dart
│   │   │       ├── generate_totp.dart
│   │   │       └── check_yubikey_status.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── authentication_bloc.dart
│   │       │   ├── authentication_event.dart
│   │       │   └── authentication_state.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── setup_page.dart
│   │       └── widgets/
│   │           ├── yubikey_status_widget.dart
│   │           └── totp_input_widget.dart
│   ├── password_manager/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── password_local_datasource.dart
│   │   │   │   └── backup_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── password_model.dart
│   │   │   │   └── backup_model.dart
│   │   │   └── repositories/
│   │   │       └── password_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── password.dart
│   │   │   │   ├── password_category.dart
│   │   │   │   └── backup_data.dart
│   │   │   ├── repositories/
│   │   │   │   └── password_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_passwords.dart
│   │   │       ├── add_password.dart
│   │   │       ├── update_password.dart
│   │   │       ├── delete_password.dart
│   │   │       ├── export_backup.dart
│   │   │       └── import_backup.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── password_bloc.dart
│   │       │   ├── password_event.dart
│   │       │   └── password_state.dart
│   │       ├── pages/
│   │       │   ├── password_list_page.dart
│   │       │   ├── password_detail_page.dart
│   │       │   └── add_password_page.dart
│   │       └── widgets/
│   │           ├── password_card.dart
│   │           ├── password_form.dart
│   │           └── search_widget.dart
│   ├── backup/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── file_backup_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── backup_file_model.dart
│   │   │   └── repositories/
│   │   │       └── backup_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── backup_file.dart
│   │   │   ├── repositories/
│   │   │   │   └── backup_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_backup.dart
│   │   │       ├── restore_backup.dart
│   │   │       └── validate_backup.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── backup_bloc.dart
│   │       │   ├── backup_event.dart
│   │       │   └── backup_state.dart
│   │       ├── pages/
│   │       │   ├── backup_page.dart
│   │       │   └── restore_page.dart
│   │       └── widgets/
│   │           ├── backup_options_widget.dart
│   │           └── qr_code_widget.dart
│   └── settings/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── settings_local_datasource.dart
│       │   ├── models/
│       │   │   └── settings_model.dart
│       │   └── repositories/
│       │       └── settings_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── app_settings.dart
│       │   ├── repositories/
│       │   │   └── settings_repository.dart
│       │   └── usecases/
│       │       ├── get_settings.dart
│       │       ├── update_settings.dart
│       │       └── reset_app.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── settings_bloc.dart
│           │   ├── settings_event.dart
│           │   └── settings_state.dart
│           ├── pages/
│           │   └── settings_page.dart
│           └── widgets/
│               ├── theme_selector.dart
│               └── security_options.dart
├── services/
│   ├── dependency_injection/
│   │   └── service_locator.dart
│   ├── platform_channels/
│   │   ├── yubikey_channel.dart
│   │   └── security_channel.dart
│   └── database/
│       ├── database_helper.dart
│       └── migrations/
├── main.dart
└── app.dart
```

### Platform-Specific Structure

#### iOS (Runner/)
```
Runner/
├── AppDelegate.swift
├── Runner-Bridging-Header.h
├── YubiKeyService.swift
├── SecurityService.swift
└── Info.plist
```

#### Android (app/src/main/)
```
main/
├── kotlin/
│   └── com/example/secure_vault/
│       ├── MainActivity.kt
│       ├── YubiKeyService.kt
│       └── SecurityService.kt
├── java/
│   └── com/example/secure_vault/
│       └── YubiKeyChannel.java
└── AndroidManifest.xml
```

## Architecture Decision Records (ADRs)

### ADR-001: Clean Architecture with BLoC

**Status:** Accepted

**Context:** Need scalable architecture that supports testing and future growth

**Decision:** Implement Clean Architecture with BLoC pattern

**Consequences:**
- **Pros:** Clear separation of concerns, testable, maintainable
- **Cons:** More boilerplate initially
- **Risks:** Team learning curve for BLoC

### ADR-002: Device-Only Storage

**Status:** Accepted

**Context:** User requirement for maximum privacy and offline-first approach

**Decision:** Store all data locally on device with manual backup options

**Consequences:**
- **Pros:** Maximum privacy, no cloud dependencies, simple sync
- **Cons:** Manual backup required, no automatic cross-device sync
- **Risks:** Data loss if device fails without backup

### ADR-003: Platform Channels for YubiKey

**Status:** Accepted

**Context:** Need full YubiKit functionality not available in Flutter packages

**Decision:** Use Platform Channels to communicate with native YubiKit SDKs

**Consequences:**
- **Pros:** Full YubiKey functionality, official SDK support
- **Cons:** Platform-specific code, more complex testing
- **Risks:** SDK version compatibility issues

### ADR-004: SQLCipher for Encrypted Storage

**Status:** Accepted

**Context:** Need encrypted database with ACID compliance

**Decision:** Use SQLCipher for local encrypted database

**Consequences:**
- **Pros:** AES-256 encryption, ACID compliance, Flutter support
- **Cons:** Larger app size, performance overhead
- **Risks:** Database corruption, key management complexity

### ADR-005: Manual Backup System

**Status:** Accepted

**Context:** Device-only storage requires backup mechanism

**Decision:** Implement manual backup via encrypted files and QR codes

**Consequences:**
- **Pros:** User control, no cloud dependencies, simple implementation
- **Cons:** Manual process, user responsibility
- **Risks:** Backup file loss, QR code limitations

## Implementation Patterns

### Repository Pattern

```dart
// Abstract repository
class PasswordRepository {
  Future<List<Password>> getPasswords();
  Future<void> addPassword(Password password);
  Future<void> updatePassword(Password password);
  Future<void> deletePassword(String id);
  Future<void> exportBackup(String path);
  Future<void> importBackup(String path);
}

// Implementation
class PasswordRepositoryImpl implements PasswordRepository {
  final PasswordLocalDataSource localDataSource;
  final BackupDataSource backupDataSource;
  final NetworkInfo networkInfo;

  PasswordRepositoryImpl({
    required this.localDataSource,
    required this.backupDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Password>> getPasswords() async {
    if (await networkInfo.isConnected) {
      // Could implement cloud sync in future
    }
    return await localDataSource.getPasswords();
  }
}
```

### BLoC Pattern

```dart
// Events
abstract class PasswordEvent extends Equatable {}

class LoadPasswords extends PasswordEvent {
  @override
  List<Object> get props => [];
}

class AddPassword extends PasswordEvent {
  final Password password;
  
  AddPassword(this.password);
  
  @override
  List<Object> get props => [password];
}

// States
abstract class PasswordState extends Equatable {}

class PasswordInitial extends PasswordState {
  @override
  List<Object> get props => [];
}

class PasswordLoading extends PasswordState {
  @override
  List<Object> get props => [];
}

class PasswordLoaded extends PasswordState {
  final List<Password> passwords;
  
  PasswordLoaded(this.passwords);
  
  @override
  List<Object> get props => [passwords];
}

class PasswordError extends PasswordState {
  final String message;
  
  PasswordError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final PasswordRepository repository;

  PasswordBloc({required this.repository}) : super(PasswordInitial()) {
    on<LoadPasswords>(_onLoadPasswords);
    on<AddPassword>(_onAddPassword);
    on<UpdatePassword>(_onUpdatePassword);
    on<DeletePassword>(_onDeletePassword);
  }

  Future<void> _onLoadPasswords(
    LoadPasswords event,
    Emitter<PasswordState> emit,
  ) async {
    emit(PasswordLoading());
    try {
      final passwords = await repository.getPasswords();
      emit(PasswordLoaded(passwords));
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }
}
```

### Service Locator Pattern

```dart
// service_locator.dart
final GetIt serviceLocator = GetIt.instance;

Future<void> init() async {
  // Database
  serviceLocator.registerLazySingleton<DatabaseHelper>(
    () => DatabaseHelper(),
  );

  // Data sources
  serviceLocator.registerLazySingleton<PasswordLocalDataSource>(
    () => PasswordLocalDataSourceImpl(databaseHelper: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<YubiKeyDataSource>(
    () => YubiKeyDataSourceImpl(),
  );

  // Repositories
  serviceLocator.registerLazySingleton<PasswordRepository>(
    () => PasswordRepositoryImpl(
      localDataSource: serviceLocator(),
      backupDataSource: serviceLocator(),
      networkInfo: serviceLocator(),
    ),
  );

  // Use cases
  serviceLocator.registerLazySingleton<GetPasswords>(
    () => GetPasswords(serviceLocator()),
  );

  // BLoCs
  serviceLocator.registerFactory<PasswordBloc>(
    () => PasswordBloc(getPasswords: serviceLocator()),
  );
}
```

### Platform Channel Pattern

```dart
// yubikey_channel.dart
class YubiKeyChannel {
  static const MethodChannel _channel = MethodChannel('yubikey');

  static Future<String> getTOTPCode() async {
    try {
      final String result = await _channel.invokeMethod('getTOTPCode');
      return result;
    } on PlatformException catch (e) {
      throw YubiKeyException('Failed to get TOTP code: ${e.message}');
    }
  }

  static Future<bool> performFIDO2Assertion() async {
    try {
      final bool result = await _channel.invokeMethod('performFIDO2Assertion');
      return result;
    } on PlatformException catch (e) {
      throw YubiKeyException('Failed to perform FIDO2 assertion: ${e.message}');
    }
  }

  static Stream<YubiKeyStatus> get yubiKeyStatus {
    return _channel
        .receiveBroadcastStream()
        .map((dynamic status) => YubiKeyStatus.fromMap(status));
  }
}
```

### Encryption Service Pattern

```dart
// encryption_service.dart
class EncryptionService {
  static const String _algorithm = 'AES-256-CBC';
  static const int _keyLength = 32;
  static const int _ivLength = 16;

  static Future<EncryptedData> encrypt(String plaintext, String password) async {
    final key = await _deriveKey(password);
    final iv = SecureRandom(_ivLength);
    
    final encryptor = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encryptor.encrypt(plaintext, iv: IV(iv));
    
    return EncryptedData(
      data: encrypted.base64,
      iv: iv.base64,
      algorithm: _algorithm,
    );
  }

  static Future<String> decrypt(EncryptedData encrypted, String password) async {
    final key = await _deriveKey(password);
    final iv = IV.fromBase64(encrypted.iv);
    
    final encryptor = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encryptor.decrypt64(encrypted.data, iv: iv);
    
    return decrypted;
  }

  static Future<Uint8List> _deriveKey(String password) async {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }
}
```

## Novel Pattern Designs

### YubiKey State Management Pattern

```dart
// YubiKey state management with automatic reconnection
class YubiKeyManager extends Cubit<YubiKeyState> {
  final YubiKeyService _service;
  Timer? _connectionCheckTimer;

  YubiKeyManager(this._service) : super(YubiKeyDisconnected()) {
    _startConnectionMonitoring();
  }

  void _startConnectionMonitoring() {
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkConnection(),
    );
  }

  Future<void> _checkConnection() async {
    try {
      final isConnected = await _service.isConnected();
      if (isConnected && state is YubiKeyDisconnected) {
        emit(YubiKeyConnected());
      } else if (!isConnected && state is YubiKeyConnected) {
        emit(YubiKeyDisconnected());
      }
    } catch (e) {
      emit(YubiKeyError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _connectionCheckTimer?.cancel();
    return super.close();
  }
}
```

### Secure Memory Management Pattern

```dart
// Automatic memory cleanup for sensitive data
class SecureString {
  Uint8List? _bytes;
  Timer? _cleanupTimer;

  SecureString(String data) {
    _bytes = Uint8List.fromList(utf8.encode(data));
    _scheduleCleanup();
  }

  void _scheduleCleanup() {
    _cleanupTimer = Timer(const Duration(minutes: 5), () {
      clear();
    });
  }

  String get value {
    _scheduleCleanup(); // Reset timer on access
    return utf8.decode(_bytes!);
  }

  void clear() {
    if (_bytes != null) {
      // Zero out memory
      for (int i = 0; i < _bytes!.length; i++) {
        _bytes![i] = 0;
      }
      _bytes = null;
    }
    _cleanupTimer?.cancel();
  }
}
```

### Backup Validation Pattern

```dart
// Comprehensive backup validation
class BackupValidator {
  static Future<BackupValidationResult> validateBackup(
    String backupPath,
  ) async {
    final result = BackupValidationResult();

    try {
      // File existence check
      final file = File(backupPath);
      if (!await file.exists()) {
        result.addError('Backup file does not exist');
        return result;
      }

      // File size check
      final fileSize = await file.length();
      if (fileSize == 0) {
        result.addError('Backup file is empty');
        return result;
      }

      // File format validation
      final content = await file.readAsString();
      final backupData = BackupData.fromJson(jsonDecode(content));
      
      // Data integrity check
      if (backupData.passwords.isEmpty) {
        result.addWarning('Backup contains no passwords');
      }

      // Version compatibility check
      if (backupData.version > currentVersion) {
        result.addError('Backup version is newer than app version');
      }

      // Checksum validation
      final calculatedChecksum = _calculateChecksum(backupData);
      if (backupData.checksum != calculatedChecksum) {
        result.addError('Backup checksum validation failed');
      }

    } catch (e) {
      result.addError('Backup validation failed: ${e.toString()}');
    }

    return result;
  }
}
```

## Implementation Patterns

### Error Handling Pattern

```dart
// Custom exceptions for better error handling
class SecureVaultException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SecureVaultException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    return 'SecureVaultException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class YubiKeyException extends SecureVaultException {
  YubiKeyException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

class EncryptionException extends SecureVaultException {
  EncryptionException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}
```

### Logging Pattern

```dart
// Structured logging for security events
class SecureLogger {
  static const String _tag = 'SecureVault';
  static const int _maxLogSize = 1024 * 1024; // 1MB

  static void logSecurityEvent(
    String event,
    Map<String, dynamic> context,
  ) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'event': event,
      'context': context,
      'level': 'SECURITY',
    };

    _writeLog(logEntry);
  }

  static void logError(
    String error,
    dynamic exception,
    StackTrace? stackTrace,
  ) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'error': error,
      'exception': exception.toString(),
      'stackTrace': stackTrace?.toString(),
      'level': 'ERROR',
    };

    _writeLog(logEntry);
  }

  static Future<void> _writeLog(Map<String, dynamic> entry) async {
    final logFile = await _getLogFile();
    final logLine = jsonEncode(entry) + '\n';
    
    await logFile.writeAsString(logLine, mode: FileMode.append);
    
    // Rotate logs if too large
    if (await logFile.length() > _maxLogSize) {
      await _rotateLogs();
    }
  }
}
```

## Testing Strategy

### Unit Testing Pattern

```dart
// Example unit test for password repository
void main() {
  late PasswordRepositoryImpl repository;
  late MockPasswordLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockPasswordLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PasswordRepositoryImpl(
      localDataSource: mockLocalDataSource,
      backupDataSource: MockBackupDataSource(),
      networkInfo: mockNetworkInfo,
    );
  });

  group('getPasswords', () {
    test(
      'should return passwords from local data source when device is offline',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getPasswords())
            .thenAnswer((_) async => [testPassword]);

        // Act
        final result = await repository.getPasswords();

        // Assert
        expect(result, [testPassword]);
        verify(mockLocalDataSource.getPasswords()).called(1);
        verifyNever(mockNetworkInfo.isConnected);
      },
    );
  });
}
```

### Integration Testing Pattern

```dart
// Integration test for YubiKey authentication
def main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('YubiKey Authentication Integration Tests', () {
    testWidgets('should authenticate with YubiKey successfully', (tester) async {
      // Arrange
      await tester.pumpWidget(SecureVaultApp());

      // Act
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PasswordListPage), findsOneWidget);
      expect(find.text('Authentication successful'), findsOneWidget);
    });
  });
}
```

## Performance Optimization

### Database Optimization

```dart
// Optimized database operations
class OptimizedPasswordDataSource {
  Future<List<Password>> getPasswordsWithPagination(
    int offset,
    int limit,
  ) async {
    final db = await databaseHelper.database;
    
    return await db.query(
      'passwords',
      limit: limit,
      offset: offset,
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Password>> searchPasswords(String query) async {
    final db = await databaseHelper.database;
    
    return await db.query(
      'passwords',
      where: 'title LIKE ? OR username LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
  }
}
```

### Memory Optimization

```dart
// Memory-efficient password list widget
class EfficientPasswordList extends StatelessWidget {
  final List<Password> passwords;

  const EfficientPasswordList({required this.passwords});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: passwords.length,
      itemBuilder: (context, index) {
        return PasswordCard(
          password: passwords[index],
          key: ValueKey(passwords[index].id),
        );
      },
    );
  }
}
```

## Security Implementation

### Root/Jailbreak Detection

```dart
// Platform-specific security checks
class SecurityChecker {
  static Future<bool> isDeviceSecure() async {
    if (Platform.isIOS) {
      return await _checkIOSJailbreak();
    } else if (Platform.isAndroid) {
      return await _checkAndroidRoot();
    }
    return true;
  }

  static Future<bool> _checkIOSJailbreak() async {
    try {
      // Check for jailbreak indicators
      const jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
      ];

      for (final path in jailbreakPaths) {
        if (await Directory(path).exists()) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _checkAndroidRoot() async {
    try {
      // Check for root indicators
      const rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
      ];

      for (final path in rootPaths) {
        if (await File(path).exists()) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

### Certificate Pinning

```dart
// HTTP certificate pinning for any network requests
class SecureHttpClient extends http.BaseClient {
  final http.Client _inner;
  final Map<String, String> _pinnedCertificates;

  SecureHttpClient(this._inner, this._pinnedCertificates);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);

    // Verify certificate pinning
    if (_pinnedCertificates.containsKey(request.url.host)) {
      final pinnedCert = _pinnedCertificates[request.url.host]!;
      // Implementation would verify the actual certificate
      // against the pinned certificate
    }

    return response;
  }
}
```

## Deployment Architecture

### Build Configuration

#### Flutter Build Commands
```bash
# Development builds
flutter build apk --debug
flutter build ios --debug

# Release builds
flutter build apk --release --shrink
flutter build ios --release

# Obfuscated builds
flutter build apk --release --obfuscate --split-debug-info=build/debug/
flutter build ios --release --obfuscate
```

#### iOS Configuration
```plist
<!-- Info.plist key configurations -->
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to authenticate and access your passwords</string>

<key>NSNFCReaderUsageDescription</key>
<string>Use NFC to communicate with YubiKey for authentication</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>yubico-auth</string>
</array>
```

#### Android Configuration
```xml
<!-- AndroidManifest.xml permissions -->
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Application security -->
<application
    android:allowBackup="false"
    android:fullBackupContent="false"
    android:networkSecurityConfig="@xml/network_security_config"
    android:requestLegacyExternalStorage="false">
```

### Code Obfuscation

#### R8 ProGuard Configuration (Android)
```proguard
# Keep YubiKit classes
-keep class com.yubico.** { *; }
-keep class org.bouncycastle.** { *; }

# Keep SQLCipher classes
-keep class net.sqlcipher.** { *; }

# Keep Flutter engine
-keep class io.flutter.** { *; }
```

### Release Checklist

- [ ] Code obfuscation enabled
- [ ] Debug symbols stripped
- [ ] Certificate pinning implemented
- [ ] Root/jailbreak detection enabled
- [ ] Memory protection implemented
- [ ] Security audit completed
- [ ] Performance testing completed
- [ ] Backup/restore testing completed
- [ ] YubiKey compatibility testing
- [ ] Store submission guidelines met

## Conclusion

This architecture provides a solid foundation for SecureVault with:

- **Security-first design** with hardware-backed authentication
- **Clean Architecture** for maintainability and testing
- **Device-only storage** for maximum privacy
- **Scalable patterns** for future growth
- **Platform integration** for full YubiKey functionality

The architecture balances security requirements with usability while maintaining clean, testable code structure that can evolve as the product grows.

---

_Generated by BMAD Decision Architecture Workflow v1.0_
_Date: 2025-11-18_
_For: Max_