import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import 'package:password_manager/features/home/bloc/home_state.dart';
import 'package:password_manager/features/home/widgets/add_password_floating_button.dart';
import 'package:password_manager/features/settings/presentation/settings_page.dart';
import '../../../core/app_bar/custom_app_bar.dart';
import '../../../core/scaffold/custom_scaffold.dart';
import '../bloc/home_bloc.dart';
import '../widgets/password_list_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter_widget.dart';
import 'add_password_page.dart';
import 'edit_password_page.dart';
import 'password_details_page.dart';
import '../../login/presentation/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadPasswords());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is PasswordsExported) {
          _showExportSuccessDialog(context, state.filePath);
        } else if (state is PasswordsImported) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Імпортовано ${state.importedCount} паролів'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: CustomScaffold.blue(
        appBar: CustomAppBar.green(
          title: 'SecureVault',
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Налаштування'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup),
                    SizedBox(width: 8),
                    Text('Резервна копія'),
                  ],
                ),
              ),
              ],
            ),
          ],
        ),
        body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              context.read<HomeBloc>().add(SearchPasswords(value));
            },
          ),
          const SizedBox(height: 8),
          CategoryFilterWidget(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              context.read<HomeBloc>().add(FilterByCategory(category));
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is HomeLoaded) {
                  return PasswordListWidget(
                    passwords: state.passwords,
                    onPasswordTap: (password) => _showPasswordDetails(context, password),
                    onPasswordEdit: (password) => _editPassword(context, password),
                    onPasswordDelete: (password) => _deletePassword(context, password),
                  );
                } else if (state is HomeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Помилка завантаження',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<HomeBloc>().add(LoadPasswords()),
                          child: const Text('Повторити'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          AddPasswordFloatingButton(
        onPressed: () => _addPassword(context),
      ),
        ],
      ),
      // floatingActionButton: 
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід'),
        content: const Text('Ви впевнені, що хочете вийти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                (route) => false,
              );
            },
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SettingsPage(),
          ),
        );
        break;
      case 'backup':
        _showBackupDialog(context);
        break;
    }
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Резервна копія'),
        content: const Text('Створити резервну копію всіх паролів у форматі JSON?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HomeBloc>().add(const ExportPasswords());
            },
            child: const Text('Створити'),
          ),
        ],
      ),
    );
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) async {
    // Try to share the file
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Резервна копія SecureVault',
      );
    } catch (e) {
      // If share fails, show dialog with file path
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Резервну копію створено'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Файл збережено:'),
                const SizedBox(height: 8),
                SelectableText(
                  filePath,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('Ви можете знайти файл за цим шляхом.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Закрити'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _addPassword(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPasswordPage(),
      ),
    );
    // Reload passwords after returning from add page
    if (mounted) {
      context.read<HomeBloc>().add(LoadPasswords());
    }
  }

  void _showPasswordDetails(BuildContext context, dynamic password) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PasswordDetailsPage(password: password),
      ),
    );
  }

  void _editPassword(BuildContext context, dynamic password) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPasswordPage(password: password),
      ),
    );
  }

  void _deletePassword(BuildContext context, dynamic password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалення пароля'),
        content: Text('Видалити пароль для "${password.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HomeBloc>().add(DeletePassword(password.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }
}