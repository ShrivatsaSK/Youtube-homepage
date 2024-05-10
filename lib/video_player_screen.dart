import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlickManager flickManager;
  late int likes;
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.video['video_url']),
      ),
    );
    likes = widget.video['Likes'];
    isLiked = false;
  }

  void likeVideo() async {
    if (!isLiked) {
      setState(() {
        likes++;
        isLiked = true;
      });

      // Update likes in the database
      final response = await Supabase.instance.client
          .from('videos')
          .update({'Likes': likes}) // Update 'Likes' field with new value
          .eq('id', widget.video['id']) // Update the record with matching ID
          .execute();

      if (response.error != null) {
        // Rollback local likes if update fails
        setState(() {
          likes--;
          isLiked = false;
        });
      }
    }
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      backgroundColor: const Color.fromARGB(
          255, 255, 220, 164), // Light orange background color
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9, // Original aspect ratio of the video
            child: FlickVideoPlayer(flickManager: flickManager),
          ),
          const SizedBox(height: 16), // Spacing between video and text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8), // Spacing between title and line
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: 5.0,
                          color: Colors.white), // White horizontal line
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 8), // Leave gap at ends
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.video['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blue,
                              ),
                              child: InkWell(
                                onTap: likeVideo,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        color: isLiked
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255, 74, 74, 74),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Like',
                                        style: TextStyle(
                                          color: isLiked
                                              ? Colors.white
                                              : const Color.fromARGB(
                                                  255, 74, 74, 74),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Likes: $likes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 74, 74, 74),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                    height: 8), // Spacing between title and description
                Text(
                  widget.video['description'],
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding:
                      const EdgeInsets.all(12), // Padding around channel text
                  decoration: BoxDecoration(
                    color:
                        Colors.grey[200], // Grey background color for the box
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: Text(
                    'Channel: ${widget.video['channel_name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
