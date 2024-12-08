import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Anime App adalah aplikasi yang dirancang untuk para penggemar anime. Aplikasi ini memungkinkan pengguna untuk menelusuri informasi anime terbaru, genre, status, dan episode secara lengkap. Dengan desain modern dan responsif, kami berharap aplikasi ini dapat memberikan pengalaman terbaik untuk komunitas anime.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Versi: 1.0.0',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.bug_report, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Report: https://github.com/fitri-hy/anime-flutter',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
