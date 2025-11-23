import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/core/app_bar/custom_app_bar.dart';
import 'package:password_manager/core/scaffold/custom_scaffold.dart';
import 'package:password_manager/features/authentication/bloc/authentication_bloc.dart';
import 'package:password_manager/features/authentication/widgets/yubikey_status_widget.dart';
import 'package:password_manager/features/home/presentation/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationBloc()..add(CheckYubiKeyConnection()),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccess) {
            // Navigate to home page after successful authentication
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        },
        child: CustomScaffold.blue(
          appBar: CustomAppBar.green(
            title: 'Вхід',
          ),
          body: Column(
            children: [
              const YubiKeyStatusWidget(),
              Expanded(
                child: Center(
                  child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      return _buildAuthenticationButtons(context, state);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticationButtons(BuildContext context, AuthenticationState state) {
    if (state is AuthenticationLoading) {
      return const CircularProgressIndicator();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.read<AuthenticationBloc>().add(Authenticate());
          },
          icon: const Icon(Icons.security),
          label: const Text('Увійти з YubiKey'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        if (state is YubiKeyConnected) ...[
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthenticationBloc>().add(GenerateTOTP());
            },
            icon: const Icon(Icons.timer),
            label: const Text('Згенерувати TOTP'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              context.read<AuthenticationBloc>().add(PerformHardwareConfirmation());
            },
            icon: const Icon(Icons.touch_app),
            label: const Text('Апаратне підтвердження'),
          ),
        ],
        if (state is TOTPGenerated) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              children: [
                const Text(
                  'TOTP Код:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.totpCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (state is AuthenticationSuccess) ...[
          const SizedBox(height: 16),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
          const SizedBox(height: 8),
          const Text(
            'Автентифікація успішна!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}
