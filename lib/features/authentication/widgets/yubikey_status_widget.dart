import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/features/authentication/bloc/authentication_bloc.dart';

class YubiKeyStatusWidget extends StatelessWidget {
  const YubiKeyStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getStatusIcon(state),
                      color: _getStatusColor(state),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Статус YubiKey',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusText(state),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(state),
                  ),
                ),
                if (state is YubiKeyConnected) ...[
                  const SizedBox(height: 8),
                  _buildYubiKeyInfo(state.yubiKeyInfo),
                ],
                if (state is AuthenticationError) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(AuthenticationState state) {
    if (state is YubiKeyConnected) {
      return Icons.bluetooth_connected;
    } else if (state is AuthenticationLoading) {
      return Icons.bluetooth_searching;
    } else if (state is AuthenticationError) {
      return Icons.bluetooth_disabled;
    } else {
      return Icons.bluetooth_disabled;
    }
  }

  Color _getStatusColor(AuthenticationState state) {
    if (state is YubiKeyConnected) {
      return Colors.green;
    } else if (state is AuthenticationLoading) {
      return Colors.orange;
    } else if (state is AuthenticationError) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _getStatusText(AuthenticationState state) {
    if (state is YubiKeyConnected) {
      return 'YubiKey підключено';
    } else if (state is AuthenticationLoading) {
      return 'Перевірка підключення...';
    } else if (state is AuthenticationError) {
      return 'Помилка підключення';
    } else {
      return 'YubiKey не підключено';
    }
  }

  Widget _buildYubiKeyInfo(Map<String, dynamic> info) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info['name'] != null)
            Text('Назва: ${info['name']}'),
          if (info['version'] != null)
            Text('Версія: ${info['version']}'),
          if (info['serial'] != null)
            Text('Серійний номер: ${info['serial']}'),
        ],
      ),
    );
  }
}