class TrendingEvent {
  final String name;
  final String date;
  final String location;
  final String imageUrl;

  TrendingEvent({
    required this.name,
    required this.date,
    required this.location,
    required this.imageUrl,
  });

  factory TrendingEvent.fromJson(Map<String, dynamic> json) {
    return TrendingEvent(
      name: json['name'],
      date: json['date'],
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }
}
