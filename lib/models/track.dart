class Track {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String cover;
  final String preview;
  final int duration;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.preview,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'],
      title: json['title'] ?? '',
      artist: json['artist']?['name'] ?? '',
      album: json['album']?['title'] ?? '',
      cover: json['album']?['cover_medium'] ?? '',
      preview: json['preview'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }
}