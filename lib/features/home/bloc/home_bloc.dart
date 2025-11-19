import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../models/password_model.dart';
import '../models/category_model.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../core/database/database_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DatabaseService _databaseService = DatabaseService();
  String _searchQuery = '';
  String _selectedCategoryId = 'All';
  PasswordSortType _sortType = PasswordSortType.title;
  bool _sortAscending = true;

  HomeBloc() : super(const HomeInitial()) {
    on<LoadPasswords>(_onLoadPasswords);
    on<LoadCategories>(_onLoadCategories);
    on<AddPassword>(_onAddPassword);
    on<UpdatePassword>(_onUpdatePassword);
    on<DeletePassword>(_onDeletePassword);
    on<ToggleFavoritePassword>(_onToggleFavoritePassword);
    on<SearchPasswords>(_onSearchPasswords);
    on<FilterByCategory>(_onFilterByCategory);
    on<SortPasswords>(_onSortPasswords);
    // on<ExportPasswords>(_onExportPasswords);
    on<ImportPasswords>(_onImportPasswords);
    on<GeneratePassword>(_onGeneratePassword);
    on<CheckPasswordStrength>(_onCheckPasswordStrength);
  }

  Future<void> _onLoadPasswords(
    LoadPasswords event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      await _initializeDefaultCategories();
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
    } catch (e) {
      emit(HomeError('Помилка завантаження категорій: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(const HomeLoading());
      await _initializeDefaultCategories();
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
    } catch (e) {
      emit(HomeError('Помилка завантаження категорій: ${e.toString()}'));
    }
  }

  Future<void> _onAddPassword(
    AddPassword event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final password = event.password.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        strength: Password.calculateStrength(event.password.password),
      );
      
      await _databaseService.addPassword(password);
      
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
      
      emit(PasswordAdded(password));
    } catch (e) {
      emit(HomeError('Помилка додавання пароля: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePassword(
    UpdatePassword event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final updatedPassword = event.password.copyWith(
        updatedAt: DateTime.now(),
        strength: Password.calculateStrength(event.password.password),
      );
      
      await _databaseService.updatePassword(updatedPassword);
      
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
      
      emit(PasswordUpdated(updatedPassword));
    } catch (e) {
      emit(HomeError('Помилка оновлення пароля: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePassword(
    DeletePassword event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _databaseService.deletePassword(event.passwordId);
      
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
      
      emit(PasswordDeleted(event.passwordId));
    } catch (e) {
      emit(HomeError('Помилка видалення пароля: ${e.toString()}'));
    }
  }

  Future<void> _onToggleFavoritePassword(
    ToggleFavoritePassword event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final passwords = await _databaseService.getAllPasswords();
      final password = passwords.firstWhere((p) => p.id == event.passwordId);
      final updatedPassword = password.copyWith(
        isFavorite: !password.isFavorite,
        updatedAt: DateTime.now(),
      );
      
      await _databaseService.updatePassword(updatedPassword);
      
      final allPasswords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(allPasswords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
      
      emit(PasswordToggledFavorite(event.passwordId, updatedPassword.isFavorite));
    } catch (e) {
      emit(HomeError('Помилка змни улюбленого пароля: ${e.toString()}'));
    }
  }

  Future<void> _onSearchPasswords(
    SearchPasswords event,
    Emitter<HomeState> emit,
  ) async {
    try {
      _searchQuery = event.query;
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<HomeState> emit,
  ) async {
    try {
      _selectedCategoryId = event.categoryId;
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onSortPasswords(
    SortPasswords event,
    Emitter<HomeState> emit,
  ) async {
    try {
      _sortType = event.sortType;
      _sortAscending = event.ascending;
      final passwords = await _databaseService.getAllPasswords();
      final categories = await _databaseService.getAllCategories();
      final filteredPasswords = _getFilteredPasswords(passwords);
      
      emit(HomeLoaded(
        passwords: filteredPasswords,
        categories: categories,
        filteredPasswords: filteredPasswords,
        searchQuery: _searchQuery,
        selectedCategoryId: _selectedCategoryId,
        sortType: _sortType,
        sortAscending: _sortAscending,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  // Future<void> _onExportPasswords(
  //   ExportPasswords event,
  //   Emitter<HomeState> emit,
  // ) async {
  //   try {
  //     final filePath = await _databaseService.exportPasswords(event.passwords);
  //     emit(PasswordsExported(filePath));
  //   } catch (e) {
  //     emit(HomeError('Помилка експорту паролів: ${e.toString()}'));
  //   }
  // }

  Future<void> _onImportPasswords(
    ImportPasswords event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final count = await _databaseService.exportPasswords(event.filePath);
      emit(PasswordsImported(count));
      
      add(LoadPasswords());
    } catch (e) {
      emit(HomeError('Помилка імпорту паролів: ${e.toString()}'));
    }
  }

  Future<void> _onGeneratePassword(
    GeneratePassword event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final password = await _databaseService.generatePassword(
        length: event.length,
        includeUppercase: event.includeUppercase,
        includeLowercase: event.includeLowercase,
        includeNumbers: event.includeNumbers,
        includeSymbols: event.includeSymbols,
      );
      
      final strength = Password.calculateStrength(password);
      emit(PasswordGenerated(password, strength));
    } catch (e) {
      emit(HomeError('Помилка генерації пароля: ${e.toString()}'));
    }
  }

  Future<void> _onCheckPasswordStrength(
    CheckPasswordStrength event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final strength = Password.calculateStrength(event.password);
      emit(PasswordStrengthChecked(strength));
    } catch (e) {
      emit(HomeError('Помилка перевірки сили пароля: ${e.toString()}'));
    }
  }

  Future<void> _initializeDefaultCategories() async {
    try {
      final existingCategories = await _databaseService.getAllCategories();
      if (existingCategories.isEmpty) {
        final defaultCategories = [
          Category(
            id: 'social',
            name: 'Соціальні мережі',
            description: 'Акаунти соціальних мереж',
            color: Colors.blue,
            icon: Icons.people,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: 'work',
            name: 'Робота',
            description: 'Робочі акаунти',
            color: Colors.green,
            icon: Icons.work,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: 'finance',
            name: 'Фінанси',
            description: 'Банківські та фінансові акаунти',
            color: Colors.orange,
            icon: Icons.account_balance,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: 'entertainment',
            name: 'Розваги',
            description: 'Розважальні сервіси',
            color: Colors.purple,
            icon: Icons.movie,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Category(
            id: 'shopping',
            name: 'Покупки',
            description: 'Інтернет-магазини',
            color: Colors.red,
            icon: Icons.shopping_cart,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        for (final category in defaultCategories) {
          await _databaseService.addCategory(category);
        }
      }
    } catch (e) {
      // Silently handle category initialization errors
    }
  }

  List<Password> _getFilteredPasswords(List<Password> passwords) {
    var filtered = passwords;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((password) {
        return password.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            password.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            password.website.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            password.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply category filter
    if (_selectedCategoryId != 'All') {
      filtered = filtered.where((password) => password.categoryId == _selectedCategoryId).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int result = 0;
      
      switch (_sortType) {
        case PasswordSortType.title:
          result = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case PasswordSortType.username:
          result = a.username.toLowerCase().compareTo(b.username.toLowerCase());
          break;
        case PasswordSortType.website:
          result = a.website.toLowerCase().compareTo(b.website.toLowerCase());
          break;
        case PasswordSortType.strength:
          result = a.strength.compareTo(b.strength);
          break;
        case PasswordSortType.dateCreated:
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case PasswordSortType.dateUpdated:
          result = a.updatedAt.compareTo(b.updatedAt);
          break;
        case PasswordSortType.createdAt:
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case PasswordSortType.updatedAt:
          result = a.updatedAt.compareTo(b.updatedAt);
          break;
        case PasswordSortType.favorite:
          result = a.isFavorite ? 1 : -1;
          break;
      }
      
      return _sortAscending ? result : -result;
    });
    
    return filtered;
  }

  String _generateSecurePassword({
    required int length,
    required bool includeUppercase,
    required bool includeLowercase,
    required bool includeNumbers,
    required bool includeSymbols,
  }) {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    String chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSymbols) chars += symbols;
    
    if (chars.isEmpty) return '';
    
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    
    for (int i = 0; i < length; i++) {
      final index = (random + i) % chars.length;
      password += chars[index];
    }
    
    return password;
  }

}