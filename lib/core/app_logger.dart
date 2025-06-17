import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Tidak tampilkan stack trace
      colors: true,
      printEmojis: true,
      // ignore: deprecated_member_use
      printTime: false,
    ),
  );

  static Logger get instance => _logger;
}
