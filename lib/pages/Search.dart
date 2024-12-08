import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'dart:typed_data';
import 'Detail.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  int currentPage = 1;
  String currentQuery = '';
  bool hasNextPage = false;

  Future<void> fetchSearchResults() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://api.i-as.dev/api/animev2/search?q=$currentQuery&page=$currentPage'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final animeList = data['results'].map((anime) {
        anime['url'] = anime['url']
            .replaceAll('https://api.i-as.dev/api/animev2/detail/', '');
        return anime;
      }).toList();

      setState(() {
        searchResults = animeList;
        hasNextPage = data['pagination']['hasNextPage'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat hasil penelusuran');
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
	  title: const Text(
		'Pencarian',
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
	  ],
	  ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Cari Anime',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      setState(() {
                        currentQuery = _searchController.text;
                        currentPage = 1;
                      });
                      fetchSearchResults();
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? const Center(child: Text("Tidak ada hasil ditemukan"))
                    : ListView.builder(
                        itemCount: searchResults.length + 1,
                        itemBuilder: (context, index) {
							if (index == searchResults.length) {
							  return Padding(
								padding: const EdgeInsets.symmetric(vertical: 16.0),
								child: Center(
								  child: Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
									  if (currentPage > 1)
										ElevatedButton(
										  onPressed: () {
											setState(() {
											  currentPage--;
											});
											fetchSearchResults();
										  },
										  child: const Icon(Icons.arrow_back),
										),
									  const SizedBox(width: 16),
									  if (hasNextPage)
										ElevatedButton(
										  onPressed: () {
											setState(() {
											  currentPage++;
											});
											fetchSearchResults();
										  },
										  child: const Icon(Icons.arrow_forward),
										),
									],
								  ),
								),
							  );
							}
                          final result = searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: InkWell(
                                onTap: () {
                                  final slug = result['url'];
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
                                        child: getImageList(result),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result['title'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              result['status'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              result['type'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400,
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
          ),
        ],
      ),
    );
  }
}
