import 'package:flutter/material.dart';

class ARControls extends StatelessWidget {
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback? onScaleUp;
  final VoidCallback? onScaleDown;
  final VoidCallback onDelete;
  final bool isEnabled;

  const ARControls({
    super.key,
    required this.onRotateLeft,
    required this.onRotateRight,
    this.onScaleUp,
    this.onScaleDown,
    required this.onDelete,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Rotate Left
          _buildControlButton(
            icon: Icons.rotate_left,
            label: 'Rotate',
            onPressed: isEnabled ? onRotateLeft : null,
          ),

          // Rotate Right
          _buildControlButton(
            icon: Icons.rotate_right,
            label: 'Rotate',
            onPressed: isEnabled ? onRotateRight : null,
          ),

          // Delete
          _buildControlButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onPressed: isEnabled ? onDelete : null,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final isDisabled = onPressed == null;
    final buttonColor = color ?? const Color(0xFF0058A3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: isDisabled ? Colors.grey.shade400 : buttonColor,
          iconSize: 28,
          style: IconButton.styleFrom(
            backgroundColor: isDisabled
                ? Colors.grey.shade200
                : buttonColor.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDisabled ? Colors.grey.shade400 : Colors.black,
          ),
        ),
      ],
    );
  }
}
