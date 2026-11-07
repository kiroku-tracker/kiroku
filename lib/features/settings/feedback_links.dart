import 'dart:io';

import '../../system/updates.dart';

/// Форма новой ошибки на GitHub с версиями Kiroku и Windows.
Uri bugReportUri(AppVersion? version) => _newIssue({
  'template': 'bug_report.yml',
  if (version != null) 'version': '$version',
  'windows': Platform.operatingSystemVersion.replaceAll('"', ''),
});

/// Форма новой идеи на GitHub.
Uri ideaUri() => _newIssue({'template': 'idea.yml'});

Uri _newIssue(Map<String, String> query) =>
    Uri.https('github.com', '/${UpdateClient.repository}/issues/new', query);
