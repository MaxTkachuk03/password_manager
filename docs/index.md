# SecureVault - Password Manager Project Documentation

**Project:** password_manager  
**Type:** Mobile App (Flutter)  
**Level:** 3 (Complex System)  
**Generated:** 2025-11-23

## Project Overview

SecureVault is an offline-first password manager for mobile platforms (iOS/Android) built with Flutter. The application implements dual-factor authentication through YubiKey hardware tokens and provides secure password storage with AES-256 encryption.

## Architecture

### Technology Stack
- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** BLoC Pattern (flutter_bloc)
- **Database:** SQLCipher (sqflite_sqlcipher) - Encrypted SQLite
- **Security:** 
  - pointycastle for encryption
  - flutter_secure_storage for sensitive data
  - local_auth for biometric authentication
  - YubiKey integration via platform channels

### Project Structure

```
lib/
├── core/
│   ├── app_bar/          # Custom app bar components
│   ├── database/         # Database service and helper
│   ├── scaffold/         # Custom scaffold components
│   ├── services/         # YubiKey service (platform channels)
│   ├── text_field/       # Custom text field components
│   └── theme/            # App colors and theming
├── features/
│   ├── authentication/   # YubiKey authentication (BLoC)
│   ├── home/             # Password management (BLoC, models, widgets)
│   └── login/            # Login page
└── localization/         # i18n support
```

### Key Features

1. **Authentication**
   - YubiKey hardware token support
   - TOTP generation
   - Hardware confirmation
   - Session management

2. **Password Management**
   - CRUD operations for passwords
   - Category organization
   - Search and filtering
   - Favorite passwords
   - Password strength calculation

3. **Security**
   - AES-256 encrypted database (SQLCipher)
   - Offline-first architecture
   - Secure storage for sensitive data
   - Biometric authentication support

### Current Implementation Status

**Completed:**
- Basic project structure
- Database layer (SQLCipher)
- BLoC state management setup
- Authentication BLoC with YubiKey service
- Home page with password list
- Password and Category models
- Database service with CRUD operations

**In Progress / TODO:**
- Complete UI screens (add/edit password forms)
- YubiKey native platform integration
- Backup/restore functionality
- Settings and security screens
- Password generator
- Export functionality

## Database Schema

### Passwords Table
- id, title, username, password, website, notes
- categoryId, createdAt, updatedAt
- isFavorite, strength, tags

### Categories Table
- id, name, icon, color, passwordCount

## Next Steps

1. Complete tech-spec with user stories
2. Create sprint plan
3. Implement remaining features

