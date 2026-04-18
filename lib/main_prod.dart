import 'main.dart' as app;
import 'core/config/app_config.dart';

void main() async {
  AppConfig.current = AppConfig.prod();
  await app.initializeAndRun();
}
