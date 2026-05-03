import '../core/services/app_storage.dart';
import '../data_model/app_state.dart';
import 'app_state_repository.dart';

class LocalAppStateRepository implements AppStateRepository {
  const LocalAppStateRepository();

  @override
  Future<AppState?> load() => AppStorage.load();

  @override
  Future<void> save(AppState state) => AppStorage.save(state);

  @override
  Future<void> clear() => AppStorage.clear();
}
