import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'Episode.dart';
import 'Search.dart';
import 'dart:typed_data';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<dynamic> animeList = [];
  int currentPage = 1;
  bool hasPrevPage = false;
  bool hasNextPage = false;
  bool isLoading = false;

  Future<void> fetchAnimeList() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2?page=$currentPage'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['results'].map((anime) {
          anime['url'] = anime['url'].replaceAll('https://api.i-as.dev/api/animev2/episode/', '');
          return anime;
        }).toList();
        hasPrevPage = data['pagination']['hasPrevPage'];
        hasNextPage = data['pagination']['hasNextPage'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat daftar anime');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAnimeList();
  }

  void _navigateToEpisode(String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodePage(slug: slug),
      ),
    );
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() {
        currentPage++;
      });
      fetchAnimeList();
    }
  }

  void _goToPreviousPage() {
    if (hasPrevPage) {
      setState(() {
        currentPage--;
      });
      fetchAnimeList();
    }
  }

  Widget getImageList(Map<String, dynamic> anime) {
    String imageUrl = anime['image'];

    return imageUrl.isEmpty
        ? const Text('No Image', style: TextStyle(fontSize: 16, color: Colors.grey))
        : Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return const Text('No Image', style: TextStyle(fontSize: 16, color: Colors.grey));
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	  appBar: AppBar(
      automaticallyImplyLeading: false,
	  title: const Text(
		'Anime Terbaru',
		style: TextStyle(fontWeight: FontWeight.bold),
	  ),
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
          : animeList.isEmpty
              ? const Center(child: Text("Tidak ada data yang tersedia"))
              : ListView.builder(
                  itemCount: animeList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == animeList.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: hasPrevPage ? _goToPreviousPage : null,
                              child: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: hasNextPage ? _goToNextPage : null,
                              child: const Icon(Icons.arrow_forward),
                            ),
                          ],
                        ),
                      );
                    }

                    final anime = animeList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 1,
                        child: InkWell(
                          onTap: () => _navigateToEpisode(anime['url']),
                          borderRadius: BorderRadius.circular(5),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: getImageList(anime),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        anime['title'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        anime['status'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        anime['type'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
