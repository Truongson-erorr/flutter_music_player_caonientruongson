import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool shuffle = false;
  bool repeat = false;
  double volume = 0.7;
  String audioQuality = 'Cao';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Giao diện'),
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Bật/tắt giao diện tối'),
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),
          _buildSectionTitle('Âm thanh'),
          ListTile(
            title: const Text('Âm lượng nhạc'),
            subtitle: Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 10,
              label: '${(volume * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  volume = value;
                });
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Phát ngẫu nhiên'),
            subtitle: const Text('Trộn bài hát khi phát'),
            value: shuffle,
            onChanged: (value) {
              setState(() {
                shuffle = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Lặp lại bài hát'),
            subtitle: const Text('Tự động phát lại bài đang nghe'),
            value: repeat,
            onChanged: (value) {
              setState(() {
                repeat = value;
              });
            },
          ),
          ListTile(
            title: const Text('Chất lượng âm thanh'),
            trailing: DropdownButton<String>(
              value: audioQuality,
              items: const [
                DropdownMenuItem(value: 'Thấp', child: Text('Thấp')),
                DropdownMenuItem(value: 'Trung bình', child: Text('Trung bình')),
                DropdownMenuItem(value: 'Cao', child: Text('Cao')),
              ],
              onChanged: (value) {
                setState(() {
                  audioQuality = value!;
                });
              },
            ),
          ),
          _buildSectionTitle('Thông tin'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Phiên bản ứng dụng'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text('Nhà phát triển'),
            subtitle: Text('Your Name'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
