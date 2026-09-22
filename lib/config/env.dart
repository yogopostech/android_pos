import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static final DotEnv _env = DotEnv();

  // Initialize the environment variables asynchronously
  static Future<void> init() async {
    await _env.load();
  }

  static int get port {
    final portStr = _env.env['PORT'] ?? '8000';
    return int.tryParse(portStr) ?? 8000;
  }
}