import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/core/app.dart';
import 'package:password_manager/features/home/bloc/home_bloc.dart';

void main() {
  testWidgets('App loads and shows login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => HomeBloc()),
        ],
        child: const App(),
      ),
    );

    // Wait for the app to fully load
    await tester.pumpAndSettle();

    // Verify that login page is shown (should contain "Вхід" text)
    expect(find.text('Вхід'), findsOneWidget);
  });
}
