import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import 'package:password_manager/features/home/bloc/home_state.dart';
import 'package:password_manager/features/home/models/category_model.dart';
import '../bloc/home_bloc.dart';
import '../models/password_model.dart';
import '../presentation/edit_password_page.dart';
import 'password_item_widget.dart';

class PasswordListWidget extends StatefulWidget {
  final List<Password> passwords;
  final void Function(dynamic password) onPasswordDelete;
  final void Function(dynamic password) onPasswordEdit;
  final void Function(dynamic password) onPasswordTap;

  const PasswordListWidget({
    Key? key,
    required this.passwords,
    required this.onPasswordDelete,
    required this.onPasswordEdit,
    required this.onPasswordTap,
  }) : super(key: key);

  @override
  State<PasswordListWidget> createState() => _PasswordListWidgetState();
}

class _PasswordListWidgetState extends State<PasswordListWidget> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isRefreshing = false;
  HomeLoaded? _lastState;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeLoading && _isRefreshing) {
          // Don't do anything, we're already refreshing
        } else if (state is HomeLoaded && _isRefreshing) {
          // Refresh completed
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _isRefreshing = false;
              });
            }
          });
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading && !_isRefreshing) {
            return _buildLoadingState();
          }
          
          if (state is HomeError) {
            return _buildErrorState(context, state.message);
          }
          
          if (state is HomeLoaded) {
            _lastState = state;
            if (state.filteredPasswords.isEmpty) {
              return _buildEmptyState(context, state);
            }
            
            return _buildPasswordList(context, state);
          }
          
          // If we have a previous state, show it
          if (_lastState != null) {
            if (_lastState!.filteredPasswords.isEmpty) {
              return _buildEmptyState(context, _lastState!);
            }
            return _buildPasswordList(context, _lastState!);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const PasswordItemSkeleton();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Помилка завантаження',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeBloc>().add(LoadPasswords()),
              icon: const Icon(Icons.refresh),
              label: const Text('Спробувати знову'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeLoaded state) {
    final hasSearchQuery = state.searchQuery.isNotEmpty;
    final hasCategoryFilter = state.selectedCategoryId != 'All';
    final isFavoritesFilter = state.selectedCategoryId == 'Favorites';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isFavoritesFilter
                    ? Icons.favorite_border_rounded
                    : hasSearchQuery || hasCategoryFilter
                        ? Icons.search_off_rounded
                        : Icons.lock_open_rounded,
                key: ValueKey('${hasSearchQuery}_${hasCategoryFilter}_$isFavoritesFilter'),
                size: 80,
                color: isFavoritesFilter ? Colors.red.shade300 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFavoritesFilter
                  ? 'Немає улюблених паролів'
                  : hasSearchQuery || hasCategoryFilter
                      ? 'Нічого не знайдено'
                      : 'Немає паролів',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFavoritesFilter
                  ? 'Додайте паролі в улюблені, натиснувши на іконку сердечка'
                  : hasSearchQuery || hasCategoryFilter
                      ? 'Спробуйте змінити фільтри пошуку або очистити їх'
                      : 'Додайте ваш перший пароль, щоб почати зберігати їх безпечно',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasSearchQuery || hasCategoryFilter) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _clearFilters(context);
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Очистити фільтри'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordList(BuildContext context, HomeLoaded state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Prevent RefreshIndicator from triggering on programmatic scroll
        if (notification is ScrollUpdateNotification && _isRefreshing) {
          return true;
        }
        return false;
      },
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          if (_isRefreshing) {
            return;
          }
          setState(() {
            _isRefreshing = true;
          });
          try {
            HapticFeedback.lightImpact();
            context.read<HomeBloc>().add(LoadPasswords());
            // Wait for the state to update
            await Future.delayed(const Duration(milliseconds: 800));
          } finally {
            if (mounted) {
              setState(() {
                _isRefreshing = false;
              });
            }
          }
        },
        child: ListView.builder(
          key: PageStorageKey('password_list'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.filteredPasswords.length,
          itemBuilder: (context, index) {
            final password = state.filteredPasswords[index];
            return _buildSlidablePasswordItem(context, password);
          },
        ),
      ),
    );
  }

  Widget _buildSlidablePasswordItem(BuildContext context, Password password) {
    return Slidable(
      key: ValueKey(password.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.mediumImpact();
              _editPassword(context, password);
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Редагувати',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) {
              HapticFeedback.heavyImpact();
              _deletePasswordWithUndo(context, password);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Видалити',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: PasswordItemWidget(
        password: password,
        onTap: () {
          HapticFeedback.selectionClick();
          _showPasswordDetails(context, password);
        },
        onEdit: () => _editPassword(context, password),
        onDelete: () => _deletePasswordWithUndo(context, password),
        onCopyPassword: () {
          HapticFeedback.lightImpact();
          _copyPassword(context, password.password);
        },
        onCopyUsername: () {
          HapticFeedback.lightImpact();
          _copyPassword(context, password.username);
        },
      ),
    );
  }

  void _showPasswordDetails(BuildContext context, Password password) {
    showDialog(
      context: context,
      builder: (context) => PasswordDetailsDialog(password: password),
    );
  }

  void _editPassword(BuildContext context, Password password) {
    // Navigate to edit password screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPasswordPage(password: password),
      ),
    );
  }

  void _deletePasswordWithUndo(BuildContext context, Password password) {
    final passwordToRestore = password;
    
    // Delete password
    context.read<HomeBloc>().add(DeletePassword(password.id));
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Пароль "${password.title}" видалено'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Скасувати',
          textColor: Colors.white,
          onPressed: () {
            HapticFeedback.lightImpact();
            // Restore password
            context.read<HomeBloc>().add(RestorePassword(passwordToRestore));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Пароль "${password.title}" відновлено'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _copyPassword(BuildContext context, String text) {
    // In a real app, this would copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Скопійовано: ${text.substring(0, text.length > 20 ? 20 : text.length)}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearFilters(BuildContext context) {
    context.read<HomeBloc>().add(SearchPasswords(''));
    context.read<HomeBloc>().add(FilterByCategory('All'));
  }
}

class PasswordDetailsDialog extends StatelessWidget {
  final Password password;

  const PasswordDetailsDialog({Key? key, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = PredefinedCategories.getCategoryById(password.categoryId);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (category != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category.icon,
                      size: 20,
                      color: category.color,
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              password.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (password.website.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.link, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      password.website,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailRow('Користувач:', password.username, Icons.person),
            _buildDetailRow('Пароль:', '•' * password.password.length, Icons.lock),
            if (password.notes.isNotEmpty)
              _buildDetailRow('Примітки:', password.notes, Icons.note),
            const SizedBox(height: 16),
            _buildStrengthIndicator(),
            const SizedBox(height: 16),
            if (password.tags.isNotEmpty) _buildTags(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  'Копіювати пароль',
                  Icons.key,
                  Colors.blue,
                ),
                _buildActionButton(
                  context,
                  'Копіювати логін',
                  Icons.person,
                  Colors.green,
                ),
                _buildActionButton(
                  context,
                  'Редагувати',
                  Icons.edit,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Сила пароля:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return Container(
                  width: 20,
                  height: 8,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: index < password.strength 
                        ? password.strengthColor 
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              password.strengthText,
              style: TextStyle(
                fontSize: 12,
                color: password.strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Теги:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: password.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}