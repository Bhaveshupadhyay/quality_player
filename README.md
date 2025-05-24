## Quality Video Player

A Flutter video player widget that supports both landscape and portrait modes, allowing flexible aspect-ratio handling and stretch-to-fill behavior.

## Features

- Orientation Aware: Automatically switches between native aspect ratio in landscape and fill-to-width in portrait.
- Auto Initialization & Playback: Initializes the VideoPlayerController and begins playback once ready.
- Loading State: Displays a customizable loading indicator until the video is ready.
- Easy Configuration: One widget, minimal setup.

## Installation

```dart
dependencies:
  quality_player: <latest_version>
```

## Usage

```dart
import 'package:player/quality_player.dart';

final qualityPlayer = QualityPlayer('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
```
