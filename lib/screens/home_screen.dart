import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/mini_player.dart';
import '../widgets/song_tile.dart';
import '../screens/settings_screen.dart';
import '../screens/search_screen.dart';
import '../screens/playlist_screen.dart';

enum SortOption { title, artist, album }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  List<SongModel> _myPlaylist = []; // danh sách playlist
  bool _isLoading = true;
  bool _hasPermission = false;
  SortOption _currentSort = SortOption.title;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final granted = await _permissionService.requestMusicPermission();
    if (!mounted) return;

    if (granted) {
      await _loadSongs();
    }

    setState(() {
      _hasPermission = granted;
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      setState(() {
        _songs = songs;
        _filteredSongs = List.from(_songs);
        _sortSongs();
      });
      
      context.read<PlaylistProvider>().setAllSongs(_songs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading songs: $e')),
      );
    }
  }

  void _sortSongs() {
    setState(() {
      _filteredSongs.sort((a, b) {
        switch (_currentSort) {
          case SortOption.title:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case SortOption.artist:
            return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
          case SortOption.album:
            return (a.album ?? '').toLowerCase().compareTo((b.album ?? '').toLowerCase());
        }
      });
    });
  }

  void _filterSongs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = List.from(_songs);
      } else {
        _filteredSongs = _songs.where((song) {
          final titleLower = song.title.toLowerCase();
          final artistLower = song.artist.toLowerCase();
          final albumLower = (song.album ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) ||
              artistLower.contains(searchLower) ||
              albumLower.contains(searchLower);
        }).toList();
      }
      _sortSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasPermission
                      ? _buildPermissionDenied()
                      : _filteredSongs.isEmpty
                          ? _buildNoSongs()
                          : _buildSongList(),
            ),
            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null) return const SizedBox.shrink();
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Music',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  if (_songs.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(songs: _filteredSongs),
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PlaylistScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(),
                    ),
                  );
                },
              ),
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort, color: Colors.black),
                onSelected: (SortOption option) {
                  _currentSort = option;
                  _sortSongs();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: SortOption.title,
                    child: Text('Sort by Title'),
                  ),
                  PopupMenuItem(
                    value: SortOption.artist,
                    child: Text('Sort by Artist'),
                  ),
                  PopupMenuItem(
                    value: SortOption.album,
                    child: Text('Sort by Album'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      itemCount: _filteredSongs.length,
      itemBuilder: (context, index) {
        final song = _filteredSongs[index];
        return SongTile(
          song: song,
          onTap: () {
            context.read<AudioProvider>().setPlaylist(
              _filteredSongs,
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Storage Permission Required',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please grant storage permission to access music',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No Music Found',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          SizedBox(height: 10),
          Text(
            'Add some music files to your device',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
