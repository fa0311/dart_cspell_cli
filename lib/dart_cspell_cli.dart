import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';

List<String> extractTopLevelNames(Iterable<SyntacticEntity> node) {
  final names = <String>[];
  for (final entity in node) {
    switch (entity) {
      case TopLevelVariableDeclaration():
        names.addAll(entity.childEntities
            .whereType<VariableDeclarationList>()
            .expand((e) => e.variables.map((e) => e.name.lexeme)));
      case FunctionDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(entity.childEntities
            .whereType<FunctionExpression>()
            .expand((e) => extractParameterNames(e.childEntities)));
      case ClassDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(extractConstructorNames(entity.childEntities));
      case EnumDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(entity.childEntities
            .whereType<EnumConstantDeclaration>()
            .map((e) => e.name.lexeme));
        names.addAll(extractConstructorNames(entity.childEntities));
      case MixinDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(extractConstructorNames(entity.childEntities));
      case ExtensionDeclaration():
        if (entity.name != null) {
          names.add(entity.name!.lexeme);
        }
        names.addAll(extractConstructorNames(entity.childEntities));
      case GenericTypeAlias():
        names.add(entity.name.lexeme);
        names.addAll(entity.childEntities
            .whereType<GenericFunctionType>()
            .expand((e) => extractParameterNames(e.childEntities)));
      case _:
      // print("not implemented ${entity.runtimeType}");
    }
  }
  return names;
}

List<String> extractParameterNames(Iterable<SyntacticEntity> node) {
  final names = <String>[];
  for (final entity in node) {
    switch (entity) {
      case FormalParameterList():
        names.addAll(entity.childEntities
            .whereType<DefaultFormalParameter>()
            .expand((e) => e.childEntities
                .whereType<SimpleFormalParameter>()
                .map((e) => e.name!.lexeme)));

      case _:
      // print("not implemented ${entity.runtimeType}");
    }
  }
  return names;
}

List<String> extractConstructorNames(Iterable<SyntacticEntity> node) {
  final names = <String>[];
  for (final entity in node) {
    switch (entity) {
      case ConstructorDeclaration():
        if (entity.name != null) {
          names.add(entity.name!.lexeme);
        }
        names.addAll(extractParameterNames(entity.childEntities));
      case MethodDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(extractParameterNames(entity.childEntities));
      case FieldDeclaration():
        names.addAll(entity.childEntities
            .whereType<VariableDeclarationList>()
            .expand((e) => e.variables.map((e) => e.name.lexeme)));

      case _:
      // print("not implemented ${entity.runtimeType}");
    }
  }
  return names;
}

Iterable<String> splitWords(String name) {
  final result = <List<String>>[];
  result.add([]);
  for (final c in name.split("")) {
    if (["_", "-", " "].contains(c)) {
      result.add([]);
    } else if (c.toUpperCase() == c) {
      result.add([c.toLowerCase()]);
    } else {
      result.last.add(c);
    }
  }
  return result.map((e) => e.join(""));
}

List<String> normalize(List<String> names) {
  return names
      .where((e) => !e.startsWith("_"))
      .map((e) => e.replaceAll(RegExp(r"\d"), ""))
      .expand((e) => splitWords(e))
      .where((e) => e.length > 3)
      .toList();
}

Future<List<String>> getCspellWords() async {
  final cspellDictionaryPathList = [
    // "cspell-dicts/dictionaries/en_US/src/en_US.txt", // 194
    // "cspell-dicts/dictionaries/en_GB-MIT/src/wordsEnGb.txt", //189
    // "cspell-dicts/dictionaries/en_GB/src/wordsEnGb.txt", // 189
    // "cspell-dicts/dictionaries/companies/src/companies.txt",
    // "cspell-dicts/dictionaries/software-terms/dict/computing-acronyms.txt",
    // "cspell-dicts/dictionaries/software-terms/dict/networkingTerms.txt",
    // "cspell-dicts/dictionaries/software-terms/dict/softwareTerms.txt",
    // "cspell-dicts/dictionaries/software-terms/dict/webServices.txt",
    // "cspell-dicts/dictionaries/fonts/dict/fonts.txt",
    // "cspell-dicts/dictionaries/typescript/dict/typescript.txt",
    // "cspell-dicts/dictionaries/node/dict/node.txt", // 190
    // "cspell-dicts/dictionaries/php/dict/php.txt",
    // "cspell-dicts/dictionaries/golang/dict/go.txt",
    // "cspell-dicts/dictionaries/python/dict/python-common.txt",
    // "cspell-dicts/dictionaries/python/dict/python.txt",
    // "cspell-dicts/dictionaries/powershell/dict/powershell.txt",
    // "cspell-dicts/dictionaries/html/dict/html.txt", // 187
    // "cspell-dicts/dictionaries/css/dict/css.txt",

// listenable - aws*                 node_modules\@cspell\dict-aws\dict\aws.txt
// listenable - companies*           node_modules\@cspell\dict-companies\dict\companies.txt
// listenable - computing-acronyms*  node_modules\@cspell\dict-software-terms\dict\computing-acronyms.txt
// listenable - cryptocurrencies*    node_modules\@cspell\dict-cryptocurrencies\dict\cryptocurrencies.txt
// listenable * en_us*               node_modules\@cspell\dict-en_us\en_US.trie.gz
// listenable - en-common-misspelli* node_modules\@cspell\dict-en-common-misspellings\dict-en.yaml
// listenable * en-gb                node_modules\@cspell\dict-en-gb\en_GB.trie.gz
// listenable - filetypes*           node_modules\@cspell\dict-filetypes\filetypes.txt.gz
// listenable - public-licenses*     node_modules\@cspell\dict-public-licenses\public-licenses.txt.gz
// listenable - software-term-sugge* node_modules\@cspell\dict-software-terms\cspell-corrections.yaml
// listenable - softwareTerms*       node_modules\@cspell\dict-software-terms\dict\softwareTerms.txt
// listenable - web-services*        node_modules\@cspell\dict-software-terms\dict\webServices.txt

    "cspell-dicts/dictionaries/aws/dict/aws.txt",
    "cspell-dicts/dictionaries/companies/dict/companies.txt",
    "cspell-dicts/dictionaries/software-terms/dict/computing-acronyms.txt",
    "cspell-dicts/dictionaries/cryptocurrencies/dict/cryptocurrencies.txt",
    "cspell-dicts/dictionaries/en_US/src/en_US.txt",
    "cspell-dicts/dictionaries/en_GB/src/wordsEnGb.txt",
    "cspell-dicts/dictionaries/filetypes/src/filetypes.txt",
    "cspell-dicts/dictionaries/public-licenses/src/generated/public-licenses.txt",
    "cspell-dicts/dictionaries/software-terms/dict/softwareTerms.txt",
    "cspell-dicts/dictionaries/software-terms/dict/webServices.txt",
  ];
  final cspellDictionary = await Future.wait(
      cspellDictionaryPathList.map((e) => File(e).readAsLines()));
  return cspellDictionary.expand((e) => e).toList();
}
