import 'package:flutter/material.dart';

class PasswordDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final bool isConfirmPassword;
  final String? confirmPasswordHint;

  const PasswordDialog({
    super.key,
    required this.title,
    this.hint,
    this.isConfirmPassword = false,
    this.confirmPasswordHint,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? hint,
    bool isConfirmPassword = false,
    String? confirmPasswordHint,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => PasswordDialog(
        title: title,
        hint: hint,
        isConfirmPassword: isConfirmPassword,
        confirmPasswordHint: confirmPasswordHint,
      ),
    );
  }

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: widget.hint ?? 'Пароль',
                  hintText: widget.hint ?? 'Введіть пароль',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пароль не може бути порожнім';
                  }
                  if (value.length < 4) {
                    return 'Пароль має містити мінімум 4 символи';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              if (widget.isConfirmPassword) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: widget.confirmPasswordHint ?? 'Підтвердіть пароль',
                    hintText: widget.confirmPasswordHint ?? 'Введіть пароль ще раз',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Паролі не співпадають';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Підтвердити'),
        ),
      ],
    );
  }
}

