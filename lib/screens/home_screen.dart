import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/deezer_service.dart';
import '../services/player_service.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _deezer = DeezerService();
  final _searchController = TextEditingController();
  List<Track> _chartTracks = [];
  List<Track> _searchResults = [];
  bool _isSearching = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    final tracks = await _deezer.getChart();
    setState(() {
      _chartTracks = tracks;
      _loading = false;
    });
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) {
      setState(() { _isSearching = false; _searchResults = []; });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _deezer.search(q);
    setState(() => _searchResults = results);
  }

  void _openPlayer(Track track, List<Track> trackList) {
    final index = trackList.indexWhere((t) => t.id == track.id);
    context.read<PlayerService>().setQueue(trackList, index);
    context.read<PlayerService>().play(track);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    if (_isSearching) ...[
                      _sectionHeader('SEARCH RESULTS'),
                      const SizedBox(height: 12),
                      _buildTrackList(_searchResults),
                    ] else ...[
                      if (player.recentlyPlayed.isNotEmpty) ...[
                        _sectionHeader('RECENTLY PLAYED'),
                        const SizedBox(height: 12),
                        _buildRecentlyPlayed(player.recentlyPlayed),
                        const SizedBox(height: 24),
                      ],
                      _sectionHeader('RECOMMENDATION'),
                      const SizedBox(height: 12),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildTrackList(_chartTracks),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            if (player.currentTrack != null) _buildMiniPlayer(player),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.white38, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search songs, artists...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
              ),
              onChanged: _search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _search('');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.close, color: Colors.white38, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const Text('See All', style: TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentlyPlayed(List<Track> tracks) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.take(5).length,
        itemBuilder: (_, i) {
          final t = tracks[i];
          return GestureDetector(
            onTap: () => _openPlayer(t, tracks),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(t.cover, width: 120, height: 110, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 120, height: 110, color: const Color(0xFF1E1E1E))),
                  ),
                  const SizedBox(height: 6),
                  Text(t.artist,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(t.title,
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackList(List<Track> tracks) {
    return Column(
      children: tracks.map((t) {
        return GestureDetector(
          onTap: () => _openPlayer(t, tracks),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(t.cover, width: 48, height: 48, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 48, height: 48, color: const Color(0xFF1E1E1E))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(t.artist,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniPlayer(PlayerService player) {
    final t = player.currentTrack!;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen())),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(t.cover, width: 44, height: 44, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(t.artist, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(player.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
              onPressed: player.togglePlay,
            ),
          ],
        ),
      ),
    );
  }
}