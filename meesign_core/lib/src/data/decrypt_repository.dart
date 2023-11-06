import 'package:drift/drift.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/decrypt.dart';
import '../model/group.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/uuid.dart';
import 'task_repository.dart';
import 'network_dispatcher.dart';

class DecryptRepository extends TaskRepository<Decrypt> {
  final TaskDao _taskDao;
  final NetworkDispatcher _dispatcher;

  DecryptRepository(
    this._dispatcher,
    TaskSource taskSource,
    this._taskDao,
  ) : super(rpc.TaskType.DECRYPT, taskSource, _taskDao);

  /// Encrypt a message for the given group.
  Future<void> encrypt(
    String description,
    List<int> message,
    List<int> gid,
  ) async {
    final data = ElGamalWrapper.encrypt(message, gid);
    await _dispatcher.unauth.decrypt(
      rpc.DecryptRequest()
        ..groupId = gid
        ..name = description
        ..data = data,
    );
  }

  @override
  Future<void> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.DecryptRequest.fromBuffer(rpcTask.request);

    // FIXME: too similar to files?
    final tid = rpcTask.id as Uint8List;

    await _taskDao.transaction(() async {
      await _taskDao.upsertTask(
        db.TasksCompanion.insert(
          id: tid,
          did: did.bytes,
          gid: Value(req.groupId as Uint8List),
          state: TaskState.created,
        ),
      );

      await _taskDao.insertDecrypt(
        db.DecryptsCompanion.insert(
          tid: tid,
          did: did.bytes,
          name: req.name,
          data: req.data as Uint8List,
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task) async {
    final group = await _taskDao.getGroup(did.bytes, gid: task.gid);
    return task.copyWith(
      context: Value(ProtocolWrapper.init(
        group.protocol.toNative(),
        group.context,
      )),
    );
  }

  @override
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final context = task.context;
    if (context != null) ProtocolWrapper.finish(context);
    await _taskDao.updateDecrypt(db.DecryptsCompanion(
      tid: Value(task.id),
      did: Value(task.did),
      data: Value(rpcTask.data as Uint8List),
    ));
  }

  @override
  Stream<List<Task<Decrypt>>> observeTasks(Uuid did) {
    Task<Decrypt> toModel(DecryptTask dt) {
      final group = dt.group.toModel();
      final decrypt = Decrypt(dt.decrypt.name, group, dt.decrypt.data);
      return TaskConversion.fromEntity(
          dt.task, group.protocol.signRounds, decrypt);
    }

    return _taskDao
        .watchDecryptTasks(did.bytes)
        .map((list) => list.map((toModel)).toList());
  }

  Stream<List<Decrypt>> observeDecrypts(Uuid did) => observeResults(did);
}
