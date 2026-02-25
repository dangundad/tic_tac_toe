import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('tic_tac_toe smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());

    expect(find.byType(TicTacToeApp), findsOneWidget);
  });
}
