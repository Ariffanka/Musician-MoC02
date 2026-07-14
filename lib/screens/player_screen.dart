import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final DraggableScrollableController _dragController = DraggableScrollableController();
  bool _sheetOpen = false;

  String _fmt(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  void _toggleSheet() {
    if (_sheetOpen) {
      _dragController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _dragController.animateTo(0.65,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    setState(() => _sheetOpen = !_sheetOpen);
  }

  @override
  void initState() {
    super.initState();
    _dragController.addListener(() {
      final isOpen = _dragController.size > 0.1;
      if (isOpen != _sheetOpen) {
        setState(() => _sheetOpen = isOpen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerService>();
    final track = player.currentTrack;
    if (track == null) return const SizedBox();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Back To Menu',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Player content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      track.cover.replaceAll('cover_medium', 'cover_xl'),
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 260,
                        color: const Color(0xFF1E1E1E),
                        child: const Icon(Icons.music_note, size: 80, color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    track.artist,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.title,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider(player),
                  const SizedBox(height: 24),
                  _buildControls(player),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Drag handle — selalu visible, bisa di-tap & drag
          GestureDetector(
            onTap: _toggleSheet,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
                _dragController.animateTo(0.65,
                    duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                setState(() => _sheetOpen = true);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // DraggableScrollableSheet untuk queue
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 0,
          ),
        ],
      ),
      bottomSheet: DraggableScrollableSheet(
        controller: _dragController,
        initialChildSize: 0.0,
        minChildSize: 0.0,
        maxChildSize: 0.65,
        snap: true,
        snapSizes: const [0.0, 0.65],
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleSheet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Up Next',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: player.queue.length,
                    itemBuilder: (_, i) {
                      final t = player.queue[i];
                      final isCurrent = player.currentTrack?.id == t.id;
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            t.cover,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 48, height: 48, color: const Color(0xFF2E2E2E)),
                          ),
                        ),
                        title: Text(
                          t.artist,
                          style: TextStyle(
                            color: isCurrent ? Colors.blue[300] : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          t.title,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isCurrent
                            ? Icon(Icons.equalizer, color: Colors.blue[300])
                            : const Icon(Icons.play_arrow, color: Colors.white38),
                        onTap: () {
                          player.setQueue(player.queue, i);
                          player.play(t);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider(PlayerService player) {
    final pos = player.position.inSeconds.toDouble();
    final dur = player.duration.inSeconds.toDouble();
    return Column(
      children: [
        SliderTheme(
          data: const SliderThemeData(
            trackHeight: 2,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Color(0xFF3A3A3A),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: pos.clamp(0, dur == 0 ? 1 : dur),
            max: dur == 0 ? 1 : dur,
            onChanged: (v) => player.seek(Duration(seconds: v.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(player.position),
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(_fmt(player.duration),
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(PlayerService player) {
    final shuffleColor = player.isShuffle ? Colors.blue[300]! : Colors.white54;
    final repeatIcon =
        player.repeatMode == PlayerRepeatMode.one ? Icons.repeat_one : Icons.repeat;
    final repeatColor =
        player.repeatMode != PlayerRepeatMode.off ? Colors.blue[300]! : Colors.white54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlIcon(
            icon: Icons.shuffle, size: 22, color: shuffleColor, onTap: player.toggleShuffle),
        _ControlIcon(
            icon: Icons.skip_previous,
            size: 34,
            color: Colors.white,
            onTap: player.playPrevious),
        GestureDetector(
          onTap: player.togglePlay,
          child: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              player.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
        _ControlIcon(
            icon: Icons.skip_next, size: 34, color: Colors.white, onTap: player.playNext),
        _ControlIcon(
            icon: repeatIcon, size: 22, color: repeatColor, onTap: player.toggleRepeat),
      ],
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon(
      {required this.icon, required this.size, required this.color, required this.onTap});
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Icon(icon, size: size, color: color));
  }
}