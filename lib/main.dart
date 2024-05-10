import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'video_list_screen.dart';

void main() {
  runApp(const MyApp());
  Supabase.initialize(
    url: 'https://pefexkvflsdocigksvhg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlZmV4a3ZmbHNkb2NpZ2tzdmhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQ5Nzc2MzIsImV4cCI6MjAzMDU1MzYzMn0.BmXCePggpiG-4hbMKgJh12Rk4D9jf41Huj-fn2jvrSU',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube Homepage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
