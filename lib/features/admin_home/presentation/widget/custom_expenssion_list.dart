import 'package:flutter/material.dart';

class CustomExpansionList extends StatelessWidget {
  final String title;
  final List<String> items;

  const CustomExpansionList({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: items
            .map(
              (item) => ListTile(
            title: Text(item),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Handle item tap
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clicked on $item')),
              );
            },
          ),
        )
            .toList(),
      ),
    );
  }
}