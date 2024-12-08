import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'Detail.dart';
import '../main.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<dynamic> animeList = [];
  List<dynamic> azList = [];
  bool isLoading = true;
  String selectedAlphabet = '#';
  int page = 1;
  bool hasNextPage = true;

  Future<void> fetchAnimeByAlphabet() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.i-as.dev/api/animev2/a-z?show=$selectedAlphabet&page=$page'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        animeList = data['results'];
        azList = data['azList'];
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
    fetchAnimeByAlphabet();
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
        title: const Text('Filter'),
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
		  const SizedBox(width: 15),
          DropdownButton<String>(
            value: selectedAlphabet,
            onChanged: (String? newValue) {
              setState(() {
                selectedAlphabet = newValue!;
                page = 1;
                isLoading = true;
              });
              fetchAnimeByAlphabet();
            },
            items: [
              DropdownMenuItem<String>(
                value: '#',
                child: Text('#'),
              ),
              DropdownMenuItem<String>(
                value: '0-9',
                child: Text('0-9'),
              ),
              ...List.generate(26, (index) {
                return DropdownMenuItem<String>(
                  value: String.fromCharCode(65 + index),
                  child: Text(String.fromCharCode(65 + index)),
                );
              }),
            ],
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
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: page > 1
                                ? () {
                                    setState(() {
                                      page--;
                                    });
                                    fetchAnimeByAlphabet();
                                  }
                                : null,
                            child: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: hasNextPage
                                ? () {
                                    setState(() {
                                      page++;
                                    });
                                    fetchAnimeByAlphabet();
                                  }
                                : null,
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final anime = animeList[index];
                String slug = anime['url'].replaceFirst('https://api.i-as.dev/api/animev2/detail/', '');

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
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
                                  Text('${anime['status']}'),
                                  Text('${anime['type']}'),
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
