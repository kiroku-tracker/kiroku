import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app_section.dart';
import '../../core/labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/toast.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/popup_panel.dart';
import '../../core/widgets/poster.dart';
import '../../data/database/app_database.dart';
import '../../data/database/party_history_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../player/player_session.dart';
import '../title/title_screen.dart';
import '../watch/watch_actions.dart';
import 'party_address.dart';
import 'party_controller.dart';
import 'party_pick_panel.dart';

/// Раздел «Совместный просмотр»: комната и история.
class PartyScreen extends ConsumerWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(partyProvider.select((party) => party.active));
    return SingleChildScrollView(
      padding: pagePadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Совместный просмотр',
            trailing: _NickButton(),
          ),
          const SizedBox(height: 16),
          if (active) const _Room() else const _Start(),
          const SizedBox(height: 18),
          const _HistoryPanel(),
        ],
      ),
    );
  }
}

/// Свой ник в комнате; клик открывает правку.
class _NickButton extends ConsumerWidget {
  const _NickButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    final uid = ref.watch(partyUidProvider).value ?? '';
    final name = partyName(prefs);
    return Builder(
      builder: (context) => Tooltip(
        message: 'Ник',
        child: TextButton(
          onPressed: () => showPopupPanel(
            context,
            width: 360,
            builder: (_) => const _NickPanel(),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.text,
            padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar(name: name, seed: _seed(uid, name), size: 28),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.pencil,
                size: 14,
                color: AppColors.navIdle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Правка ника: поле и ник из Discord по кнопке.
class _NickPanel extends ConsumerStatefulWidget {
  const _NickPanel();

  @override
  ConsumerState<_NickPanel> createState() => _NickPanelState();
}

class _NickPanelState extends ConsumerState<_NickPanel> {
  late final _name = TextEditingController(
    text: partyName(ref.read(appPrefsProvider).value ?? const AppPrefs()),
  );
  bool _asking = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(String value) async {
    final prefs = ref.read(appPrefsProvider.notifier);
    final party = ref.read(partyProvider.notifier);
    final name = value.trim();
    await prefs.change(
      (prefs) =>
          prefs.copyWith(partyName: name == partyDefaultName() ? '' : name),
    );
    await party.rename();
  }

  void _done() {
    _save(_name.text);
    Navigator.of(context).pop();
  }

  Future<void> _fromDiscord() async {
    setState(() {
      _asking = true;
      _error = null;
    });
    final name = await discordUserName();
    if (!mounted) return;
    setState(() => _asking = false);
    if (name == null || name.isEmpty) {
      setState(() => _error = 'Discord не запущен');
      return;
    }
    _name.text = name;
    await _save(name);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.menu,
      elevation: 12,
      shadowColor: const Color(0x85000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.menuBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ник',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            const Text('Виден друзьям в комнате', style: _small),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: true,
              onSubmitted: (_) => _done(),
              decoration: InputDecoration(
                hintText: partyDefaultName(),
                isDense: true,
              ),
            ),
            if (_error case final error?) ...[
              const SizedBox(height: 6),
              Text(
                error,
                style: const TextStyle(
                  color: AppColors.dangerText,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _asking ? null : _fromDiscord,
                  child: const Text('Взять из Discord'),
                ),
                const Spacer(),
                FilledButton(onPressed: _done, child: const Text('Сохранить')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const _muted = TextStyle(color: AppColors.muted, height: 1.45);
const _small = TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4);

BoxDecoration _panel() => BoxDecoration(
  color: AppColors.panel,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: AppColors.panelBorder),
);

/// Создать свою комнату или войти в комнату друга.
class _Start extends ConsumerStatefulWidget {
  const _Start();

  @override
  ConsumerState<_Start> createState() => _StartState();
}

class _StartState extends ConsumerState<_Start> {
  final _code = TextEditingController();
  Future<({String? address, int port, String? error})>? _room;
  AppPrefs? _roomPrefs;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final party = ref.watch(partyProvider);
    final prefs = ref.watch(appPrefsProvider).value ?? const AppPrefs();
    if (_roomPrefs?.partyNetwork != prefs.partyNetwork ||
        _roomPrefs?.partyAddress != prefs.partyAddress) {
      _roomPrefs = prefs;
      _room = partyRoom(prefs);
    }
    final notifier = ref.read(partyProvider.notifier);
    void join() => notifier.join(_code.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Пауза и перемотка общие, отставшего ждут остальные',
          style: _muted,
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: LucideIcons.housePlus,
                  title: 'Создать комнату',
                  text: 'Друзья войдут по коду комнаты',
                  child: FutureBuilder(
                    future: _room,
                    builder: (context, snapshot) {
                      final room = snapshot.data;
                      if (room?.error case final error?) {
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: AppColors.dangerText,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(appSectionProvider.notifier)
                                  .open(AppSection.settings),
                              child: const Text('Настройки'),
                            ),
                          ],
                        );
                      }
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: room != null && !party.busy
                              ? notifier.host
                              : null,
                          icon: const Icon(LucideIcons.plus),
                          label: const Text('Создать'),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  icon: LucideIcons.logIn,
                  title: 'Войти в комнату',
                  text: 'По коду от создателя комнаты',
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _code,
                          decoration: const InputDecoration(
                            hintText: 'Код, например K7Q2-M9X',
                            isDense: true,
                          ),
                          onSubmitted: party.busy ? null : (_) => join(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: party.busy ? null : join,
                        child: const Text('Войти'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (party.error case final error?) ...[
          const SizedBox(height: 12),
          Text(error, style: const TextStyle(color: AppColors.dangerText)),
        ],
      ],
    );
  }
}

/// Карточка действия: значок, название, пояснение и кнопки.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.accentText),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(text, style: _muted),
          const Spacer(),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

/// Комната: что смотрим, кто здесь и что им можно.
class _Room extends ConsumerWidget {
  const _Room();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(partyProvider);
    final host = party.role == PartyRole.host;
    final address = party.address;
    final rights = party.rights;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Комната', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 14),
              if (address != null) _CodeChip(address: address),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => ref.read(partyProvider.notifier).leave(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dangerText,
                ),
                icon: const Icon(LucideIcons.logOut),
                label: Text(host ? 'Закрыть комнату' : 'Выйти из комнаты'),
              ),
            ],
          ),
          if (party.reconnecting) ...[
            const SizedBox(height: 14),
            const _Reconnecting(),
          ],
          const SizedBox(height: 18),
          _NowWatching(party: party),
          if (!host) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  LucideIcons.keyRound,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 8),
                Text(
                  rights.isEmpty
                      ? 'Управляет только создатель комнаты'
                      : 'Вам доступно: ${[for (final right in PartyRight.values)
                          if (rights.contains(right)) right.short].join(', ')}',
                  style: _small,
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Участники',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(width: 8),
              Text('${party.people.length}', style: _muted),
            ],
          ),
          const SizedBox(height: 6),
          for (final person in party.people)
            _PersonRow(person: person, host: host),
        ],
      ),
    );
  }
}

