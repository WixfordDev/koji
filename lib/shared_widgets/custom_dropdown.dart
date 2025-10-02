import 'package:flutter/material.dart';

class CustomDynamicDropdownButton extends StatefulWidget {
  final String? hint;

  /// itemList: [{ "id": 30, "name": "Brand" }, ...]
  final List<Map<String, dynamic>> itemList;

  /// onChanged: full map ফেরত দিবে (id+name)
  final ValueChanged<Map<String, dynamic>?>? onChanged;
  final Color? color;
  final Color? borderColors;

  /// চাইলে প্রি-সিলেক্ট আইটেমের id দিতে পারেন
  final dynamic initialId;

  const CustomDynamicDropdownButton({
    super.key,
    this.hint,
    required this.itemList,
    this.onChanged,
    this.color,
    this.borderColors,
    this.initialId,
  });

  @override
  State<CustomDynamicDropdownButton> createState() =>
      _CustomDynamicDropdownButtonState();
}

class _CustomDynamicDropdownButtonState
    extends State<CustomDynamicDropdownButton> {
  dynamic _selectedId; // int বা String

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialId;
    if (_selectedId != null && !_idExists(_selectedId)) {
      _selectedId = null;
    }
  }

  @override
  void didUpdateWidget(covariant CustomDynamicDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // itemList আপডেট হলে, সিলেক্টেড id আর আছে কি না চেক
    if (_selectedId != null && !_idExists(_selectedId)) {
      setState(() => _selectedId = null);
    }
  }

  bool _idExists(dynamic id) {
    return widget.itemList.any((e) => e['id'] == id);
  }

  Map<String, dynamic>? _mapById(dynamic id) {
    try {
      return widget.itemList.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final seen = <dynamic>{};
    final uniqueList = widget.itemList.where((e) {
      final id = e['id'];
      if (seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: widget.color ?? Colors.grey.withAlpha(40),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: widget.borderColors ?? Colors.grey.withAlpha(30),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<dynamic>(
          // 👈 value এখন id (int/String)
          iconEnabledColor: Colors.black,
          isExpanded: true,
          style: const TextStyle(color: Colors.black),
          hint: Text(
            widget.hint ?? "Select",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: "DIN",
            ),
          ),
          value: _selectedId,
          dropdownColor: Colors.white,
          items: uniqueList.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item['id'],
              child: Text(
                item["name"]?.toString() ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.black,
                 // fontFamily: FontConstants.poppinsMedium,
                ),
              ),
            );
          }).toList(),
          onChanged: (newId) {
            setState(() => _selectedId = newId);
            if (widget.onChanged != null) {
              widget.onChanged!(_mapById(newId));
            }
          },
        ),
      ),
    );
  }
}
