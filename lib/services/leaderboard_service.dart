import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String username;
  final int score;
  final DateTime date;

  LeaderboardEntry({
    required this.username,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'score': score,
        'date': date.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'] as String,
      score: json['score'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class LeaderboardService {
  static const String _leaderboardKey = 'leaderboard';
  static const int maxEntries = 10;

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_leaderboardKey);
      if (jsonStr == null) return [];

      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveScore(String username, int score) async {
    final entries = await getLeaderboard();

    entries.add(LeaderboardEntry(
      username: username,
      score: score,
      date: DateTime.now(),
    ));

    // Sort by score descending
    entries.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top entries
    final topEntries = entries.take(maxEntries).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_leaderboardKey, jsonEncode(topEntries.map((e) => e.toJson()).toList()));
  }

  static Future<int?> getRank(int score) async {
    final entries = await getLeaderboard();
    if (entries.isEmpty) return 1;

    int rank = 1;
    for (final entry in entries) {
      if (score > entry.score) break;
      rank++;
    }
    return rank <= maxEntries ? rank : null;
  }

  static Future<bool> isHighScore(int score) async {
    final entries = await getLeaderboard();
    if (entries.length < maxEntries) return true;
    return score > entries.last.score;
  }
}
