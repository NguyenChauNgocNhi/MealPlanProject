import 'package:flutter/material.dart';

// Định nghĩa 4 loại thông báo
enum NotificationType { success, error, warning, info }

class NotificationStyle {
  final Color backgroundColor;
  final IconData icon;

  const NotificationStyle(this.backgroundColor, this.icon);

  static NotificationStyle of(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return NotificationStyle(Colors.green.shade600, Icons.check_circle);
      case NotificationType.error:
        return NotificationStyle(Colors.red.shade600, Icons.error);
      case NotificationType.warning:
        return NotificationStyle(Colors.orange.shade600, Icons.warning);
      case NotificationType.info:
        return NotificationStyle(Colors.blue.shade600, Icons.info);
    }
  }
}

class SlideInNotification extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismissed; // callback khi thông báo biến mất

  const SlideInNotification({
    super.key,
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<SlideInNotification> createState() => _SlideInNotificationState();
}

class _SlideInNotificationState extends State<SlideInNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late NotificationStyle style;

  @override
  void initState() {
    super.initState();
    style = NotificationStyle.of(widget.type);
    // Tạo animation trượt từ phải → trái 
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // widget nằm lệch sang phải đúng bằng 100% chiều rộng của nó (ngoài màn hình)
      end: const Offset(0.0, 0.0),  // widget nằm đúng vị trí ban đầu (không dịch chuyển)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    // Khi khởi tạo, thông báo trượt vào màn hình. Sau 3 giây, trượt ra ngoài và gọi onDismissed
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), () {
      _controller.reverse().then((_) => widget.onDismissed());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: style.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // horizontal(trái và phải), vertical(trên và dưới)
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(style.icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showRightNotification(BuildContext context, String message, NotificationType type) {
  final overlay = Overlay.of(context); // Tạo một OverlayEntry để hiển thị thông báo trên toàn màn hình
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => Positioned(
      top: 100,
      right: 0,
      child: SlideInNotification(
        message: message,
        type: type,
        onDismissed: () => entry.remove(), // Khi thông báo tự ẩn → gọi entry.remove() để xóa khỏi overlay
      ),
    ),
  );

  overlay.insert(entry);
}
