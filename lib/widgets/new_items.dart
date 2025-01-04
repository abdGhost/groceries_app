import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceries_app/data/categories.dart';
import 'package:groceries_app/models/category.dart';
import 'package:groceries_app/models/grocery_item.dart';

import 'package:http/http.dart' as http;

class NewItems extends StatefulWidget {
  const NewItems({super.key});

  @override
  State<NewItems> createState() {
    return _NewItemsState();
  }
}

class _NewItemsState extends State<NewItems> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables]!;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final url = Uri.https(
        'groceriesapp-e76b0-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );

      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'name': enteredName,
              'quantity': enteredQuantity,
              'category': selectedCategory.title,
            },
          ));

      print(response.statusCode);
      print(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text('Quantity'),
                        ),
                        initialValue: enteredQuantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a valid, positive number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      category.value.title,
                                    ),
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: Text(
                        'Reset',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveItem,
                      child: Text(
                        'Add Item',
                      ),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
