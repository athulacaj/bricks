import 'dart:io';
import 'package:mason/mason.dart';

class MyProcess {
  static late HookContext context;
  String msg;
  MyProcess({this.msg = 'Running process...'});
  Future<bool> run(String command, List<String>? params) async {
    final progress = context.logger.progress(msg);

    // Run `flutter packages get` after generation.
    ProcessResult result = await Process.run(command, params ?? []);
    // log the output of the process
    // context.logger.info(result.stdout);
    // write log into a file
    // save the log into a file using dart:io
    File('mason_build_log.txt')
        .writeAsStringSync(result.stdout.toString(), mode: FileMode.append);

    File('mason_build_log.txt')
        .writeAsStringSync(result.stderr.toString(), mode: FileMode.append);

    //log the error of the process
    context.logger.err(result.stderr);

    // print the log
    context.logger.info(result.stdout);

    progress.complete();

    // return false if the process failed
    if (result.exitCode != 0) {
      return false;
    }
    return true;
  }
}

const appId = '1:767403347925:android:12345678';

Future<void> run(HookContext context) async {
  // take a input from the user
  // final String? input = context.pro

  // clear the log file
  File('mason_build_log.txt').writeAsStringSync('', mode: FileMode.write);

  MyProcess.context = context;

  // await Process.run('flutter', ['packages', 'get']);
  // bool s1 = await MyProcess(msg: "installing packages")
  //     .run('flutter', ['packages', 'get']);
  // if (!s1) return;
  // run the build apk command
  // bool s2 = await MyProcess(msg: "building app").run('flutter', [
  //   'build',
  //   'apk',
  //   '--release',
  //   '-t',
  //   'lib/main_staging.dart',
  //   '--flavor',
  //   'staging',
  //   '--build-number',
  //   '138',
  //   '--build-name',
  //   '1.0.0'
  // ]);
  // if (!s2) return;
  // await MyProcess(msg: "installing packages")
  //     .run('flutter', ['packages', 'get']);

  // upload app to firebase app distribution
  bool s3 = await MyProcess(msg: "uploading app to firebase app distribution")
      .run('firebase', [
    'appdistribution:distribute',
    'build/app/outputs/flutter-apk/app-staging-release.apk',
    '--app',
    appId,
    '--release-notes',
    'This is a demo release'
  ]);
  // firebase appdistribution:distribute test.apk --app 1:1234567890:android:0a1b2c3d4e5f67890 --release-notes "Bug fixes and improvements"
}
