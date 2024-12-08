import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'Detail.dart';
import 'Search.dart';
import '../main.dart';

class GenreDetailPage extends StatefulWidget {
  final String genreSlug;

  const GenreDetailPage({Key? key, required this.genreSlug}) : super(key: key);

  @override
  _GenreDetailPageState createState() => _GenreDetailPageState();
}

class _GenreDetailPageState extends State<GenreDetailPage> {
  List<dynamic> animeList = [];
  bool isLoading = true;
  int currentPage = 1;
  bool hasNextPage = false;

  @override
  void initState() {
    super.initState();
    fetchGenreDetails();
  }

  Future<void> fetchGenreDetails() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://api.i-as.dev/api/animev2/genres/${widget.genreSlug}?page=$currentPage'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['results'];
        hasNextPage = data['pagination']['hasNextPage'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat detail genre');
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
        title: Text('Genre: ${widget.genreSlug}'),
		actions: [
		  IconButton(
		    icon: const Icon(Icons.home),
		    onPressed: () {
			  Navigator.pushReplacement(
			    context,
			    MaterialPageRoute(
				  builder: (context) => const MyHomePage(title: 'Anime App'),
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
          : ListView.builder(
              itemCount: animeList.length + 1,
              itemBuilder: (context, index) {
                if (index == animeList.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: currentPage > 1
                              ? () {
                                  setState(() {
                                    currentPage--;
                                    isLoading = true;
                                  });
                                  fetchGenreDetails();
                                }
                              : null,
                         child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: hasNextPage
                              ? () {
                                  setState(() {
                                    currentPage++;
                                    isLoading = true;
                                  });
                                  fetchGenreDetails();
                                }
                              : null,
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  );
                }

                final anime = animeList[index];
                String slug = anime['url'].replaceFirst(
                    'https://api.i-as.dev/api/animev2/detail/', '');

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    elevation: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(slug: slug),
                          ),
                        );
                      },
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
                                  const SizedBox(height: 8),
                                  Text(
                                    '${anime['status']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${anime['type']}',
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
