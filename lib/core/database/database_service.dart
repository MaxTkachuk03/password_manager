import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../encryption/encryption_service.dart';
import '../security/master_password_service.dart';
import '../../features/home/models/password_model.dart';
import '../../features/home/models/category_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Password operations
  Future<List<Password>> getAllPasswords() async {
    try {
      return await DatabaseHelper.getAllPasswords();
    } catch (e) {
      throw DatabaseException('Failed to get all passwords: $e');
    }
  }

  Future<Password?> getPasswordById(String id) async {
    try {
      return await DatabaseHelper.getPasswordById(id);
    } catch (e) {
      throw DatabaseException('Failed to get password by id: $e');
    }
  }

  Future<bool> addPassword(Password password) async {
    try {
      final result = await DatabaseHelper.insertPassword(password);
      
      // Update category password count
      await _updateCategoryPasswordCount(password.categoryId);
      
      return result > 0;
    } catch (e) {
      throw DatabaseException('Failed to add password: $e');
    }
  }

  Future<bool> updatePassword(Password password) async {
    try {
      final result = await DatabaseHelper.updatePassword(password);
      
      // Update category password count if category changed
      await _updateCategoryPasswordCount(password.categoryId);
      
      return result > 0;
    } catch (e) {
      throw DatabaseException('Failed to update password: $e');
    }
  }

  Future<bool> deletePassword(String id) async {
    try {
      // Get password before deletion to update category count
      final password = await getPasswordById(id);
      if (password != null) {
        final result = await DatabaseHelper.deletePassword(id);
        
        // Update category password count
        await _updateCategoryPasswordCount(password.categoryId);
        
        return result > 0;
      }
      return false;
    } catch (e) {
      throw DatabaseException('Failed to delete password: $e');
    }
  }

  Future<List<Password>> searchPasswords(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllPasswords();
      }
      return await DatabaseHelper.searchPasswords(query);
    } catch (e) {
      throw DatabaseException('Failed to search passwords: $e');
    }
  }

  Future<List<Password>> getPasswordsByCategory(String categoryId) async {
    try {
      if (categoryId == 'all') {
        return getAllPasswords();
      }
      return await DatabaseHelper.getPasswordsByCategory(categoryId);
    } catch (e) {
      throw DatabaseException('Failed to get passwords by category: $e');
    }
  }

  Future<List<Password>> getFavoritePasswords() async {
    try {
      return await DatabaseHelper.getFavoritePasswords();
    } catch (e) {
      throw DatabaseException('Failed to get favorite passwords: $e');
    }
  }

  // Category operations
  Future<List<Category>> getAllCategories() async {
    try {
      return await DatabaseHelper.getAllCategories();
    } catch (e) {
      throw DatabaseException('Failed to get all categories: $e');
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      return await DatabaseHelper.getCategoryById(id);
    } catch (e) {
      throw DatabaseException('Failed to get category by id: $e');
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      final result = await DatabaseHelper.insertCategory(category);
      return result > 0;
    } catch (e) {
      throw DatabaseException('Failed to add category: $e');
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      final result = await DatabaseHelper.updateCategory(category);
      return result > 0;
    } catch (e) {
      throw DatabaseException('Failed to update category: $e');
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      // Check if category has passwords
      final passwords = await getPasswordsByCategory(id);
      if (passwords.isNotEmpty) {
        throw DatabaseException('Cannot delete category with existing passwords');
      }
      
      final result = await DatabaseHelper.deleteCategory(id);
      return result > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete category: $e');
    }
  }

  // Export/Import operations
  Future<Map<String, dynamic>> exportData() async {
    try {
      return await DatabaseHelper.exportData();
    } catch (e) {
      throw DatabaseException('Failed to export data: $e');
    }
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      await DatabaseHelper.importData(data);
      return true;
    } catch (e) {
      throw DatabaseException('Failed to import data: $e');
    }
  }

  // Statistics
  Future<Map<String, int>> getPasswordStatistics() async {
    try {
      return await DatabaseHelper.getPasswordStatistics();
    } catch (e) {
      throw DatabaseException('Failed to get password statistics: $e');
    }
  }

  // Database maintenance
  Future<void> clearAllData() async {
    try {
      await DatabaseHelper.clearAllData();
    } catch (e) {
      throw DatabaseException('Failed to clear all data: $e');
    }
  }

  Future<void> closeDatabase() async {
    try {
      await DatabaseHelper.closeDatabase();
    } catch (e) {
      throw DatabaseException('Failed to close database: $e');
    }
  }

  // Private helper methods
  Future<void> _updateCategoryPasswordCount(String categoryId) async {
    try {
      final passwords = await getPasswordsByCategory(categoryId);
      final count = passwords.length;
      
      await DatabaseHelper.updateCategoryPasswordCount(categoryId, count);
    } catch (e) {
      // Don't throw error for category count updates
      print('Failed to update category password count: $e');
    }
  }

  // Batch operations
  Future<bool> addMultiplePasswords(List<Password> passwords) async {
    try {
      final db = await DatabaseHelper.database;
      final batch = db.batch();
      
      for (final password in passwords) {
        batch.insert(
          DatabaseHelper.passwordsTable,
          password.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      final results = await batch.commit();
      
      // Update category counts
      final categoryIds = passwords.map((p) => p.categoryId).toSet();
      for (final categoryId in categoryIds) {
        await _updateCategoryPasswordCount(categoryId);
      }
      
      return results.every((result) => result != null && result as int > 0);
    } catch (e) {
      throw DatabaseException('Failed to add multiple passwords: $e');
    }
  }

  Future<bool> updateMultiplePasswords(List<Password> passwords) async {
    try {
      final db = await DatabaseHelper.database;
      final batch = db.batch();
      
      for (final password in passwords) {
        batch.update(
          DatabaseHelper.passwordsTable,
          password.toMap(),
          where: '${DatabaseHelper.columnPasswordId} = ?',
          whereArgs: [password.id],
        );
      }
      
      final results = await batch.commit();
      
      // Update category counts
      final categoryIds = passwords.map((p) => p.categoryId).toSet();
      for (final categoryId in categoryIds) {
        await _updateCategoryPasswordCount(categoryId);
      }
      
      return results.every((result) => result != null && result as int > 0);
    } catch (e) {
      throw DatabaseException('Failed to update multiple passwords: $e');
    }
  }

  Future<bool> deleteMultiplePasswords(List<String> passwordIds) async {
    try {
      // Get passwords before deletion to update category counts
      final passwords = <Password>[];
      for (final id in passwordIds) {
        final password = await getPasswordById(id);
        if (password != null) {
          passwords.add(password);
        }
      }
      
      final db = await DatabaseHelper.database;
      final batch = db.batch();
      
      for (final id in passwordIds) {
        batch.delete(
          DatabaseHelper.passwordsTable,
          where: '${DatabaseHelper.columnPasswordId} = ?',
          whereArgs: [id],
        );
      }
      
      final results = await batch.commit();
      
      // Update category counts
      final categoryIds = passwords.map((p) => p.categoryId).toSet();
      for (final categoryId in categoryIds) {
        await _updateCategoryPasswordCount(categoryId);
      }
      
      return results.every((result) => result != null && result as int > 0);
    } catch (e) {
      throw DatabaseException('Failed to delete multiple passwords: $e');
    }
  }

  // Search with filters
  Future<List<Password>> searchWithFilters({
    String? query,
    String? categoryId,
    bool? isFavorite,
    int? minStrength,
    int? maxStrength,
    List<String>? tags,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      
      String whereClause = '1=1';
      List<dynamic> whereArgs = [];
      
      if (query != null && query.trim().isNotEmpty) {
        whereClause += '''
          AND (
            ${DatabaseHelper.columnPasswordTitle} LIKE ? OR 
            ${DatabaseHelper.columnPasswordUsername} LIKE ? OR 
            ${DatabaseHelper.columnPasswordWebsite} LIKE ? OR 
            ${DatabaseHelper.columnPasswordNotes} LIKE ? OR
            ${DatabaseHelper.columnPasswordTags} LIKE ?
          )
        ''';
        whereArgs.addAll(['%$query%', '%$query%', '%$query%', '%$query%', '%$query%']);
      }
      
      if (categoryId != null && categoryId != 'all') {
        whereClause += ' AND ${DatabaseHelper.columnPasswordCategoryId} = ?';
        whereArgs.add(categoryId);
      }
      
      if (isFavorite != null) {
        whereClause += ' AND ${DatabaseHelper.columnPasswordIsFavorite} = ?';
        whereArgs.add(isFavorite ? 1 : 0);
      }
      
      if (minStrength != null) {
        whereClause += ' AND ${DatabaseHelper.columnPasswordStrength} >= ?';
        whereArgs.add(minStrength);
      }
      
      if (maxStrength != null) {
        whereClause += ' AND ${DatabaseHelper.columnPasswordStrength} <= ?';
        whereArgs.add(maxStrength);
      }
      
      if (tags != null && tags.isNotEmpty) {
        for (final tag in tags) {
          whereClause += ' AND ${DatabaseHelper.columnPasswordTags} LIKE ?';
          whereArgs.add('%$tag%');
        }
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.passwordsTable,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: '${DatabaseHelper.columnPasswordUpdatedAt} DESC',
      );
      
      return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to search with filters: $e');
    }
  }

  Future<String> exportPasswords() async {
    try {
      final exportData = await DatabaseHelper.exportData();
      final jsonString = jsonEncode(exportData);
      
      // Always encrypt with master password
      final masterPasswordService = MasterPasswordService();
      var masterPassword = await masterPasswordService.getMasterPassword();
      
      // Auto-generate master password if not set
      if (masterPassword == null || masterPassword.isEmpty) {
        masterPassword = await _generateAndStoreMasterPassword();
      }
      
      // Encrypt with AES256-GCM
      final encryptedContent = EncryptionService.encrypt(jsonString, masterPassword);
      
      // Get appropriate directory for mobile platforms
      Directory directory;
      try {
        if (Platform.isAndroid) {
          // Try to use Downloads directory on Android
          final downloadsDir = Directory('/storage/emulated/0/Download');
          if (await downloadsDir.exists()) {
            directory = downloadsDir;
          } else {
            // Fallback to external storage
            final externalDir = await getExternalStorageDirectory();
            directory = externalDir ?? await getApplicationDocumentsDirectory();
          }
        } else if (Platform.isIOS) {
          // For iOS, use documents directory (accessible via Files app)
          directory = await getApplicationDocumentsDirectory();
        } else {
          // Desktop fallback
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        // Fallback to application documents
        directory = await getApplicationDocumentsDirectory();
      }
      
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'securevault_backup_$timestamp.encrypted';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsString(encryptedContent);
      
      return file.path;
    } catch (e) {
      throw DatabaseException('Failed to export passwords: $e');
    }
  }

  Future<int> importPasswords(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw DatabaseException('File not found: $filePath');
      }
      
      final fileContent = await file.readAsString();
      String jsonString;
      
      // Check if file is encrypted
      if (EncryptionService.isEncrypted(fileContent)) {
        // Use master password for decryption
        final masterPasswordService = MasterPasswordService();
        final masterPassword = await masterPasswordService.getMasterPassword();
        
        if (masterPassword == null || masterPassword.isEmpty) {
          throw DatabaseException('Master password not set. Cannot decrypt file. Please export a new backup first to generate master password.');
        }
        
        jsonString = EncryptionService.decrypt(fileContent, masterPassword);
      } else {
        // Legacy unencrypted file support
        jsonString = fileContent;
      }
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      await DatabaseHelper.importData(data);
      
      // Count imported items
      final passwords = await getAllPasswords();
      return passwords.length;
    } catch (e) {
      if (e is EncryptionException) {
        throw DatabaseException(e.message);
      }
      throw DatabaseException('Failed to import passwords: ${e.toString()}');
    }
  }

  Future<String> generatePassword({
    required int length,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) async {
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;

    if (chars.isEmpty) {
      throw DatabaseException('Потрібно вибрати хоча б один тип символів');
    }

    final random = Random.secure();
    final password = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      final index = random.nextInt(chars.length);
      password.write(chars[index]);
    }

    return password.toString();
  }

  /// Generate and store master password automatically
  Future<String> _generateAndStoreMasterPassword() async {
    // Generate a secure 32-character master password
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String numbers = '0123456789';
    const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    const String allChars = uppercase + lowercase + numbers + symbols;

    final random = Random.secure();
    final password = StringBuffer();
    
    for (int i = 0; i < 32; i++) {
      final index = random.nextInt(allChars.length);
      password.write(allChars[index]);
    }

    final masterPassword = password.toString();
    final masterPasswordService = MasterPasswordService();
    await masterPasswordService.setMasterPassword(masterPassword);
    
    return masterPassword;
  }
}

class DatabaseException implements Exception {
  final String message;
  
  const DatabaseException(this.message);
  
  @override
  String toString() => 'DatabaseException: $message';
}