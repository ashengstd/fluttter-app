import 'package:flutter/material.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String heroTag;

  const AnimatedFloatingActionButton({
    required this.child,
    required this.onPressed,
    required this.heroTag,
    super.key,
  });

  @override
  AnimatedFloatingActionButtonState createState() =>
      AnimatedFloatingActionButtonState();
}

class AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: FloatingActionButton(
        heroTag: widget.heroTag,
        onPressed: widget.onPressed,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: widget.child,
      ),
    );
  }
}
