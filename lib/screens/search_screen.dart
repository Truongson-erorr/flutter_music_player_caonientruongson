import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_tile.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class SearchScreen extends StatefulWidget {
  final List<SongModel> songs;

  const SearchScreen({super.key, required this.songs});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SongModel> _results = [];

  void _search(String query) {
    setState(() {
      _results = widget.songs
          .where((song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              hintText: 'Search songs...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.grey),
            ),
            onChanged: _search,
          ),
        ),
      ),
      body: _results.isEmpty
          ? const Center(
              child: Text(
                'No results',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(
                color: Colors.grey,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final song = _results[index];
                return GestureDetector(
                  onTap: () {

                  },
                  child: SongTile(
                    song: song,
                    onTap: () {
                      context.read<AudioProvider>().setPlaylist(_results, index);
                    },
                  ),
                );
              },
            ),
    );
  }
}
