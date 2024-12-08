import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'StatusDetail.dart';
import '../main.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<dynamic> statusList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatusList();
  }

  Future<void> fetchStatusList() async {
    final response = await http.get(
      Uri.parse('https://api.i-as.dev/api/animev2/status'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        statusList = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat daftar status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	  appBar: AppBar(
      automaticallyImplyLeading: false,
	  title: const Text(
		'Status',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: statusList.length,
              itemBuilder: (context, index) {
                final status = statusList[index];
                final slug = status['url'].replaceFirst(
                    'https://api.i-as.dev/api/animev2/status/', '');

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
                        status['title'],
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
							  builder: (context) =>
								  StatusDetailPage(statusSlug: slug),
							),
						  );
					  },
                    ),
                  );
              },
            ),
    );
  }
}
