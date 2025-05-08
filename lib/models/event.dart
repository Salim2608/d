class Event {
  final String title;
  final String date;
  final String location;
  final String imageUrl;

  Event({
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: json['date'],
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }
}
