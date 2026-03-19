import 'package:flutter/material.dart';
import 'game_background.dart';

class GameScaffold extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;

  const GameScaffold({
    super.key,
    this.scaffoldKey,
    required this.child,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBody: extendBody,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          const Positioned.fill(child: GameBackground()),
          SafeArea(
            top: appBar == null,
            bottom: bottomNavigationBar == null,
            child: child,
          ),
        ],
      ),
    );
  }
}
