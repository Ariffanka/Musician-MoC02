import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class DeezerService {
  static const _proxy = 'https://corsproxy.io/?';
  static const _base = 'https://api.deezer.com';

  Future<List<Track>> _get(String path) async {
    final url = Uri.parse('$_proxy${Uri.encodeComponent('$_base$path')}');
    final res = await http.get(url);
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    return (data['data'] as List).map((e) => Track.fromJson(e)).toList();
  }

  Future<List<Track>> search(String query) =>
      _get('/search?q=${Uri.encodeComponent(query)}&limit=20');

  Future<List<Track>> getChart() => _get('/chart/0/tracks?limit=20');
}