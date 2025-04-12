import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/pantry_item.dart';

class AddItemScreen extends StatefulWidget {
  final PantryItem? item;

  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedUnit = 'kg';
  String _selectedCategory = 'Groceries';
  DateTime? _expiryDate;
  bool _isListening = false;
  final SpeechToText _speechToText = SpeechToText();

  final List<String> _units = ['kg', 'g', 'l', 'ml', 'pcs'];
  final List<String> _categories = [
    'Groceries',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Spices',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _selectedUnit = widget.item!.unit;
      _selectedCategory = widget.item!.category;
      _expiryDate = widget.item!.expiryDate;
      _notesController.text = widget.item!.notes ?? '';
    }
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            _nameController.text = result.recognizedWords;
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() => _expiryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _startListening,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a quantity';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: _units.map((String unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedUnit = newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedCategory = newValue);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expiry Date'),
              subtitle: Text(
                _expiryDate == null
                    ? 'Not set'
                    : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.item == null ? 'Add Item' : 'Update Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = PantryItem(
        id: widget.item?.id,
        name: _nameController.text,
        quantity: double.parse(_quantityController.text),
        unit: _selectedUnit,
        category: _selectedCategory,
        expiryDate: _expiryDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      Navigator.pop(context, item);
    }
  }
} 