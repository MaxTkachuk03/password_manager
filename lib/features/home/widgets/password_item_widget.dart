import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import '../bloc/home_bloc.dart';
import '../models/password_model.dart';
import '../models/category_model.dart';

class PasswordItemWidget extends StatelessWidget {
  final Password password;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopyPassword;
  final VoidCallback? onCopyUsername;

  const PasswordItemWidget({
    Key? key,
    required this.password,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCopyPassword,
    this.onCopyUsername,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = PredefinedCategories.getCategoryById(password.categoryId);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, category),
                const SizedBox(height: 12),
                _buildTitleAndWebsite(),
                const SizedBox(height: 8),
                _buildUsername(),
                if (password.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildNotes(),
                ],
                const SizedBox(height: 12),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Category? category) {
    return Row(
      children: [
        if (category != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon,
              size: 16,
              color: category.color,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Row(
            children: [
              _buildStrengthIndicator(),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  password.strengthText,
                  style: TextStyle(
                    fontSize: 12,
                    color: password.strengthColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildFavoriteButton(context),
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Container(
          width: 4,
          height: 16,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: index < password.strength 
                ? password.strengthColor 
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggleFavorite(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: password.isFavorite 
              ? Colors.red.withOpacity(0.1) 
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          password.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: password.isFavorite ? Colors.red : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildTitleAndWebsite() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                password.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (password.website.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        password.website,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildUsername() {
    return Row(
      children: [
        Icon(
          Icons.person,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            password.username,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onCopyUsername != null)
          GestureDetector(
            onTap: onCopyUsername,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.content_copy,
                size: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              password.notes,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onCopyPassword != null)
          _buildActionButton(
            Icons.key,
            'Копіювати пароль',
            onCopyPassword!,
            Colors.blue,
          ),
        if (onEdit != null) ...[
          const SizedBox(width: 4),
          _buildActionButton(
            Icons.edit,
            'Редагувати',
            onEdit!,
            Colors.green,
          ),
        ],
        if (onDelete != null) ...[
          const SizedBox(width: 4),
          _buildActionButton(
            Icons.delete,
            'Видалити',
            onDelete!,
            Colors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap, Color color) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTags(),
        _buildTimestamp(),
      ],
    );
  }

  Widget _buildTags() {
    if (password.tags.isEmpty) return const SizedBox.shrink();
    
    return Row(
      children: password.tags.take(3).map((tag) {
        return Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(password.updatedAt);
    
    String timeText;
    if (difference.inDays > 0) {
      timeText = '${difference.inDays} днів тому';
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours} годин тому';
    } else if (difference.inMinutes > 0) {
      timeText = '${difference.inMinutes} хвилин тому';
    } else {
      timeText = 'Щойно';
    }
    
    return Text(
      'Оновлено: $timeText',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade500,
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    context.read<HomeBloc>().add(ToggleFavoritePassword(password.id));
  }
}

class PasswordItemSkeleton extends StatelessWidget {
  const PasswordItemSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSkeletonBox(32, 32, Colors.grey.shade300),
              const SizedBox(width: 8),
              Expanded(child: _buildSkeletonBox(60, 16, Colors.grey.shade300)),
              _buildSkeletonBox(24, 24, Colors.grey.shade300),
            ],
          ),
          const SizedBox(height: 12),
          _buildSkeletonBox(120, 16, Colors.grey.shade400),
          const SizedBox(height: 8),
          _buildSkeletonBox(80, 14, Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}