import 'dart:io';
import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap; 
  final VoidCallback? onAddToPlaylist; 
  final VoidCallback? onRemoveFromPlaylist; 
  final bool isInPlaylist; 

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onAddToPlaylist,
    this.onRemoveFromPlaylist,
    this.isInPlaylist = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildAlbumArt(),
        title: Text(
          song.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onPressed: () => _showOptionsMenu(context),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAlbumArt() {
    if (song.albumArt != null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(File(song.albumArt!), fit: BoxFit.cover),
        ),
      );
    } else {
      String firstLetter = song.title.isNotEmpty ? song.title[0].toUpperCase() : "?";
      final colorList = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.brown,
      ];
      final color = colorList[firstLetter.hashCode % colorList.length];

      return CircleAvatar(
        backgroundColor: color,
        radius: 25,
        child: Text(
          firstLetter,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isInPlaylist && onRemoveFromPlaylist != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove from playlist', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromPlaylist!();
                },
              ),
            if (!isInPlaylist) ...[
              if (onAddToPlaylist != null)
                ListTile(
                  leading: const Icon(Icons.playlist_add, color: Colors.black),
                  title: const Text('Add to playlist', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.pop(context);
                    onAddToPlaylist!();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.black),
                title: const Text('Share', style: TextStyle(color: Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.black),
                title: const Text('Song info', style: TextStyle(color: Colors.black)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ],
        );
      },
    );
  }
}
