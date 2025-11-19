import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:password_manager/features/home/bloc/home_event.dart';
import 'package:password_manager/features/home/bloc/home_state.dart';
import '../bloc/home_bloc.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    Key? key,
    required TextEditingController controller,
    required Null Function(dynamic value) onChanged,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();
    context.read<HomeBloc>().add(SearchPasswords(query));
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(16),
      child: _isExpanded
          ? _buildExpandedSearchBar()
          : _buildCollapsedSearchBar(),
    );
  }

  Widget _buildCollapsedSearchBar() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Text(
              'Пошук паролів...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Введіть текст для пошуку...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: _toggleExpanded,
                  icon: const Icon(Icons.close),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          _buildSearchSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded && state.searchQuery.isNotEmpty) {
          final suggestions = _getSearchSuggestions(state.searchQuery);

          if (suggestions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Нічого не знайдено',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Швидкі фільтри:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...suggestions.map(
                (suggestion) => _buildSuggestionChip(suggestion),
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<String> _getSearchSuggestions(String query) {
    final suggestions = <String>[];
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('email') || lowerQuery.contains('gmail')) {
      suggestions.add('email');
    }
    if (lowerQuery.contains('social') || lowerQuery.contains('facebook')) {
      suggestions.add('social');
    }
    if (lowerQuery.contains('work') || lowerQuery.contains('github')) {
      suggestions.add('work');
    }
    if (lowerQuery.contains('shop') || lowerQuery.contains('amazon')) {
      suggestions.add('shopping');
    }
    if (lowerQuery.contains('entertainment') ||
        lowerQuery.contains('netflix')) {
      suggestions.add('entertainment');
    }

    return suggestions;
  }

  Widget _buildSuggestionChip(String suggestion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ActionChip(
        label: Text(suggestion),
        onPressed: () {
          _controller.text = suggestion;
          _onSearchChanged();
        },
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
