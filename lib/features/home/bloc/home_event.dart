import 'package:equatable/equatable.dart';
import '../models/password_model.dart';
import '../models/category_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadPasswords extends HomeEvent {
  const LoadPasswords();
}

class LoadCategories extends HomeEvent {
  const LoadCategories();
}

class AddPassword extends HomeEvent {
  final Password password;

  const AddPassword(this.password);

  @override
  List<Object?> get props => [password];
}

class UpdatePassword extends HomeEvent {
  final Password password;

  const UpdatePassword(this.password);

  @override
  List<Object?> get props => [password];
}

class DeletePassword extends HomeEvent {
  final String passwordId;

  const DeletePassword(this.passwordId);

  @override
  List<Object?> get props => [passwordId];
}

class RestorePassword extends HomeEvent {
  final Password password;

  const RestorePassword(this.password);

  @override
  List<Object?> get props => [password];
}

class ToggleFavoritePassword extends HomeEvent {
  final String passwordId;

  const ToggleFavoritePassword(this.passwordId);

  @override
  List<Object?> get props => [passwordId];
}

class SearchPasswords extends HomeEvent {
  final String query;

  const SearchPasswords(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends HomeEvent {
  final String categoryId;

  const FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SortPasswords extends HomeEvent {
  final PasswordSortType sortType;
  final bool ascending;

  const SortPasswords(this.sortType, this.ascending);

  @override
  List<Object?> get props => [sortType, ascending];
}

class AddCategory extends HomeEvent {
  final Category category;

  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends HomeEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends HomeEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ExportPasswords extends HomeEvent {
  const ExportPasswords();
}

class ImportPasswords extends HomeEvent {
  final String filePath;

  const ImportPasswords(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class GeneratePassword extends HomeEvent {
  final int length;
  final bool includeUppercase;
  final bool includeLowercase;
  final bool includeNumbers;
  final bool includeSymbols;

  const GeneratePassword({
    this.length = 16,
    this.includeUppercase = true,
    this.includeLowercase = true,
    this.includeNumbers = true,
    this.includeSymbols = true,
  });

  @override
  List<Object?> get props => [
        length,
        includeUppercase,
        includeLowercase,
        includeNumbers,
        includeSymbols,
      ];
}

class CheckPasswordStrength extends HomeEvent {
  final String password;

  const CheckPasswordStrength(this.password);

  @override
  List<Object?> get props => [password];
}

enum PasswordSortType {
  title,
  username,
  website,
  createdAt,
  updatedAt,
  strength,
  favorite, dateCreated, dateUpdated,
}