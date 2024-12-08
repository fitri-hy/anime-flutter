import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'pages/List.dart';
import 'pages/Search.dart';
import 'pages/Filter.dart';
import 'pages/Genre.dart';
import 'pages/Status.dart';
import 'pages/Episode.dart';
import 'pages/Info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Anime'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> randomBanner = [];
  List<dynamic> randomPopular = [];
  List<dynamic> latestAnimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(1);
  }

  Future<void> _fetchData(int page) async {
    try {
      final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2?page=$page'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          List<dynamic> allAnimes = data['results'];
          randomBanner = List.from(allAnimes);
          randomBanner.shuffle(Random());
		  
         randomPopular = List.from(allAnimes)
		   ..shuffle(Random());
		 randomPopular = randomPopular.take(5).toList();


          latestAnimes = List.from(allAnimes);
          latestAnimes = latestAnimes.take(5).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kesalahan'),
          content: const Text('Gagal memuat data. Silakan coba lagi nanti.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _navigateToList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListPage()),
    );
  }

  void _navigateToFilter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterPage()),
    );
  }

  void _navigateToGenre(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GenrePage()),
    );
  }

  void _navigateToStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatusPage()),
    );
  }

  Image getImageBanner(Map<String, dynamic> recipe) {
    String imageUrl = recipe['image'];
    if (imageUrl.startsWith('data:image')) {
      List<int> bytes = base64Decode(imageUrl.split(',').last);
      Uint8List uint8List = Uint8List.fromList(bytes);
      return Image.memory(uint8List, fit: BoxFit.cover);
    } else {
      return Image.network(imageUrl, fit: BoxFit.cover);
    }
  }

  Widget getImageList(Map<String, dynamic> anime) {
    String imageUrl = anime['image'];

    return imageUrl.isEmpty
        ? const Text('No Image', style: TextStyle(fontSize: 16, color: Colors.grey))
        : ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              imageUrl,
              width: 100, 
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Text('No Image', style: TextStyle(fontSize: 16, color: Colors.grey));
              },
            ),
          );
  }

Widget _menuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
  double screenWidth = MediaQuery.of(context).size.width;
  double cardWidth = screenWidth * 0.2;

  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        width: cardWidth,
        height: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: cardWidth * 0.4, color: Colors.deepPurple),
              SizedBox(height: cardWidth * 0.1),
              Text(
                title,
                style: TextStyle(
                  fontSize: cardWidth * 0.15,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Anime App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 9,
                        enableInfiniteScroll: true,
                        viewportFraction: 0.9,
                        pageSnapping: true,
                        enlargeFactor: 0.3,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                      ),
                      items: randomBanner.map((recipe) {
                        return GestureDetector(
                          onTap: () {
                            String url = recipe['url'];
                            String slug = url.replaceFirst('https://api.i-as.dev/api/animev2/episode/', '');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EpisodePage(slug: slug),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: getImageBanner(recipe),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      recipe['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black,
                                            offset: Offset(0.0, 0.0),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Termukan Berdasarkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _menuCard(
                          context,
                          'Terbaru',
                          Icons.list,
                          () => _navigateToList(context),
                        ),
                        _menuCard(
                          context,
                          'Genre',
                          Icons.category,
                          () => _navigateToGenre(context),
                        ),
                        _menuCard(
                          context,
                          'Status',
                          Icons.playlist_add_check,
                          () => _navigateToStatus(context),
                        ),
                        _menuCard(
                          context,
                          'Filter',
                          Icons.filter_alt,
                          () => _navigateToFilter(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Anime Terbaru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: latestAnimes.length,
                      itemBuilder: (context, index) {
                        final anime = latestAnimes[index];
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
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Anime Populer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: randomPopular.length,
                      itemBuilder: (context, index) {
                        final anime = randomPopular[index];
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
					
					
                  ],
                ),
              ),
            ),
    );
  }

  void _navigateToEpisode(String url) {
    String slug = url.replaceFirst('https://api.i-as.dev/api/animev2/episode/', '');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EpisodePage(slug: slug)),
    );
  }
}
