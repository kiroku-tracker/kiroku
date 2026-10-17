import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Разделы бокового меню.
enum AppSection { library, groups, party, calendar, journal, search, settings }

final sectionNavigatorKeys = {
  for (final section in AppSection.values) section: GlobalKey<NavigatorState>(),
};

class AppSectionNotifier extends Notifier<AppSection> {
  @override
  AppSection build() => AppSection.library;

  void open(AppSection section) {
    if (state == section) {
      sectionNavigatorKeys[section]?.currentState?.popUntil(
        (route) => route.isFirst,
      );
    }
    state = section;
  }
}

final appSectionProvider = NotifierProvider<AppSectionNotifier, AppSection>(
  AppSectionNotifier.new,
);

/// Запрос фокуса для поля поиска.
class SearchFocusNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}

final searchFocusProvider = NotifierProvider<SearchFocusNotifier, int>(
  SearchFocusNotifier.new,
);
