import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';

enum NotificationType {
  info,
  success,
  warning,
  error,
}

class NotificationBanner extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Duration duration;

  const NotificationBanner({
    Key? key,
    required this.message,
    this.type = NotificationType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // Auto-dismiss after duration
    if (widget.duration != Duration.zero) {
      Future.delayed(widget.duration, () {
        if (mounted && !_isDismissed) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    setState(() {
      _isDismissed = true;
    });
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -100 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.actionLabel != null && widget.onAction != null)
                  TextButton(
                    onPressed: widget.onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      widget.actionLabel!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    
    switch (widget.type) {
      case NotificationType.success:
        iconData = Icons.check_circle;
        break;
      case NotificationType.warning:
        iconData = Icons.warning;
        break;
      case NotificationType.error:
        iconData = Icons.error;
        break;
      case NotificationType.info:
      default:
        iconData = Icons.info;
        break;
    }
    
    return Icon(
      iconData,
      color: Colors.white,
      size: 24,
    );
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return AppTheme.successColor;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return AppTheme.errorColor;
      case NotificationType.info:
      default:
        return AppTheme.primaryColor;
    }
  }
}

