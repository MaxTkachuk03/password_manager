import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import 'package:password_manager/features/home/bloc/home_state.dart';
import '../bloc/home_bloc.dart';
import '../models/category_model.dart';

class CategoryFilterWidget extends StatelessWidget {
  const CategoryFilterWidget({super.key, required String selectedCategory, required Null Function(dynamic category) onCategorySelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            return _buildCategoryList(context, state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, HomeLoaded state) {
    final categoryNames = PredefinedCategories.getCategoryNames();
    final selectedCategoryId = state.selectedCategoryId;
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categoryNames.length + 1, // +1 for Favorites
      itemBuilder: (context, index) {
        // First item is "All"
        if (index == 0) {
          final isSelected = 'All' == selectedCategoryId;
          return _buildCategoryChip(
            context,
            'All',
            Icons.apps,
            Colors.grey,
            isSelected,
            () => _selectCategory(context, 'All'),
          );
        }
        
        // Second item is "Favorites"
        if (index == 1) {
          final isSelected = 'Favorites' == selectedCategoryId;
          return _buildCategoryChip(
            context,
            'Улюблені',
            Icons.favorite,
            Colors.red,
            isSelected,
            () => _selectCategory(context, 'Favorites'),
          );
        }
        
        // Rest are categories
        final categoryName = categoryNames[index - 1];
        final categoryId = PredefinedCategories.getIdByName(categoryName);
        final isSelected = categoryId == selectedCategoryId;
        
        final category = PredefinedCategories.getCategoryById(categoryId);
        if (category == null) return const SizedBox.shrink();
        
        return _buildCategoryChip(
          context,
          category.name,
          category.icon,
          category.color,
          isSelected,
          () => _selectCategory(context, category.id),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectCategory(BuildContext context, String categoryId) {
    context.read<HomeBloc>().add(FilterByCategory(categoryId));
  }

  Widget _buildCategoryCount(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CategoryFilterDialog extends StatelessWidget {
  const CategoryFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Фільтр по категоріях',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  return _buildCategoryGrid(context, state);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, HomeLoaded state) {
    final categories = [
      {'name': 'All', 'id': 'All', 'icon': Icons.apps, 'color': Colors.grey},
      ...PredefinedCategories.categories.map((category) => {
            'name': category.name,
            'id': category.id,
            'icon': category.icon,
            'color': category.color,
          }),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category['id'] == state.selectedCategoryId;
        
        return GestureDetector(
          onTap: () {
            context.read<HomeBloc>().add(FilterByCategory(category['id'] as String));
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? category['color'] as Color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? category['color'] as Color 
                    : (category['color'] as Color).withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 24,
                  color: isSelected ? Colors.white : category['color'] as Color,
                ),
                const SizedBox(height: 4),
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : category['color'] as Color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}