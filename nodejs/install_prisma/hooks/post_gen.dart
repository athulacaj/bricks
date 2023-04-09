import 'dart:io';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final installProgress = context.logger.progress(
      'running npm i --save-dev prisma typescript ts-node @types/node');
  // Run `flutter packages get` after generation.
  await Process.run('npm', [
    'install',
    '--save-dev',
    'prisma',
    'typescript',
    'ts-node',
    '@types/node',
  ]);
  installProgress.complete();
  final generateProgress = context.logger
      .progress('running npx prisma init --datasource-provider postgresql');
  await Process.run(
          'npx', ['prisma', 'init', '--datasource-provider', 'postgresql'])
      .then((value) => print(value.stdout))
      .catchError((error) => print(error));
  generateProgress.complete();
}
