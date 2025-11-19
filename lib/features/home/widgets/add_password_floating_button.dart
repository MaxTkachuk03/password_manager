import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import 'package:password_manager/features/home/bloc/home_state.dart';
import '../bloc/home_bloc.dart';

class AddPasswordFloatingButton extends StatefulWidget {
  const AddPasswordFloatingButton({
    Key? key,
    required void Function() onPressed,
  }) : super(key: key);

  @override
  State<AddPasswordFloatingButton> createState() =>
      _AddPasswordFloatingButtonState();
}

class _AddPasswordFloatingButtonState extends State<AddPasswordFloatingButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.75).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [if (_isExpanded) ..._buildActionButtons(), _buildMainButton()],
    );
  }

  List<Widget> _buildActionButtons() {
    return [
      _buildActionButton(
        icon: Icons.password,
        label: 'Генерувати пароль',
        color: Colors.purple,
        onPressed: _generatePassword,
        top: 140,
      ),
      _buildActionButton(
        icon: Icons.file_upload,
        label: 'Імпортувати',
        color: Colors.orange,
        onPressed: _importPasswords,
        top: 90,
      ),
      _buildActionButton(
        icon: Icons.file_download,
        label: 'Експортувати',
        color: Colors.green,
        onPressed: _exportPasswords,
        top: 40,
      ),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required double top,
  }) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          margin: EdgeInsets.only(bottom: top),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      onPressed();
                      _toggleExpanded();
                    },
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: FloatingActionButton.extended(
        onPressed: _toggleExpanded,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateAnimation.value * 2 * 3.14159,
              child: const Icon(Icons.add),
            );
          },
        ),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isExpanded ? 'Закрити' : 'Додати',
            key: ValueKey(_isExpanded),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _generatePassword() {
    _showPasswordGeneratorDialog();
  }

  void _importPasswords() {
    _showImportDialog();
  }

  void _exportPasswords() {
    _showExportDialog();
  }

  void _showPasswordGeneratorDialog() {
    showDialog(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );
  }

  void _showImportDialog() {
    showDialog(context: context, builder: (context) => const ImportDialog());
  }

  void _showExportDialog() {
    showDialog(context: context, builder: (context) => const ExportDialog());
  }
}

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({Key? key}) : super(key: key);

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
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
                      onPressed: () => _copyPassword(_generatedPassword),
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
                    onPressed: () => _addPasswordWithGenerated(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Додати пароль'),
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

  void _copyPassword(String password) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пароль скопійовано!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addPasswordWithGenerated() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Відкриття форми додавання пароля...')),
    );
  }
}

class ImportDialog extends StatelessWidget {
  const ImportDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Імпортувати паролі',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Оберіть формат файлу для імпорту:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildImportOption(
              context,
              'CSV файл',
              'Імпортувати з CSV файлу',
              Icons.table_chart,
              Colors.blue,
              () => _importFromCSV(context),
            ),
            const SizedBox(height: 8),
            _buildImportOption(
              context,
              'JSON файл',
              'Імпортувати з JSON файлу',
              Icons.code,
              Colors.green,
              () => _importFromJSON(context),
            ),
            const SizedBox(height: 8),
            _buildImportOption(
              context,
              '1Password',
              'Імпортувати з 1Password',
              Icons.security,
              Colors.orange,
              () => _importFrom1Password(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _importFromCSV(BuildContext context) {
    Navigator.of(context).pop();
    context.read<HomeBloc>().add(ImportPasswords('csv'));
  }

  void _importFromJSON(BuildContext context) {
    Navigator.of(context).pop();
    context.read<HomeBloc>().add(ImportPasswords('json'));
  }

  void _importFrom1Password(BuildContext context) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Імпорт з 1Password буде доступний у майбутніх версіях'),
      ),
    );
  }
}

class ExportDialog extends StatelessWidget {
  const ExportDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Експортувати паролі',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Оберіть формат експорту:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildExportOption(
              context,
              'CSV файл',
              'Експортувати в CSV формат',
              Icons.table_chart,
              Colors.blue,
              () => _exportToCSV(context),
            ),
            const SizedBox(height: 8),
            _buildExportOption(
              context,
              'JSON файл',
              'Експортувати в JSON формат',
              Icons.code,
              Colors.green,
              () => _exportToJSON(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _exportToCSV(BuildContext context) {
    Navigator.of(context).pop();
    context.read<HomeBloc>().add(ExportPasswords('csv'));
  }

  void _exportToJSON(BuildContext context) {
    Navigator.of(context).pop();
    context.read<HomeBloc>().add(ExportPasswords('json'));
  }
}
