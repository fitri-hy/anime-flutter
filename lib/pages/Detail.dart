import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'Episode.dart';
import 'Search.dart';
import '../main.dart';

class DetailPage extends StatefulWidget {
  final String slug;

  const DetailPage({Key? key, required this.slug}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic> animeDetail = {};
  bool isLoading = true;

  Future<void> fetchAnimeDetail() async {
    final response = await http.get(
      Uri.parse('https://api.i-as.dev/api/animev2/detail/${widget.slug}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeDetail = data['result'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat detail anime');
    }
  }

  Widget getImageList(Map<String, dynamic> anime) {
    String imageUrl = anime['image'];

    return imageUrl.isEmpty
        ? const Text('No Image', style: TextStyle(fontSize: 16, color: Colors.grey))
        : Center(
            child: Image.network(
              imageUrl,
              width: 250,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Text('No Image', style: TextStyle(fontSize: 16, color: Colors.grey));
              },
            ),
          );
  }

  String extractEpisodeSlug(String epUrl) {
    return epUrl.replaceAll('https://api.i-as.dev/api/animev2/episode/', '');
  }

  @override
  void initState() {
    super.initState();
    fetchAnimeDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animeDetail.isNotEmpty ? animeDetail['title'] : 'Detail'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
				  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                     child: getImageList(animeDetail),
                  ),
                  const SizedBox(height: 20),
                  Table(
                    border: TableBorder.all(color: Color(0xFFe3e3e3)),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFe3e3e3)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Info', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Title'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['title'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Status'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['status'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Studio'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['studio'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Released'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['released'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Season'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['season'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Type'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['type'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Censor'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['censor'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Director'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['director'] ?? 'N/A'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Producers'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(animeDetail['producers'] ?? 'N/A'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Deskripsi:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(animeDetail['description'] ?? 'No description available'),
                  const SizedBox(height: 20),
                  Text('Episode:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  animeDetail['episodes'] != null
                      ? Column(
                          children: animeDetail['episodes'].map<Widget>((episode) {
                            String epSlug = extractEpisodeSlug(episode['epUrl']);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EpisodePage(slug: epSlug),
                                  ),
                                );
                              },
                              child: Card(
								margin: const EdgeInsets.symmetric(vertical: 5.0),
								elevation: 1,
								child: Padding(
								  padding: const EdgeInsets.all(8.0),
								  child: Row(
									children: [
									  Text(episode['epNo'] ?? 'N/A'),
									  const SizedBox(width: 16),
									  Expanded(
										child: Padding(
										  padding: const EdgeInsets.symmetric(vertical: 8.0),
										  child: Text(
											episode['epTitle'] ?? 'Episode Title N/A',
											overflow: TextOverflow.ellipsis,
										  ),
										),
									  ),
									],
								  ),
								),
							  ),
                            );
                          }).toList(),
                        )
                      : const Center(child: Text('No episodes available')),
                ],
              ),
            ),
    );
  }
}
