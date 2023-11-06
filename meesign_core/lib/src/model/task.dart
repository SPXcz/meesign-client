import 'package:meta/meta.dart';

import '../database/database.dart' as db;
import '../util/uuid.dart';

enum TaskState { created, running, needsCard, finished, failed }

// TODO: use freezed package?
@immutable
class Task<T> {
  final Uuid id;
  final TaskState state;
  final bool approved;
  final int round;
  final int nRounds;
  final int attempt;
  final T info;

  const Task({
    required this.id,
    this.state = TaskState.created,
    this.approved = false,
    this.round = 0,
    required this.nRounds,
    this.attempt = 0,
    required this.info,
  });

  // TODO: implement comparison, hash
}

class TaskConversion {
  static Task<T> fromEntity<T>(db.Task entity, int nRounds, T info) => Task<T>(
        id: Uuid.take(entity.id),
        state: entity.state,
        approved: entity.approved,
        round: entity.round,
        nRounds: nRounds,
        attempt: entity.attempt,
        info: info,
      );
}
