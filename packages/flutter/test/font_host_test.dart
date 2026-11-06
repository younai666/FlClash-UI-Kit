import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flclash_ui_kit/flclash_ui_kit.dart';

void main() {
  testWidgets(
    'the host keeps the original Windows Chinese fallback in both themes',
    (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        late ThemeData theme;
        await tester.pumpWidget(
          KitApp(
            liquidGlass: null,
            themeMode: mode,
            locale: const Locale('zh'),
            home: Builder(
              builder: (context) {
                theme = Theme.of(context);
                return const Surface(child: Text('仪表盘 · Aa 123'));
              },
            ),
          ),
        );
        expect(theme.bodyTextStyle.fontFamily, 'Segoe UI');
        expect(
          theme.bodyTextStyle.fontFamilyFallback,
          contains('Microsoft YaHei UI'),
        );
        expect(
          theme.displayTextStyle.fontFamilyFallback,
          contains('Microsoft YaHei UI'),
        );
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('host font configuration is preserved', (tester) async {
    late ThemeData theme;
    await tester.pumpWidget(
      KitApp(
        liquidGlass: null,
        fontFamily: 'HostSans',
        fontFamilyFallback: const ['HostCJK'],
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const Surface(child: Text('Host'));
          },
        ),
      ),
    );
    expect(theme.bodyTextStyle.fontFamily, 'HostSans');
    expect(theme.bodyTextStyle.fontFamilyFallback, ['HostCJK']);
  });
}
