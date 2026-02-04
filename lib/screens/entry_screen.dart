import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:magicful_2048/services/user_service.dart';
import 'package:magicful_2048/services/leaderboard_service.dart';
import 'package:magicful_2048/providers/game_provider.dart';
import 'package:magicful_2048/screens/game_screen.dart';
import 'package:magicful_2048/utils/constants.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String? _existingUsername;
  List<LeaderboardEntry> _leaderboard = [];
  int _selectedGridSize = GameSizes.defaultGridSize;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final username = await UserService.getUsername();
    final leaderboard = await LeaderboardService.getLeaderboard();

    if (mounted) {
      setState(() {
        _existingUsername = username;
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      await UserService.saveUsername(_usernameController.text.trim());
      _navigateToGame();
    }
  }

  void _navigateToGame() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.setGridSize(_selectedGridSize);
    gameProvider.startNewGame();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: GameColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: GameColors.lightText,
                ),
              ),
              const Text(
                'Magicful Edition',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 32),
              if (_existingUsername != null) ...[
                _buildWelcomeBack(),
              ] else ...[
                _buildUsernameForm(),
              ],
              const SizedBox(height: 24),
              _buildGridSizeSelector(),
              const SizedBox(height: 24),
              _buildLeaderboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBack() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: 16,
              color: GameColors.lightText.withValues(alpha: 0.7),
            ),
          ),
          Text(
            _existingUsername!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GameColors.lightText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.gridBackground,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _existingUsername = null),
            child: Text(
              'Change username',
              style: TextStyle(
                color: GameColors.lightText.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your username',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: GameColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                filled: true,
                fillColor: GameColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a username';
                }
                if (value.trim().length < 2) {
                  return 'Username must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Your username is used to track your scores against all other players. No password required!',
              style: TextStyle(
                fontSize: 12,
                color: GameColors.lightText.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameColors.gridBackground,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Start Playing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSizeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Grid Size',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GameColors.lightText,
                ),
              ),
              const Spacer(),
              if (_selectedGridSize != GameSizes.rankingGridSize)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Not ranked',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: GameSizes.availableGridSizes.map((size) {
              final isSelected = _selectedGridSize == size;
              final isRanked = size == GameSizes.rankingGridSize;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGridSize = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GameColors.gridBackground
                            : GameColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: isRanked && !isSelected
                            ? Border.all(color: Colors.amber, width: 2)
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${size}x$size',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : GameColors.lightText,
                            ),
                          ),
                          if (isRanked) ...[
                            const SizedBox(height: 4),
                            Icon(
                              Icons.emoji_events,
                              size: 14,
                              color: isSelected ? Colors.amber : Colors.amber.shade700,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Only 4x4 games are eligible for the leaderboard',
              style: TextStyle(
                fontSize: 12,
                color: GameColors.lightText.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GameColors.lightText,
                ),
              ),
              const Spacer(),
              Text(
                '4x4 only',
                style: TextStyle(
                  fontSize: 12,
                  color: GameColors.lightText.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_leaderboard.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 48,
                    color: GameColors.lightText.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No scores yet!\nBe the first to play.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: GameColors.lightText.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(_leaderboard.length, (index) {
              final entry = _leaderboard[index];
              final rank = index + 1;
              return _buildLeaderboardEntry(rank, entry);
            }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(int rank, LeaderboardEntry entry) {
    Color? medalColor;
    if (rank == 1) medalColor = Colors.amber;
    if (rank == 2) medalColor = Colors.grey.shade400;
    if (rank == 3) medalColor = Colors.brown.shade300;

    final isCurrentUser = entry.username == _existingUsername;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.blue.withValues(alpha: 0.1)
            : GameColors.background,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: Colors.blue.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: medalColor != null
                ? Icon(Icons.emoji_events, color: medalColor, size: 20)
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: GameColors.lightText.withValues(alpha: 0.5),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.username,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: isCurrentUser ? Colors.blue : GameColors.lightText,
              ),
            ),
          ),
          Text(
            entry.score.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCurrentUser ? Colors.blue : GameColors.gridBackground,
            ),
          ),
        ],
      ),
    );
  }
}
