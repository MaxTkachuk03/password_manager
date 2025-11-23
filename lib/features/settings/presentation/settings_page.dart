import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/app_bar/custom_app_bar.dart';
import '../../../core/scaffold/custom_scaffold.dart';
import '../../../core/app.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';

class SettingsPage extends StatefulWidget {
  final AppThemeNotifier? themeNotifier;
  
  const SettingsPage({super.key, this.themeNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _autoLockMinutes = 5;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 5;
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _saveAutoLockMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('auto_lock_minutes', minutes);
    setState(() {
      _autoLockMinutes = minutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.blue(
      appBar: CustomAppBar.green(
        title: 'Налаштування',
        isNeedLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Застосунок'),
          _buildThemeSetting(),
          const SizedBox(height: 24),
          _buildSectionTitle('Безпека'),
          _buildAutoLockSetting(),
          const SizedBox(height: 24),
          _buildSectionTitle('Резервна копія'),
          _buildBackupRestoreSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Про застосунок'),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeSetting() {
    // If themeNotifier is available, use it for real-time updates
    if (widget.themeNotifier != null) {
      return ListenableBuilder(
        listenable: widget.themeNotifier!,
        builder: (context, _) {
          final isDarkMode = widget.themeNotifier!.isDarkMode;
          return Card(
            child: SwitchListTile(
              title: const Text('Темна тема'),
              subtitle: const Text('Увімкнути темний режим'),
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              value: isDarkMode,
              onChanged: (value) {
                widget.themeNotifier?.setDarkMode(value);
              },
            ),
          );
        },
      );
    }
    
    // Fallback: use SharedPreferences directly if themeNotifier is not available
    return FutureBuilder<bool>(
      future: SharedPreferences.getInstance().then((prefs) => prefs.getBool('dark_mode') ?? false),
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data ?? false;
        return Card(
          child: SwitchListTile(
            title: const Text('Темна тема'),
            subtitle: const Text('Увімкнути темний режим'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (value) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('dark_mode', value);
              // Show message to restart app
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Перезапустіть застосунок для застосування теми'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAutoLockSetting() {
    return Card(
      child: ListTile(
        title: const Text('Автоблокування'),
        subtitle: Text('Блокувати застосунок через $_autoLockMinutes хвилин неактивності'),
        leading: const Icon(Icons.lock_clock),
        trailing: DropdownButton<int>(
          value: _autoLockMinutes,
          items: const [
            DropdownMenuItem(value: 0, child: Text('Ніколи')),
            DropdownMenuItem(value: 1, child: Text('1 хв')),
            DropdownMenuItem(value: 5, child: Text('5 хв')),
            DropdownMenuItem(value: 10, child: Text('10 хв')),
            DropdownMenuItem(value: 30, child: Text('30 хв')),
          ],
          onChanged: (value) {
            if (value != null) {
              _saveAutoLockMinutes(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBackupRestoreSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Резервна копія'),
            subtitle: const Text('Створити резервну копію всіх паролів'),
            leading: const Icon(Icons.backup),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.read<HomeBloc>().add(const ExportPasswords());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Створення резервної копії...'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Відновити'),
            subtitle: const Text('Відновити паролі з резервної копії'),
            leading: const Icon(Icons.restore),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                
                if (result != null && result.files.single.path != null) {
                  context.read<HomeBloc>().add(
                    ImportPasswords(result.files.single.path!),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Відновлення паролів...'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Помилка вибору файлу: $e\nБудь ласка, перезапустіть застосунок.'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Версія'),
            subtitle: Text('SecureVault v$_appVersion'),
            leading: const Icon(Icons.info),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Ліцензія'),
            subtitle: const Text('MIT License'),
            leading: const Icon(Icons.description),
            onTap: () {
              _showLicenseDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Політика конфіденційності'),
            subtitle: const Text('Як ми захищаємо ваші дані'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              _showPrivacyDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ліцензія'),
        content: const SingleChildScrollView(
          child: Text(
            'MIT License\n\n'
            'Copyright (c) 2025 SecureVault\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy\n'
            'of this software and associated documentation files (the "Software"), to deal\n'
            'in the Software without restriction, including without limitation the rights\n'
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n'
            'copies of the Software, and to permit persons to whom the Software is\n'
            'furnished to do so, subject to the following conditions:\n\n'
            'The above copyright notice and this permission notice shall be included in all\n'
            'copies or substantial portions of the Software.\n\n'
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n'
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n'
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n'
            'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n'
            'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n'
            'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n'
            'SOFTWARE.',
          ),
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Політика конфіденційності'),
        content: const SingleChildScrollView(
          child: Text(
            'SecureVault - Політика конфіденційності\n\n'
            '1. Зберігання даних\n'
            'Всі ваші паролі зберігаються локально на вашому пристрої з використанням AES-256 шифрування.\n\n'
            '2. Відсутність збору даних\n'
            'Ми не збираємо, не передаємо та не зберігаємо ваші дані на серверах.\n\n'
            '3. Безпека\n'
            'Застосунок використовує SQLCipher для захисту бази даних та YubiKey для додаткової автентифікації.\n\n'
            '4. Резервні копії\n'
            'Резервні копії створюються та зберігаються лише на вашому пристрої або в обраній вами хмарі.\n\n'
            '5. Оновлення\n'
            'Ця політика може оновлюватися. Будь ласка, перевіряйте її періодично.',
          ),
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

