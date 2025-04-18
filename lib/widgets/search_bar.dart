import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    required this.onSearch,
    this.onFilterTap,
    this.showFilterButton = true,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppTheme.textSecondaryColor.withOpacity(0.7),
                ),
              ),
              onChanged: widget.onSearch,
              onSubmitted: widget.onSearch,
            ),
          ),
          if (_showClearButton)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.textSecondaryColor),
              onPressed: () {
                _controller.clear();
                widget.onSearch('');
              },
            ),
          if (widget.showFilterButton)
            IconButton(
              icon: const Icon(Icons.filter_list, color: AppTheme.primaryColor),
              onPressed: widget.onFilterTap,
            ),
        ],
      ),
    );
  }
}
