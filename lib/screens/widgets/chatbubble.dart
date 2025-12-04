import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoiceBubble extends StatefulWidget {
  final String filePath;
  final bool isMe;
  final double maxWidth;

  const VoiceBubble({
    super.key,
    required this.filePath,
    required this.isMe,
    this.maxWidth = 250,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  late AudioPlayer _player;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      if (widget.filePath.startsWith("http")) {
        await _player.setUrl(widget.filePath);
      } else {
        await _player.setFilePath(widget.filePath);
      }

      duration = _player.duration ?? Duration.zero;

      _player.positionStream.listen((pos) {
        setState(() {
          position = pos;
        });
      });

      _player.playerStateStream.listen((state) {
        setState(() {
          isPlaying = state.playing;
        });
      });
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.blue : Colors.grey[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _togglePlayPause,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: duration.inMilliseconds == 0
                      ? 0
                      : position.inMilliseconds / duration.inMilliseconds,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
