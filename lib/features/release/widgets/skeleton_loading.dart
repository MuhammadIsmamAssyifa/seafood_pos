import 'package:flutter/material.dart';

class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.margin,
  });

  /// Factory for a text line skeleton
  factory SkeletonLoading.text({
    Key? key,
    double width = double.infinity,
    double height = 16,
  }) =>
      SkeletonLoading(
        key: key,
        width: width,
        height: height,
        borderRadius: 4,
      );

  /// Factory for a card skeleton
  factory SkeletonLoading.card({
    Key? key,
    double width = double.infinity,
    double height = 120,
    EdgeInsetsGeometry? margin,
  }) =>
      SkeletonLoading(
        key: key,
        width: width,
        height: height,
        borderRadius: 12,
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      );

  /// Factory for list items skeleton
  static Widget list({int itemCount = 4, double itemHeight = 72}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            SkeletonLoading(width: itemHeight, height: itemHeight, borderRadius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 140, height: 16),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: 90, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Factory for grid cards skeleton (e.g. Menu, Tables)
  static Widget grid({int itemCount = 6, double aspectRatio = 1.2}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonLoading(
        height: double.infinity,
        borderRadius: 14,
      ),
    );
  }

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha((_animation.value * 255).round()),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
