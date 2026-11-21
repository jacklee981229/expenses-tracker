import 'dart:io';

import 'package:expense_tracker/core/constants/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Settings shows a copy of the version, since reading the built one would
/// need a package; this keeps the copy honest.
void main() {
  test('Settings shows the version pubspec.yaml builds', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\S+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'pubspec.yaml needs version: x.y.z+n');
    expect(kAppVersion, match!.group(1));
    expect(kAppBuildNumber, match.group(2));
  });

  test('CHANGELOG.md has an entry for this version', () {
    final changelog = File('CHANGELOG.md').readAsStringSync();
    expect(changelog, contains('## $kAppVersion '));
  });
}
