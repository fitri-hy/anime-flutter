import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'Detail.dart';
import 'Search.dart';
import '../main.dart';

class StatusDetailPage extends StatefulWidget {
  final String statusSlug;

  const StatusDetailPage({super.key, required this.statusSlug});

  @override
  _StatusDetailPageState createState() => _StatusDetailPageState();
}

class _StatusDetailPageState extends State<StatusDetailPage> {
  List<dynamic> animeList = [];
  int currentPage = 1;
  bool hasPrevPage = false;
  bool hasNextPage = false;
  bool isLoading = false;

  Future<void> fetchStatusDetails() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://api.i-as.dev/api/animev2/status/${widget.statusSlug}?page=$currentPage'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['results'].map((anime) {
          anime['url'] = anime['url'].replaceAll(
              'https://api.i-as.dev/api/animev2/detail/', '');
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
      throw Exception('Gagal memuat detail status');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStatusDetails();
  }

  void _navigateToDetail(String slug) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(slug: slug),
      ),
    );
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() {
        currentPage++;
      });
      fetchStatusDetails();
    }
  }

  void _goToPreviousPage() {
    if (hasPrevPage) {
      setState(() {
        currentPage--;
      });
      fetchStatusDetails();
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
        title: Text('Status: ${widget.statusSlug}'),
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
              ? const Center(child: Text("No data available"))
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
                          onTap: () => _navigateToDetail(anime['url']),
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
