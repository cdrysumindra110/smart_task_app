import 'package:cloud_firestore/cloud_firestore.dart';
enum TaskStatus {pending, completed}
class TaskModel {
final String id;
final String title;
final String description;
final DateTime date;
final TaskStatus status;
final String userId;

TaskModel({
  required this.id,
  required this. title,
  required this. description,
  required this. date,
  required this. status,
  required this.userId
});

bool get isCompleted => status ==  TaskStatus.completed;

TaskModel copyWith({
  String? id,
  String? title,
  String? description,
  DateTime? date,
  TaskStatus? status,
  String? userId,
}){
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description : description?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      userId: userId ?? this.userId
    );
  }

Map<String, dynamic> toMap(){
  return {
    'title': title,
    'description': description,
    'date': Timestamp.fromDate(date),
    'status': status.name,
    'userId': userId,
  };
}

factory TaskModel.fromMap(String id, Map<String, dynamic> map){
  return TaskModel(
    id: id, 
    title: map['title'] as String? ?? '', 
    description: map['description']  as String? ?? '', 
    date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(), 
    status: TaskStatus.values.firstWhere((e) => e.name == (map['status'] as String? ?? 'pending'),
    orElse: () => TaskStatus.pending
     ), 
    userId: map['userId'] as String? ?? '',
    );
  }

  factory TaskModel.fromDocument(DocumentSnapshot doc){
    return TaskModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}