/// Код комнаты; клик копирует его.
class _CodeChip extends ConsumerWidget {
  const _CodeChip({required this.address});

  final String address;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = partyDisplayCode(address);
    return Tooltip(
      message: 'Скопировать код',
      child: Material(
        color: AppColors.secondaryButton,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
          side: const BorderSide(color: AppColors.secondaryButtonBorder),
        ),
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));
            ref.read(toastProvider.notifier).show('Код скопирован');
          },
          hoverColor: AppColors.secondaryButtonHover,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 11, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Код', style: _small),
                const SizedBox(width: 8),
                Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  LucideIcons.copy,
                  size: 15,
                  color: AppColors.navIdle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Полоса «связь потеряна».
class _Reconnecting extends StatelessWidget {
  const _Reconnecting();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: const Row(
        children: [
          SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.dangerText,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Связь потеряна, переподключение…',
            style: TextStyle(color: AppColors.dangerText),
          ),
        ],
      ),
    );
  }
}

/// Что сейчас смотрят в комнате; клик открывает это в плеере.
class _NowWatching extends ConsumerWidget {
  const _NowWatching({required this.party});

  final PartyState party;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) => _build(context, ref));
  }

  /// Поиск тайтла под карточкой; выбранный открывается во встроенном плеере.
  void _pick(BuildContext context, WidgetRef ref) {
    final box = context.findRenderObject()! as RenderBox;
    showPopupPanel(
      context,
      width: box.size.width.clamp(320, 560),
      fromLeft: true,
      builder: (_) => PartyPickPanel(
        onPick: (anime) => watchOnSite(ref, anime, inApp: true),
      ),
    );
  }

  Widget _build(BuildContext context, WidgetRef ref) {
    final host = party.role == PartyRole.host;
    final target = party.target;
    if (target == null) {
      return _HeroFrame(
        onTap: host ? () => _pick(context, ref) : null,
        child: Row(
          children: [
            const _Cover(url: null, width: 70, height: 100),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Пока ничего не выбрано',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    host
                        ? 'Серия, открытая в плеере, появится здесь у всех'
                        : 'Серию выбирает создатель комнаты',
                    style: _muted,
                  ),
                ],
              ),
            ),
            if (host) ...[
              const SizedBox(width: 20),
              FilledButton.icon(
                onPressed: () => _pick(context, ref),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                icon: const Icon(LucideIcons.search),
                label: const Text('Выбрать тайтл'),
              ),
            ],
          ],
        ),
      );
    }
    final animeId = target.animeId;
    final anime = animeId == null
        ? null
        : ref.watch(animeProvider(animeId)).value;
    final session = ref.watch(playerSessionProvider);
    final here = session != null && '${session.uri}' == target.uri;
    final details = [
      if (target.episode case final episode?) 'Серия $episode',
      ?target.dubbing,
    ].join(' · ');
    void watch() => ref.read(partyProvider.notifier).watch();

    return _HeroFrame(
      onTap: watch,
      child: Row(
        children: [
          _Cover(url: anime?.posterUrl, width: 70, height: 100),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  target.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(details, style: _muted),
                ],
                const SizedBox(height: 12),
                _RoomStatus(party: party),
                if (party.duration > 0) ...[
                  const SizedBox(height: 12),
                  _Progress(position: party.position, duration: party.duration),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          if (host) ...[
            IconButton(
              tooltip: 'Выбрать другой тайтл',
              onPressed: () => _pick(context, ref),
              icon: const Icon(LucideIcons.search, size: 19),
            ),
            const SizedBox(width: 8),
          ],
          FilledButton.icon(
            onPressed: watch,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            icon: Icon(here ? LucideIcons.monitorPlay : LucideIcons.play),
            label: Text(here ? 'Открыть плеер' : 'Смотреть'),
          ),
        ],
      ),
    );
  }
}

