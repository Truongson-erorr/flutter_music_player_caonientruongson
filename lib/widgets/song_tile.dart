import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/playlist_provider.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveFromPlaylist;
  final bool isInPlaylist;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
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
          child: Image.file(
            File(song.albumArt!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      final firstLetter =
          song.title.isNotEmpty ? song.title[0].toUpperCase() : '?';

      final colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.brown,
      ];

      final color = colors[firstLetter.hashCode % colors.length];

      return CircleAvatar(
        backgroundColor: color,
        radius: 25,
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🗑 Remove khỏi playlist
            if (isInPlaylist && onRemoveFromPlaylist != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove from playlist',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onRemoveFromPlaylist!();
                },
              ),

            /// ➕ Add to playlist
            if (!isInPlaylist)
              ListTile(
                leading:
                    const Icon(Icons.playlist_add, color: Colors.black),
                title: const Text(
                  'Add to playlist',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSelectPlaylistDialog(context);
                },
              ),

            ListTile(
              leading: const Icon(Icons.share, color: Colors.black),
              title: const Text('Share'),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.black),
              title: const Text('Song info'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  /// 🎯 Dialog chọn playlist
  void _showSelectPlaylistDialog(BuildContext context) {
    final playlistProvider = context.read<PlaylistProvider>();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Select playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: playlistProvider.playlists.isEmpty
                ? const Text('No playlist available')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlistProvider.playlists.length,
                    itemBuilder: (_, index) {
                      final playlist =
                          playlistProvider.playlists[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.queue_music),
                        title: Text(playlist.name),
                        onTap: () {
                          playlistProvider.addSongToPlaylist(
                            playlist.id,
                            song,
                          );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added "${song.title}" to "${playlist.name}"',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
