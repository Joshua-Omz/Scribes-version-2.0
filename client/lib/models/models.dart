class User {
  final String id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }
}

class Note {
  final String id;
  final String title;
  final String content; // backend returned body/content

  Note({required this.id, required this.title, required this.content});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['body'] ?? json['content'] ?? '',
    );
  }
}

class Draft {
  final String id;
  final String title;
  final String body;

  Draft({required this.id, required this.title, required this.body});

  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'],
      title: json['title'],
      body: json['body'] ?? '',
    );
  }
}

class Post {
  final String id;
  final String title;
  final String body;
  final String category;

  Post(
      {required this.id,
      required this.title,
      required this.body,
      required this.category});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'] ?? '',
      category: json['category'] ?? 'general',
    );
  }
}
