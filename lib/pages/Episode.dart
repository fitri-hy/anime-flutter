import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/VideoPlayer.dart';
import 'Search.dart';
import '../main.dart';

class EpisodePage extends StatefulWidget {
  final String slug;

  const EpisodePage({super.key, required this.slug});

  @override
  _EpisodePageState createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> {
  Map<String, dynamic> episodeDetails = {};
  late String videoUrl;

  Future<void> fetchEpisodeDetails() async {
    final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2/episode/${widget.slug}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        episodeDetails = data['result'];
        videoUrl = episodeDetails['videoUrl'];
        registerIframeViewFactory(videoUrl);
      });
    } else {
      throw Exception('Failed to load episode details');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEpisodeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(episodeDetails.isNotEmpty ? episodeDetails['title'] : 'Episode Details'),
        actions: [
		  IconButton(
		    icon: const Icon(Icons.home),
		    onPressed: () {
			  Navigator.pushReplacement(
			    context,
			    MaterialPageRoute(
				  builder: (context) => const MyHomePage(title: 'Anime'),
			    ),
			  );
		    },
		  ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: episodeDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        double videoWidth = MediaQuery.of(context).size.width;
                        double videoHeight = videoWidth * 9 / 16;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: videoWidth,
                            height: videoHeight,
                            child: VideoPlayerWidget(videoUrl: videoUrl),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Title: ${episodeDetails['title']}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.grey),
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Field', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(episodeDetails['status'] ?? 'N/A'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Released', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(episodeDetails['released'] ?? 'N/A'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Season', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(episodeDetails['season'] ?? 'N/A'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(episodeDetails['type'] ?? 'N/A'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Director', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(episodeDetails['director'] ?? 'N/A'),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Producers', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(episodeDetails['producers'] ?? 'N/A'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      episodeDetails['description'],
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
