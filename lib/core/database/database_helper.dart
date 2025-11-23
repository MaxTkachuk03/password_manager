import 'package:password_manager/features/home/models/category_model.dart';
import 'package:password_manager/features/home/models/password_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'password_manager.db';
  static const int _databaseVersion = 2;

  // Table names
  static const String passwordsTable = 'passwords';
  static const String categoriesTable = 'categories';

  // Password table columns
  static const String columnPasswordId = 'id';
  static const String columnPasswordTitle = 'title';
  static const String columnPasswordUsername = 'username';
  static const String columnPasswordPassword = 'password';
  static const String columnPasswordWebsite = 'website';
  static const String columnPasswordNotes = 'notes';
  static const String columnPasswordCategoryId = 'category_id';
  static const String columnPasswordCreatedAt = 'created_at';
  static const String columnPasswordUpdatedAt = 'updated_at';
  static const String columnPasswordIsFavorite = 'is_favorite';
  static const String columnPasswordStrength = 'strength';
  static const String columnPasswordTags = 'tags';

  // Category table columns
  static const String columnCategoryId = 'id';
  static const String columnCategoryName = 'name';
  static const String columnCategoryDescription = 'description';
  static const String columnCategoryColor = 'color';
  static const String columnCategoryIcon = 'icon';
  static const String columnCategoryPasswordCount = 'password_count';
  static const String columnCategoryCreatedAt = 'created_at';
  static const String columnCategoryUpdatedAt = 'updated_at';

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create passwords table
    await db.execute('''
      CREATE TABLE $passwordsTable (
        $columnPasswordId TEXT PRIMARY KEY,
        $columnPasswordTitle TEXT NOT NULL,
        $columnPasswordUsername TEXT NOT NULL,
        $columnPasswordPassword TEXT NOT NULL,
        $columnPasswordWebsite TEXT,
        $columnPasswordNotes TEXT,
        $columnPasswordCategoryId TEXT NOT NULL,
        $columnPasswordCreatedAt INTEGER NOT NULL,
        $columnPasswordUpdatedAt INTEGER NOT NULL,
        $columnPasswordIsFavorite INTEGER NOT NULL DEFAULT 0,
        $columnPasswordStrength INTEGER NOT NULL DEFAULT 0,
        $columnPasswordTags TEXT
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE $categoriesTable (
        $columnCategoryId TEXT PRIMARY KEY,
        $columnCategoryName TEXT NOT NULL UNIQUE,
        $columnCategoryDescription TEXT,
        $columnCategoryColor TEXT NOT NULL,
        $columnCategoryIcon TEXT NOT NULL,
        $columnCategoryPasswordCount INTEGER NOT NULL DEFAULT 0,
        $columnCategoryCreatedAt INTEGER NOT NULL,
        $columnCategoryUpdatedAt INTEGER NOT NULL
      )
    ''');

    // Insert predefined categories
    await _insertPredefinedCategories(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
    if (oldVersion < 2) {
      // Version 2: Fix column names and date formats
      // Drop and recreate tables with correct schema
      await db.execute('DROP TABLE IF EXISTS $passwordsTable');
      await db.execute('DROP TABLE IF EXISTS $categoriesTable');
      await _onCreate(db, newVersion);
    }
  }

  static Future<void> _insertPredefinedCategories(Database db) async {
    final predefinedCategories = PredefinedCategories.categories;
    
    for (final category in predefinedCategories) {
      await db.insert(
        categoriesTable,
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Password operations
  static Future<List<Password>> getAllPasswords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      passwordsTable,
      orderBy: '$columnPasswordUpdatedAt DESC',
    );
    return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
  }

  static Future<Password?> getPasswordById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      passwordsTable,
      where: '$columnPasswordId = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Password.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> insertPassword(Password password) async {
    final db = await database;
    return await db.insert(
      passwordsTable,
      password.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updatePassword(Password password) async {
    final db = await database;
    return await db.update(
      passwordsTable,
      password.toMap(),
      where: '$columnPasswordId = ?',
      whereArgs: [password.id],
    );
  }

  static Future<int> deletePassword(String id) async {
    final db = await database;
    return await db.delete(
      passwordsTable,
      where: '$columnPasswordId = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Password>> searchPasswords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      passwordsTable,
      where: '''
        $columnPasswordTitle LIKE ? OR 
        $columnPasswordUsername LIKE ? OR 
        $columnPasswordWebsite LIKE ? OR 
        $columnPasswordNotes LIKE ? OR
        $columnPasswordTags LIKE ?
      ''',
      whereArgs: [
        '%$query%', '%$query%', '%$query%', '%$query%', '%$query%'
      ],
      orderBy: '$columnPasswordUpdatedAt DESC',
    );
    return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
  }

  static Future<List<Password>> getPasswordsByCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      passwordsTable,
      where: '$columnPasswordCategoryId = ?',
      whereArgs: [categoryId],
      orderBy: '$columnPasswordUpdatedAt DESC',
    );
    return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
  }

  static Future<List<Password>> getFavoritePasswords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      passwordsTable,
      where: '$columnPasswordIsFavorite = ?',
      whereArgs: [1],
      orderBy: '$columnPasswordUpdatedAt DESC',
    );
    return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
  }

  // Category operations
  static Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      categoriesTable,
      orderBy: '$columnCategoryName ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  static Future<Category?> getCategoryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      categoriesTable,
      where: '$columnCategoryId = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      categoriesTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      categoriesTable,
      category.toMap(),
      where: '$columnCategoryId = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      categoriesTable,
      where: '$columnCategoryId = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateCategoryPasswordCount(String categoryId, int count) async {
    final db = await database;
    return await db.update(
      categoriesTable,
      {
        columnCategoryPasswordCount: count,
        columnCategoryUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '$columnCategoryId = ?',
      whereArgs: [categoryId],
    );
  }

  // Database maintenance
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(passwordsTable);
    await db.delete(categoriesTable);
    await _insertPredefinedCategories(db);
  }

  // Export/Import operations
  static Future<Map<String, dynamic>> exportData() async {
    final passwords = await getAllPasswords();
    final categories = await getAllCategories();
    
    return {
      'passwords': passwords.map((p) => p.toMap()).toList(),
      'categories': categories.map((c) => c.toMap()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
      'version': _databaseVersion,
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    
    // Clear existing data
    await db.delete(passwordsTable);
    await db.delete(categoriesTable);
    
    // Import categories
    final categoriesData = data['categories'] as List<dynamic>?;
    if (categoriesData != null) {
      for (final categoryData in categoriesData) {
        await db.insert(
          categoriesTable,
          Map<String, dynamic>.from(categoryData),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    
    // Import passwords
    final passwordsData = data['passwords'] as List<dynamic>?;
    if (passwordsData != null) {
      for (final passwordData in passwordsData) {
        await db.insert(
          passwordsTable,
          Map<String, dynamic>.from(passwordData),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  // Statistics
  static Future<Map<String, int>> getPasswordStatistics() async {
    final db = await database;
    
    final totalPasswords = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $passwordsTable')
    ) ?? 0;
    
    final favoritePasswords = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $passwordsTable WHERE $columnPasswordIsFavorite = 1')
    ) ?? 0;
    
    final weakPasswords = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $passwordsTable WHERE $columnPasswordStrength < 3')
    ) ?? 0;
    
    return {
      'total': totalPasswords,
      'favorites': favoritePasswords,
      'weak': weakPasswords,
    };
  }
}