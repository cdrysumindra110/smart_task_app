import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  Stream<List<TaskModel>> getTaskStream(String userId) {
    return _db.collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();

      tasks.sort((a, b) => b.date.compareTo(a.date));
      return tasks;
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _db.collection(_collection).add(task.toMap());
  }
  Future<void> updateTask(TaskModel task) async {
    await _db.collection(_collection).doc(task.id).update(task.toMap());
  }
  Future<void> deleteTask(TaskModel task) async {
    await _db.collection(_collection).doc(task.id).delete();
  }

  Future<void> toggleTaskStatus(TaskModel task) async {
    final newStatus = task.isCompleted ? TaskStatus.pending : TaskStatus.completed;
    await _db.collection(_collection).doc(task.id).update({
      'status': newStatus.name,
    });
  }
}