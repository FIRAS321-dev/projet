import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;
  final bool isEditable;

  const ProfilePhotoWidget({
    Key? key,
    this.photoUrl,
    required this.name,
    this.size = 100,
    this.onTap,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(size / 2),
                    child: Image.network(
                      photoUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitials();
                      },
                    ),
                  )
                : _buildInitials(),
          ),
          if (isEditable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('')
        : '?';
    return Center(
      child: Text(
        initials.substring(0, initials.length > 2 ? 2 : initials.length),
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

