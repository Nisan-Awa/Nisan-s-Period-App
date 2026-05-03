import '../data_model/app_state.dart';

abstract class AppStateRepository {
  Future<AppState?> load();

  Future<void> save(AppState state);

  Future<void> clear();
}
