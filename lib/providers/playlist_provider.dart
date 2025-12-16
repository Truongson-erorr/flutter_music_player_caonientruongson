import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<PlaylistModel> _playlists = [];

  List<SongModel> _allSongs = [];

  List<PlaylistModel> get playlists => _playlists;

  void setAllSongs(List<SongModel> songs) {
    _allSongs = songs;
  }

  PlaylistModel? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<SongModel> getSongsOfPlaylist(String playlistId) {
    final playlist = getById(playlistId);
    if (playlist == null) return [];

    final List<SongModel> result = [];

    for (final songId in playlist.songIds) {
      final song = _allSongs.cast<SongModel?>().firstWhere(
            (s) => s?.id == songId,
            orElse: () => null,
          );

      if (song != null) {
        result.add(song);
      }
    }

    return result;
  }

  void createPlaylist(String name) {
    _playlists.add(
      PlaylistModel(
        id: const Uuid().v4(),
        name: name,
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void renamePlaylist(String id, String newName) {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _playlists[index] = _playlists[index].copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addSongToPlaylist(String playlistId, SongModel song) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];

    if (!playlist.songIds.contains(song.id)) {
      _playlists[index] = playlist.copyWith(
        songIds: [...playlist.songIds, song.id],
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _playlists[index];

    _playlists[index] = playlist.copyWith(
      songIds: playlist.songIds.where((id) => id != songId).toList(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
}
