import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/library_repository.dart';
import '../../data/database/settings_repository.dart';
import '../../data/providers.dart';
import '../../system/discord_presence.dart';
import '../../system/discord_rpc.dart';

/// Порт комнаты по умолчанию.
const partyPort = 47160;

/// Адрес и порт из строки «IP» или «IP:порт».
({String host, int port})? parsePartyAddress(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final colon = text.lastIndexOf(':');
  if (colon < 0) return (host: text, port: partyPort);
  final port = int.tryParse(text.substring(colon + 1));
  final host = text.substring(0, colon).trim();
  if (host.isEmpty || port == null || port <= 0 || port > 65535) return null;
  return (host: host, port: port);
}

/// Буквы кода комнаты: без похожих друг на друга I, L, O, U.
const _codeLetters = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Контрольная сумма кода: ловит опечатки.
int _codeCheck(int value, int bytes) {
  var check = 0;
  for (var shift = (bytes - 1) * 8; shift >= 0; shift -= 8) {
    check = (check * 5 + ((value >> shift) & 255)) & 255;
  }
  return check;
}

/// Код комнаты из адреса: контрольная сумма, IP и порт, если он не
/// стандартный. Для имени компьютера вместо IP кода нет.
String? partyCode(String address) {
  final parsed = parsePartyAddress(address);
  if (parsed == null) return null;
  final ip = InternetAddress.tryParse(parsed.host);
  if (ip == null || ip.type != InternetAddressType.IPv4) return null;
  var value = 0;
  for (final byte in ip.rawAddress) {
    value = value << 8 | byte;
  }
  var length = 7;
  var bytes = 4;
  if (parsed.port != partyPort) {
    value = value << 16 | parsed.port;
    length = 10;
    bytes = 6;
  }
  final spare = length * 5 - bytes * 8;
  value |= (_codeCheck(value, bytes) & ((1 << spare) - 1)) << (bytes * 8);
  final letters = [
    for (var index = length - 1; index >= 0; index--)
      _codeLetters[(value >> (5 * index)) & 31],
  ].join();
  final half = (length + 1) ~/ 2;
  return '${letters.substring(0, half)}-${letters.substring(half)}';
}

/// Адрес и порт из кода комнаты.
({String host, int port})? parsePartyCode(String input) {
  final text = input
      .toUpperCase()
      .replaceAll(RegExp(r'[\s-]'), '')
      .replaceAll('O', '0')
      .replaceAll(RegExp('[IL]'), '1');
  if (text.length != 7 && text.length != 10) return null;
  var value = 0;
  for (final letter in text.split('')) {
    final digit = _codeLetters.indexOf(letter);
    if (digit < 0) return null;
    value = value << 5 | digit;
  }
  final bytes = text.length == 7 ? 4 : 6;
  final check = value >> (bytes * 8);
  value &= (1 << (bytes * 8)) - 1;
  final spare = text.length * 5 - bytes * 8;
  if (check != _codeCheck(value, bytes) & ((1 << spare) - 1)) return null;
  var port = partyPort;
  if (bytes == 6) {
    port = value & 0xFFFF;
    value >>= 16;
    if (port == 0) return null;
  }
  final host = [
    for (var shift = 24; shift >= 0; shift -= 8) (value >> shift) & 255,
  ].join('.');
  return (host: host, port: port);
}

/// Как показать комнату людям: кодом, а если его нет, адресом.
String partyDisplayCode(String address) {
  final parsed = parsePartyCode(address) ?? parsePartyAddress(address);
  if (parsed == null) return address;
  return partyCode('${parsed.host}:${parsed.port}') ?? address.trim();
}

/// Виртуальные сети, через которые друзья видят этот компьютер.
const partyVpns = 'Radmin VPN, Hamachi, ZeroTier, Tailscale';

/// Адрес этого компьютера в виртуальной сети: по названию адаптера, а у
/// Radmin VPN (26.*) и Hamachi (25.*) ещё по адресу.
Future<String?> vpnAddress() async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final vpn in ['radmin', 'hamachi', 'zerotier', 'tailscale']) {
      for (final interface in interfaces) {
        if (interface.name.toLowerCase().contains(vpn) &&
            interface.addresses.isNotEmpty) {
          return interface.addresses.first.address;
        }
      }
    }
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (address.address.startsWith('26.') ||
            address.address.startsWith('25.')) {
          return address.address;
        }
      }
    }
  } on Object {
    // Ошибка пропускается.
  }
  return null;
}

/// Адрес комнаты для друзей и порт, или текст ошибки.
Future<({String? address, int port, String? error})> partyRoom(
  AppPrefs prefs,
) async {
  switch (prefs.partyNetwork) {
    case PartyNetwork.vpn:
      final address = await vpnAddress();
      return address == null
          ? (
              address: null,
              port: partyPort,
              error: 'Не найдена виртуальная сеть ($partyVpns)',
            )
          : (address: address, port: partyPort, error: null);
    case PartyNetwork.custom:
      final parsed = parsePartyAddress(prefs.partyAddress);
      return parsed == null
          ? (
              address: null,
              port: partyPort,
              error: 'Адрес комнаты не указан в настройках',
            )
          : (
              address: prefs.partyAddress.trim(),
              port: parsed.port,
              error: null,
            );
  }
}

/// Ник в комнате: из настроек или имя пользователя Windows.
String partyName(AppPrefs prefs) {
  final name = prefs.partyName.trim();
  return name.isNotEmpty ? name : partyDefaultName();
}

/// Ник, пока свой не задан: имя пользователя Windows.
String partyDefaultName() => Platform.environment['USERNAME'] ?? 'Гость';

/// Постоянный номер этого Kiroku в совместном просмотре и имя. Номер
/// создаётся один раз и хранится в настройках.
Future<({String uid, String name})> partyIdentity(
  SettingsRepository settings,
  AppPrefs prefs,
) async {
  final saved = await settings.readAll();
  var uid = saved['party.uid'] ?? '';
  if (uid.isEmpty) {
    uid = newId();
    await settings.write('party.uid', uid);
  }
  return (uid: uid, name: partyName(prefs));
}

/// Имя пользователя запущенного Discord.
Future<String?> discordUserName() async {
  final rpc = DiscordRpc(DiscordPresence.clientId);
  try {
    if (!await rpc.connect()) return null;
    return rpc.userName;
  } on Object {
    return null;
  } finally {
    rpc.close();
  }
}

/// Постоянный номер этого Kiroku в совместном просмотре.
final partyUidProvider = FutureProvider<String>(
  (ref) async => (await partyIdentity(
    ref.read(settingsRepositoryProvider),
    const AppPrefs(),
  )).uid,
);
