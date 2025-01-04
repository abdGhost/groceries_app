import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';
import 'package:groceries_app/widgets/new_items.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> groceryItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'groceriesapp-e76b0-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    final response = await http.get(url);
    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> _loadItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;

      _loadItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      groceryItems = _loadItems;
    });
  }

  void _addItem() async {
    await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItems(),
      ),
    );
    _loadItems();
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No Items added yet!'),
    );

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(groceryItems[index]);
          },
          key: ValueKey(
            groceryItems[index].id,
          ),
          child: ListTile(
            title: Text(
              groceryItems[index].name,
            ),
            leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[index].category.color,
            ),
            trailing: Text(
              groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
