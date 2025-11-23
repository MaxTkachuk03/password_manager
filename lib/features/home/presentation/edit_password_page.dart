import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../models/password_model.dart';
import '../models/category_model.dart';
import '../../../core/scaffold/custom_scaffold.dart';
import '../../../core/app_bar/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';

class EditPasswordPage extends StatefulWidget {
  final Password password;

  const EditPasswordPage({super.key, required this.password});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _websiteController;
  late final TextEditingController _notesController;

  late String _selectedCategoryId;
  bool _obscurePassword = true;
  int _passwordStrength = 0;
  List<Category> _categories = [];
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing password data
    _titleController = TextEditingController(text: widget.password.title);
    _usernameController = TextEditingController(text: widget.password.username);
    _passwordController = TextEditingController(text: widget.password.password);
    _websiteController = TextEditingController(text: widget.password.website);
    _notesController = TextEditingController(text: widget.password.notes);
    _selectedCategoryId = widget.password.categoryId;
    _passwordStrength = widget.password.strength;

    context.read<HomeBloc>().add(LoadCategories());
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = Password.calculateStrength(_passwordController.text);
    });
    context.read<HomeBloc>().add(
      CheckPasswordStrength(_passwordController.text),
    );
  }

  void _generatePassword() {
    context.read<HomeBloc>().add(
      const GeneratePassword(
        length: 16,
        includeUppercase: true,
        includeLowercase: true,
        includeNumbers: true,
        includeSymbols: true,
      ),
    );
  }

  void _showPasswordGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => _PasswordGeneratorDialog(
        onPasswordGenerated: (password) {
          setState(() {
            _passwordController.text = password;
            _passwordStrength = Password.calculateStrength(password);
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _updatePassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });
      final updatedPassword = widget.password.copyWith(
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        website: _websiteController.text.trim(),
        notes: _notesController.text.trim(),
        categoryId: _selectedCategoryId,
        updatedAt: DateTime.now(),
        strength: _passwordStrength,
      );

      context.read<HomeBloc>().add(UpdatePassword(updatedPassword));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          setState(() {
            _isUpdating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is PasswordGenerated) {
          setState(() {
            _passwordController.text = state.password;
            _passwordStrength = state.strength;
          });
        } else if (state is HomeLoaded) {
          setState(() {
            _categories = state.categories;
          });
          // Only show success and pop if we were updating
          if (_isUpdating) {
            setState(() {
              _isUpdating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Пароль успішно оновлено'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pop();
          }
        }
      },
      child: CustomScaffold.blue(
        appBar: CustomAppBar.green(
          title: 'Редагувати пароль',
          isNeedLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading && _categories.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Назва *',
                        hintText: 'Наприклад: Gmail',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Будь ласка, введіть назву';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Ім\'я користувача',
                        hintText: 'user@example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Пароль *',
                        hintText: 'Введіть пароль',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show generate button when password is empty or always
                            IconButton(
                              icon: const Icon(Icons.autorenew),
                              tooltip:
                                  'Згенерувати пароль (довге натискання - налаштування)',
                              onPressed: _generatePassword,
                              onLongPress: _showPasswordGeneratorDialog,
                            ),
                            IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Будь ласка, введіть пароль';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Password strength indicator
                    if (_passwordController.text.isNotEmpty)
                      _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 16),

                    // Website field
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Веб-сайт',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Категорія',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(category.icon, color: category.color),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes field
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Примітки',
                        hintText: 'Додаткові примітки...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Update button
                    ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenRegular,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Оновити',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final strengthText = _getStrengthText(_passwordStrength);
    final strengthColor = _getStrengthColor(_passwordStrength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Сила пароля: ',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (_passwordStrength + 1) / 6,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 4,
        ),
      ],
    );
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Дуже слабкий';
      case 2:
        return 'Слабкий';
      case 3:
        return 'Середній';
      case 4:
        return 'Сильний';
      case 5:
        return 'Дуже сильний';
      default:
        return 'Невідомо';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _PasswordGeneratorDialog extends StatefulWidget {
  final Function(String) onPasswordGenerated;

  const _PasswordGeneratorDialog({required this.onPasswordGenerated});

  @override
  State<_PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<_PasswordGeneratorDialog> {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    context.read<HomeBloc>().add(
      GeneratePassword(
        length: _length,
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is PasswordGenerated) {
          setState(() {
            _generatedPassword = state.password;
          });
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Генератор паролів',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generatedPassword.isNotEmpty
                            ? _generatedPassword
                            : 'Генерація...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _generatedPassword),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Пароль скопійовано!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Довжина: $_length',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Slider(
                value: _length.toDouble(),
                min: 8,
                max: 32,
                divisions: 24,
                onChanged: (value) {
                  setState(() {
                    _length = value.round();
                  });
                  _generatePassword();
                },
              ),
              const SizedBox(height: 16),
              _buildCheckbox('Великі літери (A-Z)', _includeUppercase, (value) {
                setState(() => _includeUppercase = value!);
                _generatePassword();
              }),
              _buildCheckbox('Малі літери (a-z)', _includeLowercase, (value) {
                setState(() => _includeLowercase = value!);
                _generatePassword();
              }),
              _buildCheckbox('Цифри (0-9)', _includeNumbers, (value) {
                setState(() => _includeNumbers = value!);
                _generatePassword();
              }),
              _buildCheckbox('Символи (!@#\$%)', _includeSymbols, (value) {
                setState(() => _includeSymbols = value!);
                _generatePassword();
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _generatePassword,
                    child: const Text('Новий пароль'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.onPasswordGenerated(_generatedPassword);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Використати'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
