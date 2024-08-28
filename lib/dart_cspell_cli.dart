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
      case ClassDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(extractConstructorNames(entity.childEntities));
      case MethodDeclaration():
        names.add(entity.name.lexeme);
      case EnumDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(entity.childEntities
            .whereType<EnumConstantDeclaration>()
            .map((e) => e.name.lexeme));
      case GenericTypeAlias():
        names.add(entity.name.lexeme);
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
        names.addAll(entity.childEntities
            .whereType<FormalParameterList>()
            .expand((e) => e.childEntities
                .whereType<DefaultFormalParameter>()
                .map((e) => e.name!.lexeme)));
      case MethodDeclaration():
        names.add(entity.name.lexeme);
        names.addAll(entity.childEntities
            .whereType<FormalParameterList>()
            .expand((e) => e.childEntities
                .whereType<SimpleFormalParameter>()
                .map((e) => e.name!.lexeme)));
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
