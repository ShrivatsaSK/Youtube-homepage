import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'video_player_screen.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  List<dynamic> videos = [];
  List<dynamic> filteredVideos = [];
  TextEditingController searchController = TextEditingController();
  late RealtimeSubscription? subscription;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    searchController.addListener(() {
      filterVideos();
    });
  }

  @override
  void dispose() {
    subscription?.unsubscribe();
    super.dispose();
  }

  Future<void> fetchVideos() async {
    final response =
        await Supabase.instance.client.from('videos').select().execute();
    if (response.error == null) {
      setState(() {
        videos = response.data;
        filteredVideos = videos;
      });
      // Subscribe to changes in the database
      subscription = Supabase.instance.client
          .from('videos')
          .on(SupabaseEventTypes.all, (payload) => fetchVideos())
          .subscribe();
    }
  }

  void filterVideos() {
    List<dynamic> results = [];
    if (searchController.text.isEmpty) {
      results = videos;
    } else {
      results = videos
          .where((video) => video['title']
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredVideos = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
        backgroundColor: Colors.orange[200], // Light orange background color
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20), // Rounded bottom corners
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded borders
                ),
                filled: true,
                fillColor: Colors.orange[100], // Light orange background color
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                var video = filteredVideos[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: const Color.fromARGB(150, 117, 197, 247),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16), // Increased space between cards
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            video: video,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.network(
                            video['thumbnail_url'],
                            fit: BoxFit.cover,
                            height: 150, // Reduced height of thumbnail
                          ),
                        ),
                        ListTile(
                          title: Text(video['title']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['description'],
                                maxLines: 2,
                              ),
                              const SizedBox(
                                height: 4,
                              ), // Add some spacing between description and channel name
                              Text(
                                'Channel: ${video['channel_name']}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 110, 110, 110),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ), // Add some spacing between channel name and likes
                            ],
                          ),
                        ),
                      ],
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
