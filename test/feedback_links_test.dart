import 'package:flutter_test/flutter_test.dart';
import 'package:kiroku/features/settings/feedback_links.dart';
import 'package:kiroku/system/updates.dart';

void main() {
  test('форма ошибки получает версии', () {
    final uri = bugReportUri(const AppVersion(0, 5, 1));
    expect(uri.host, 'github.com');
    expect(uri.path, '/kiroku-tracker/kiroku/issues/new');
    expect(uri.queryParameters['template'], 'bug_report.yml');
    expect(uri.queryParameters['version'], '0.5.1');
    expect(uri.queryParameters['windows'], isNotEmpty);
    expect(uri.queryParameters['windows'], isNot(contains('"')));
  });

  test('без версии поле не заполняется', () {
    expect(bugReportUri(null).queryParameters.containsKey('version'), false);
  });

  test('форма идеи', () {
    expect(ideaUri().queryParameters, {'template': 'idea.yml'});
  });
}
