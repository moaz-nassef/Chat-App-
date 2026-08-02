import '../../../core/errors/failure.dart';
import '../../auth/data/user_model.dart';
import 'users_datasource.dart';

/// Users business logic.
class UsersRepo {
  UsersRepo(this._dataSource);

  final UsersDataSource _dataSource;

  Stream<List<UserModel>> watchUsers() => _dataSource.watchUsers();

  Stream<UserModel?> watchUser(String uid) => _dataSource.watchUser(uid);

  Future<UserModel> getUserById(String uid) async {
    try {
      final user = await _dataSource.getUserById(uid);
      if (user == null) throw const FirestoreFailure('❌ المستخدم غير موجود');
      return user;
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure.fromException(e);
    }
  }
}
