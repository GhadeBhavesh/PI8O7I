import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCU_M32ciniLVsotqGaQxUX6593V1sL2DA",
      appId: "1:77417343007:android:e85ad5b9e1c35893e60d2a",
      messagingSenderId: "77417343007",
      projectId: "care-59e97",
    ),
  ).then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assignment App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.lightGreenAccent[100],
      ),
      home: const HomePage(),
    );
  }
}

class WidgetSelectorPage extends StatefulWidget {
  final List<String> selectedWidgets;

  const WidgetSelectorPage({
    Key? key,
    required this.selectedWidgets,
  }) : super(key: key);

  @override
  _WidgetSelectorPageState createState() => _WidgetSelectorPageState();
}

class _WidgetSelectorPageState extends State<WidgetSelectorPage> {
  late List<String> _selectedWidgets;

  @override
  void initState() {
    super.initState();
    _selectedWidgets = List.from(widget.selectedWidgets);
  }

  Widget _buildSelectorOption(String title, String value) {
    bool isSelected = _selectedWidgets.contains(value);
    return Container(
      width: 300, // Fixed width for consistent sizing
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.lightGreenAccent : Colors.white,
            border: Border.all(color: Colors.grey),
          ),
        ),
        title: Text(title),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedWidgets.remove(value);
            } else {
              _selectedWidgets.add(value);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Wrap with Center widget
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  // Center the Column
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Center items vertically
                    children: [
                      _buildSelectorOption('Text Widget', 'textbox'),
                      _buildSelectorOption('Image Widget', 'imagebox'),
                      _buildSelectorOption('Button Widget', 'savebutton'),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 220,
              height: 50,
              margin: const EdgeInsets.only(bottom: 80),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedWidgets);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                child: const Text(
                  'Import Widgets',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _selectedWidgets = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isLoading = false;
  bool _showWarning = false; // New state variable for warning message

  Future<void> _navigateToWidgetSelector() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetSelectorPage(
          selectedWidgets: _selectedWidgets,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedWidgets.clear();
        _selectedWidgets.addAll(result);
        _showWarning = false; // Reset warning when widgets change
      });
    }
  }

  Future<void> _saveData() async {
    if (!_selectedWidgets.contains('textbox') &&
        !_selectedWidgets.contains('imagebox')) {
      setState(() {
        _showWarning = true; // Show warning instead of snackbar
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('widgets').add({
        'text': _textController.text,
        'imageUrl': _imageUrlController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _textController.clear();
        _imageUrlController.clear();
        _showWarning = false; // Clear warning on successful save
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Assignment App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightGreenAccent[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedWidgets.isEmpty)
                    const Text(
                      'No widget is added',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_selectedWidgets.contains('textbox'))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Text',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  if (_selectedWidgets.contains('imagebox'))
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('Upload Image'),
                      ),
                    ),
                  if (_selectedWidgets.contains('savebutton')) ...[
                    if (_showWarning) // Show warning message above save button
                      Container(
                        padding: const EdgeInsets.all(80),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: const Text(
                          'Add at-least a widget to save',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            width: 220,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton.extended(
              onPressed: _navigateToWidgetSelector,
              label: const Text(
                'Add Widgets',
                style: TextStyle(color: Colors.black87),
              ),
              backgroundColor: Colors.lightGreenAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.black, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
