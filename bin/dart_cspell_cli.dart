import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:args/args.dart';
import 'package:dart_cspell_cli/dart_cspell_cli.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('output', abbr: 'o');
  final results = parser.parse(arguments);
  final output = results["output"];
  final writer = output != null ? File(output).openWrite() : stdout;

  // https://github.com/dart-lang/glob/issues/81
  final dartFile = results.rest
      .expand((e) => Glob(e, caseSensitive: true).listSync())
      .toList();

  final names = <String>[];

  for (final entity in dartFile) {
    final file = path.normalize(path.absolute(entity.path));
    if (entity is File) {
      final result = parseFile(
        path: file,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      names.addAll(extractTopLevelNames(result.unit.childEntities));
    }
  }

  final diff = normalize(names).toSet();

  writer.writeAll(diff.toList(), "\n");
}
