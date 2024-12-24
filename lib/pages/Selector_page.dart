import 'package:flutter/material.dart';

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
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedWidgets.remove(value);
              } else {
                _selectedWidgets.add(value);
              }
            });
          },
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Color.fromARGB(255, 84, 236, 84)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
      backgroundColor: Color.fromARGB(255, 240, 252, 236),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 240, 252, 236),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSelectorOption('Text Widget', 'textbox'),
                      const SizedBox(height: 80),
                      _buildSelectorOption('Image Widget', 'imagebox'),
                      const SizedBox(height: 80),
                      _buildSelectorOption('Button Widget', 'savebutton'),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                width: 220,
                height: 50,
                margin: const EdgeInsets.only(bottom: 80),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedWidgets);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 176, 252, 172),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Import Widgets',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
