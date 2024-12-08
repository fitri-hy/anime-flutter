import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'GenreDetail.dart';
import '../main.dart';

class GenrePage extends StatefulWidget {
  @override
  _GenrePageState createState() => _GenrePageState();
}

class _GenrePageState extends State<GenrePage> {
  List<dynamic> genreList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    final response = await http.get(
      Uri.parse('https://api.i-as.dev/api/animev2/genres'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        genreList = data['genres'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat genre');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	  appBar: AppBar(
      automaticallyImplyLeading: false,
	  title: const Text(
		'Genre',
		style: TextStyle(fontWeight: FontWeight.bold),
	  ),
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
	  ],
	  ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: genreList.length,
                itemBuilder: (context, index) {
                  final genre = genreList[index];
                  String slug = genre['url'].replaceFirst(
                      'https://api.i-as.dev/api/animev2/genres/', '');

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 16.0,
                      ),
                      title: Text(
                        genre['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Jelajahi lebih banyak',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GenreDetailPage(genreSlug: slug),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
