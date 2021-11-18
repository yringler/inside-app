import 'dart:io';

import 'package:path_provider/path_provider.dart' as paths;

bool isMobile() => Platform.isAndroid || Platform.isIOS;

/*
 * These methods are used in this library to support easier unit testing (or whatever
 * these primitive things I have in the bin folder are called).
 */

/// Forwards to path_provider. On command line, returns current directory.
Future<Directory> getApplicationDocumentsDirectory() async => isMobile()
    ? await paths.getApplicationDocumentsDirectory()
    : Directory.current;

/// Forwards to path_provider. On command line, returns current directory.
Future<Directory> getApplicationSupportDirectory() async => isMobile()
    ? await paths.getApplicationSupportDirectory()
    : Directory.current;
