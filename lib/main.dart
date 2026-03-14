import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Dog Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _imageUrl = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDogImage();
  }

  Future<void> _fetchDogImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _imageUrl = data['message'];
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          _isLoading = false;
        });
        print('Failed to load image');
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Dog Image'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _imageUrl.isNotEmpty
                ? Image.network(
                    _imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Failed to load image');
                    },
                  )
                : const Text('No image to display'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchDogImage,
        tooltip: 'New Image',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
