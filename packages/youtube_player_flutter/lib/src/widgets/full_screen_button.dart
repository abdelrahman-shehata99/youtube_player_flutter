// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../utils/youtube_player_controller.dart';

/// A widget to display the full screen toggle button.
class FullScreenButton extends StatefulWidget {
  /// Creates [FullScreenButton] widget.
  const FullScreenButton({
    super.key,
    this.controller,
    this.color = Colors.white,
  });

  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController? controller;

  /// Defines color of the button.
  final Color color;

  @override
  State<FullScreenButton> createState() => _FullScreenButtonState();
}

class _FullScreenButtonState extends State<FullScreenButton> {
  late YoutubePlayerController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = YoutubePlayerController.of(context);
    if (controller == null) {
      assert(
        widget.controller != null,
        '\n\nNo controller could be found in the provided context.\n\n'
        'Try passing the controller explicitly.',
      );
      _controller = widget.controller!;
    } else {
      _controller = controller;
    }
    _controller.removeListener(listener);
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) setState(() {});
  }

  void _handleFullscreenToggle() {
    if (_controller.value.isFullScreen) {
      _controller.exitFullScreen();
    } else {
      final playerBuilder = _FullscreenPlayerBuilder.of(context);
      if (playerBuilder != null) {
        final player = playerBuilder.buildPlayer();
        _controller.enterFullScreen(context, player);
      } else {
        _controller.toggleFullScreenMode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _controller.value.isFullScreen
            ? Icons.fullscreen_exit
            : Icons.fullscreen,
        color: widget.color,
      ),
      onPressed: _handleFullscreenToggle,
    );
  }
}

/// Provides a way to build the player widget for fullscreen mode.
class _FullscreenPlayerBuilder extends InheritedWidget {
  const _FullscreenPlayerBuilder({
    required this.buildPlayer,
    required super.child,
  });

  final Widget Function() buildPlayer;

  static _FullscreenPlayerBuilder? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FullscreenPlayerBuilder>();
  }

  @override
  bool updateShouldNotify(_FullscreenPlayerBuilder oldWidget) => false;
}

/// Wrap your YoutubePlayer with this widget to enable proper fullscreen support.
class FullscreenPlayerProvider extends StatelessWidget {
  const FullscreenPlayerProvider({
    super.key,
    required this.child,
    required this.playerBuilder,
  });

  final Widget child;
  final Widget Function() playerBuilder;

  @override
  Widget build(BuildContext context) {
    return _FullscreenPlayerBuilder(
      buildPlayer: playerBuilder,
      child: child,
    );
  }
}
