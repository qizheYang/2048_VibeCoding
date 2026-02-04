# 2048 Magicful Edition

A modern take on the classic 2048 puzzle game, built with Flutter. Features magical abilities that let you manipulate tiles at the cost of your score.

## Play Online

[Play 2048 Magicful Edition](https://qizheyang.github.io/game/2048/)

## Features

- **Classic 2048 Gameplay**: Slide tiles to combine matching numbers and reach 2048
- **Multiple Grid Sizes**: Choose between 3x3, 4x4, 5x5, or 6x6 grids
- **Magic Abilities**: Use your score to activate special powers:
  - **Double Tile**: Double any tile's value
  - **Swap Tiles**: Swap positions of any two tiles
  - **Remove Tile**: Remove any tile from the board
  - **Regenerate**: Re-roll the last spawned tile
  - **Undo**: Revert your last move (free!)
- **Leaderboard**: Compete for high scores (4x4 mode only)
- **Cross-Platform**: Works on web, iOS, Android, macOS, Windows, and Linux

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **shared_preferences** - Local storage for user data and leaderboard

## Development

### Prerequisites

- Flutter SDK (^3.10.7)
- Dart SDK

### Running Locally

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on macOS
flutter run -d macos
```

### Building for Web

```bash
flutter build web
```

The built files will be in `build/web/`.

## Auto-Deployment

This repository is configured with GitHub Actions to automatically build and deploy to [qizheyang.github.io](https://qizheyang.github.io/game/2048/) when changes are pushed to the main branch.

## License

MIT License
