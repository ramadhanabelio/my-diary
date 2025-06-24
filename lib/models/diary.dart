class Diary {
  final int id;
  final int userId;
  final String date;
  final String title;
  final String content;
  final String? createdAt;
  final String? updatedAt;

  Diary({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'title': title,
      'content': content,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
