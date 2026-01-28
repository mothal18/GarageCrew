import 'package:flutter/material.dart';

import '../models/car_item.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import 'car_thumbnail.dart';

class AnimatedCarCard extends StatefulWidget {
  const AnimatedCarCard({
    super.key,
    required this.car,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.editTooltip = 'Edit',
    this.deleteTooltip = 'Delete',
    this.isDisabled = false,
    this.index = 0,
  });

  final CarItem car;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String editTooltip;
  final String deleteTooltip;
  final bool isDisabled;
  final int index;

  @override
  State<AnimatedCarCard> createState() => _AnimatedCarCardState();
}

class _AnimatedCarCardState extends State<AnimatedCarCard>
    with TickerProviderStateMixin {
  late final AnimationController _tapController;
  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _elevationAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Tap animation controller
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );

    // Entrance animation controller with staggered delay
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Start entrance animation with staggered delay based on index
    Future.delayed(Duration(milliseconds: 50 * (widget.index % 10)), () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tapController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled) {
      _tapController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_tapController, _entranceController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3 + _elevationAnimation.value * 0.02)
                          : Colors.black.withValues(alpha: 0.06 + _elevationAnimation.value * 0.01),
                      blurRadius: 8 + _elevationAnimation.value,
                      offset: Offset(0, 2 + _elevationAnimation.value * 0.5),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.isDisabled ? null : widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark
                    ? colorScheme.outline.withValues(alpha: 0.2)
                    : colorScheme.outline.withValues(alpha: 0.1),
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  _buildThumbnail(isDark),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildContent(theme)),
                  _buildActions(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isDark) {
    return Hero(
      tag: 'car_image_${widget.car.id ?? widget.car.title}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: CarThumbnail(
            url: widget.car.imageUrl,
            size: 72,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.car.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.car.description?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.car.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (widget.car.createdAt != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatDate(widget.car.createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.edit_outlined,
          tooltip: widget.editTooltip,
          onPressed: widget.isDisabled ? null : widget.onEdit,
          color: colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.xs),
        _ActionButton(
          icon: Icons.delete_outline,
          tooltip: widget.deleteTooltip,
          onPressed: widget.isDisabled ? null : widget.onDelete,
          color: colorScheme.error,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 20,
              color: onPressed == null
                  ? color.withValues(alpha: 0.4)
                  : color,
            ),
          ),
        ),
      ),
    );
  }
}
