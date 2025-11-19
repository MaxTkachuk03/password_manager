import 'package:equatable/equatable.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import '../models/password_model.dart';
import '../models/category_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<Password> passwords;
  final List<Category> categories;
  final List<Password> filteredPasswords;
  final String searchQuery;
  final String selectedCategoryId;
  final PasswordSortType sortType;
  final bool sortAscending;
  final String? generatedPassword;
  final int? passwordStrength;

  const HomeLoaded({
    required this.passwords,
    required this.categories,
    required this.filteredPasswords,
    this.searchQuery = '',
    this.selectedCategoryId = 'All',
    this.sortType = PasswordSortType.title,
    this.sortAscending = true,
    this.generatedPassword,
    this.passwordStrength,
  });

  @override
  List<Object?> get props => [
        passwords,
        categories,
        filteredPasswords,
        searchQuery,
        selectedCategoryId,
        sortType,
        sortAscending,
        generatedPassword,
        passwordStrength,
      ];

  HomeLoaded copyWith({
    List<Password>? passwords,
    List<Category>? categories,
    List<Password>? filteredPasswords,
    String? searchQuery,
    String? selectedCategoryId,
    PasswordSortType? sortType,
    bool? sortAscending,
    String? generatedPassword,
    int? passwordStrength,
  }) {
    return HomeLoaded(
      passwords: passwords ?? this.passwords,
      categories: categories ?? this.categories,
      filteredPasswords: filteredPasswords ?? this.filteredPasswords,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      sortType: sortType ?? this.sortType,
      sortAscending: sortAscending ?? this.sortAscending,
      generatedPassword: generatedPassword ?? this.generatedPassword,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordAdded extends HomeState {
  final Password password;

  const PasswordAdded(this.password);

  @override
  List<Object?> get props => [password];
}

class PasswordUpdated extends HomeState {
  final Password password;

  const PasswordUpdated(this.password);

  @override
  List<Object?> get props => [password];
}

class PasswordDeleted extends HomeState {
  final String passwordId;

  const PasswordDeleted(this.passwordId);

  @override
  List<Object?> get props => [passwordId];
}

class PasswordToggledFavorite extends HomeState {
  final String passwordId;
  final bool isFavorite;

  const PasswordToggledFavorite(this.passwordId, this.isFavorite);

  @override
  List<Object?> get props => [passwordId, isFavorite];
}

class CategoryAdded extends HomeState {
  final Category category;

  const CategoryAdded(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryUpdated extends HomeState {
  final Category category;

  const CategoryUpdated(this.category);

  @override
  List<Object?> get props => [category];
}

class CategoryDeleted extends HomeState {
  final String categoryId;

  const CategoryDeleted(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class PasswordsExported extends HomeState {
  final String filePath;

  const PasswordsExported(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class PasswordsImported extends HomeState {
  final int importedCount;

  const PasswordsImported(this.importedCount);

  @override
  List<Object?> get props => [importedCount];
}

class PasswordGenerated extends HomeState {
  final String password;
  final int strength;

  const PasswordGenerated(this.password, this.strength);

  @override
  List<Object?> get props => [password, strength];
}

class PasswordStrengthChecked extends HomeState {
  final int strength;

  const PasswordStrengthChecked(this.strength);

  @override
  List<Object?> get props => [strength];
}