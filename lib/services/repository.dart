import 'package:indiepub/services/api_service.dart';
import 'package:indiepub/services/database_service.dart';
import 'package:indiepub/models/event.dart';
import 'package:indiepub/models/post.dart';
import 'package:logger/logger.dart';

class Repository {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  final logger = Logger();

  Future<List<Event>> getEvents() async {
    final localEvents = await _dbService.getEvents();
    if (localEvents.isNotEmpty) {
      final latestUpdate = localEvents.map((e) => e.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
      if (DateTime.now().difference(latestUpdate).inHours < 1) {
        logger.i('Returning events from SQLite');
        return localEvents;
      }
    }

    logger.i('Fetching events from API');
    final events = await _apiService.fetchEvents();
    await _dbService.insertEvents(events);
    return events;
  }

  Future<void> createEvent(Event event) async {
    await _apiService.createEvent(event);
    await _dbService.insertEvents([event]);
  }

  Future<List<Post>> getPosts() async {
    final localPosts = await _dbService.getPosts();
    if (localPosts.isNotEmpty) {
      final latestUpdate = localPosts.map((p) => p.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
      if (DateTime.now().difference(latestUpdate).inHours < 1) {
        logger.i('Returning posts from SQLite');
        return localPosts;
      }
    }

    logger.i('Fetching posts from API');
    final posts = await _apiService.fetchPosts();
    await _dbService.insertPosts(posts);
    return posts;
  }

  Future<void> createPost(Post post) async {
    await _apiService.createPost(post);
    await _dbService.insertPosts([post]);
  }
}