/// Фон карточки «что смотрим».
class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent.withValues(alpha: 0.14), AppColors.card],
            stops: const [0, 0.65],
          ),
          borderRadius: radius,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          hoverColor: Colors.white.withValues(alpha: 0.03),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

/// Идёт просмотр, пауза или кого ждём.
class _RoomStatus extends StatelessWidget {
  const _RoomStatus({required this.party});

  final PartyState party;

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = switch (party) {
      PartyState(waiting: final waiting?) => (
        LucideIcons.hourglass,
        'Ждём: $waiting',
        AppColors.accentText,
      ),
      PartyState(playing: true) => (
        LucideIcons.play,
        'Идёт просмотр',
        AppColors.accentText,
      ),
      _ => (LucideIcons.pause, 'Пауза', AppColors.navIdle),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Сколько серии посмотрено в комнате.
class _Progress extends StatelessWidget {
  const _Progress({required this.position, required this.duration});

  final double position;
  final double duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (position / duration).clamp(0, 1),
              minHeight: 4,
              backgroundColor: AppColors.track,
              color: AppColors.progress,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('${_clock(position)} / ${_clock(duration)}', style: _small),
      ],
    );
  }
}

/// Участник: аватар, ник, что с ним, права.
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, required this.host});

  final PartyPerson person;

  /// Окно открыто у создателя комнаты: права гостей можно менять.
  final bool host;

  @override
  Widget build(BuildContext context) {
    final status = person.status;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          _Avatar(name: person.name, seed: _seed(person.uid, person.name)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        person.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (person.owner) ...[
                      const SizedBox(width: 6),
                      const Tooltip(
                        message: 'Создатель комнаты',
                        child: Icon(LucideIcons.crown, size: 14, color: _crown),
                      ),
                    ],
                    if (person.me) ...[
                      const SizedBox(width: 8),
                      const Text('вы', style: _small),
                    ],
                  ],
                ),
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${status[0].toUpperCase()}${status.substring(1)}',
                    style: _small,
                  ),
                ],
              ],
            ),
          ),
          if (!person.owner)
            for (final right in PartyRight.values)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Tooltip(
                  message: person.rights.contains(right)
                      ? right.label
                      : 'Нет права: ${right.short}',
                  child: Icon(
                    _rightIcon(right),
                    size: 15,
                    color: person.rights.contains(right)
                        ? AppColors.textSecondary
                        : AppColors.divider,
                  ),
                ),
              ),
          if (host && !person.owner) ...[
            const SizedBox(width: 4),
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Права',
                onPressed: person.uid.isEmpty
                    ? null
                    : () => showPopupPanel(
                        context,
                        width: 320,
                        builder: (_) => _RightsPanel(person: person),
                      ),
                icon: const Icon(LucideIcons.slidersHorizontal, size: 17),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _crown = Color(0xFFE0B341);

IconData _rightIcon(PartyRight right) => switch (right) {
  PartyRight.pause => LucideIcons.pause,
  PartyRight.seek => LucideIcons.fastForward,
  PartyRight.episode => LucideIcons.listVideo,
};

/// Права одного гостя: переключатели.
class _RightsPanel extends ConsumerStatefulWidget {
  const _RightsPanel({required this.person});

  final PartyPerson person;

  @override
  ConsumerState<_RightsPanel> createState() => _RightsPanelState();
}

class _RightsPanelState extends ConsumerState<_RightsPanel> {
  late final _rights = {...widget.person.rights};

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.menu,
      elevation: 12,
      shadowColor: const Color(0x85000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.menuBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Права: ${widget.person.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            const Text('Запоминаются для этого гостя', style: _small),
            const SizedBox(height: 8),
            for (final right in PartyRight.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(_rightIcon(right), size: 16, color: AppColors.navIdle),
                    const SizedBox(width: 10),
                    Expanded(child: Text(right.label)),
                    Switch(
                      value: _rights.contains(right),
                      onChanged: (on) {
                        setState(
                          () => on ? _rights.add(right) : _rights.remove(right),
                        );
                        ref.read(partyProvider.notifier).setRights(
                          widget.person.uid,
                          {..._rights},
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _avatarColors = [
  Color(0xFF6F56E8),
  Color(0xFF2F7FE0),
  Color(0xFF2E9E6E),
  Color(0xFFC77C2A),
  Color(0xFFC2507A),
  Color(0xFF2E9AA8),
  Color(0xFF8B5CC8),
];

String _seed(String uid, String name) => uid.isEmpty ? name : uid;

/// Круг с первой буквой ника; цвет постоянный для человека.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.seed, this.size = 34});

  final String name;
  final String seed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hash = seed.codeUnits.fold(
      0,
      (hash, unit) => (hash * 31 + unit) & 0x7fffffff,
    );
    final trimmed = name.trim();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _avatarColors[hash % _avatarColors.length],
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.panel, width: 2),
      ),
      child: Text(
        trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
          height: 1,
        ),
      ),
    );
  }
}

/// Сеансы совместного просмотра: что, с кем и где остановились.
class _HistoryPanel extends ConsumerWidget {
  const _HistoryPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(partyHistoryProvider).value ?? const [];
    return Panel(
      title: 'История',
      child: history.isEmpty
          ? const Text('Пока пусто', style: _muted)
          : Column(
              children: [
                for (final record in history) _HistoryRow(record: record),
              ],
            ),
    );
  }
}

/// Строка сеанса в истории.
class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.record});

  final PartySession record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeId = record.animeId;
    final anime = animeId == null
        ? null
        : ref.watch(animeProvider(animeId)).value;
    final names = ref.watch(partyPeopleProvider).value ?? const {};
    final people = [
      for (final person in partyPeople(record))
        (seed: person, name: names[person] ?? person),
    ];
    final faces = people.take(4).toList();
    final from = record.episodeFrom;
    final to = record.episodeTo;
    final episodes = to == null
        ? null
        : from == null || from == to
        ? 'Серия $to'
        : 'Серии $from–$to';
    final details = [
      ?episodes,
      if (record.position > 0) 'остановились на ${_clock(record.position)}',
    ].join(', ');

    return InkWell(
      onTap: animeId == null
          ? null
          : () => openTitle(
              context,
              animeId: animeId,
              backLabel: 'Назад к совместному просмотру',
            ),
      borderRadius: BorderRadius.circular(10),
      hoverColor: AppColors.cardHover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _Cover(url: anime?.posterUrl, width: 44, height: 62),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(details, style: _muted),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final (index, person) in faces.indexed)
                        Align(
                          widthFactor: index == faces.length - 1 ? 1 : 0.72,
                          child: _Avatar(
                            name: person.name,
                            seed: person.seed,
                            size: 22,
                          ),
                        ),
                      if (faces.isNotEmpty) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          people.isEmpty
                              ? 'Только вы'
                              : people.map((person) => person.name).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _small,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: record.role == 'host'
                  ? 'Комнату создавали вы'
                  : 'Комнату создавал друг',
              child: Icon(
                record.role == 'host' ? LucideIcons.crown : LucideIcons.logIn,
                size: 16,
                color: AppColors.navIdle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 96,
              child: Text(
                timeAgo(record.endedAt),
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(partyProvider.notifier).resume(record),
              icon: const Icon(LucideIcons.play),
              label: const Text('Продолжить'),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Удалить из истории',
              onPressed: () {
                final history = ref.read(partyHistoryRepositoryProvider);
                history.delete(record.id);
                ref
                    .read(toastProvider.notifier)
                    .show(
                      'Сеанс удалён из истории',
                      undo: () => history.save(record),
                    );
              },
              icon: const Icon(LucideIcons.trash2, size: 17),
            ),
          ],
        ),
      ),
    );
  }
}

/// Постер тайтла или заглушка.
class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.width, required this.height});

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(width > 50 ? 8 : 6);
    return SizedBox(
      width: width,
      height: height,
      child: url == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.poster,
                borderRadius: radius,
              ),
              child: Icon(
                LucideIcons.popcorn,
                size: width > 50 ? 24 : 18,
                color: AppColors.posterPlaceholder,
              ),
            )
          : Poster(url: url, borderRadius: radius),
    );
  }
}

String _clock(double seconds) {
  final total = seconds.round();
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final rest = (total % 60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$rest'
      : '$minutes:$rest';
}
