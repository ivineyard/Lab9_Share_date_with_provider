import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// =========================================================================
// 1. SECURE DATA MODEL (ChangeNotifier)
// =========================================================================
class ItemListModel extends ChangeNotifier {
  // Private encapsulated data structure
  final List<String> _items = [];

  // Encapsulated read methods instead of a direct list getter
  int get itemCount => _items.length;

  String getItem(int index) {
    return _items[index];
  }

  // Mutator methods
  void addItem(String item) {
    if (item.trim().isNotEmpty) {
      _items.add(item);
      notifyListeners(); // Triggers continuous UI rebuilds
    }
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners(); // Triggers continuous UI rebuilds
  }
}

// =========================================================================
// 2. MAIN ENTRY & APP SHELL
// =========================================================================
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ItemListModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Provider List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// =========================================================================
// 3. HOME LIST SCREEN
// =========================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch automatically updates when changes happen
    final count = context.watch<ItemListModel>().itemCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Items ($count)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: count == 0
          ? const Center(
              child: Text(
                'No items yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) {
                // Safely reading the data through the secure getter method
                final item = context.watch<ItemListModel>().getItem(index);
                
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      // context.read handles single trigger events
                      context.read<ItemListModel>().removeItem(index);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =========================================================================
// 4. ADD ITEM SCREEN
// =========================================================================
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  // context.read updates the state without watching for changes here
                  context.read<ItemListModel>().addItem(_controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Item'),
            ),
          ],
        ),
      ),
    );
  }
}