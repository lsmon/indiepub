import 'package:flutter/material.dart';
import 'package:indiepub/models/post.dart';
import 'package:indiepub/services/auth_service.dart';
import 'package:indiepub/services/repository.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  late final AuthService _auth;
  final Repository _repository = Repository();
  final TextEditingController _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Forum')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _repository.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final posts = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      title: Text(post.content),
                      subtitle: Text('Posted: ${post.createdAt}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: const InputDecoration(labelText: 'New Post'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_postController.text.isNotEmpty) {
                      final post = Post(
                        id: DateTime.now().millisecondsSinceEpoch,
                        content: _postController.text,
                        userId: _auth.getCurrentUserId()!,
                        createdAt: DateTime.now(),
                      );
                      await _repository.createPost(post);
                      _postController.clear();
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}