import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Text Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DynamicFormPage(),
    );
  }
}

class DynamicFormPage extends StatefulWidget {
  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? activeField; // Track which field is currently being edited

  @override
  void initState() {
    super.initState();

    // Add listeners to track which field is being edited
    nameController.addListener(() {
      setState(() {
        activeField = 'name';
      });
    });

    lastNameController.addListener(() {
      setState(() {
        activeField = 'lastName';
      });
    });

    ageController.addListener(() {
      setState(() {
        activeField = 'age';
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Widget buildHighlightedText() {
    String name = nameController.text.isEmpty ? '{Name}' : nameController.text;
    String lastName =
        lastNameController.text.isEmpty
            ? '{LastName}'
            : lastNameController.text;
    String age = ageController.text.isEmpty ? '{Age}' : ageController.text;

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.5),
        children: [
          TextSpan(text: 'The patient name is '),
          TextSpan(
            text: name,
            style: TextStyle(
              decoration:
                  activeField == 'name' ? TextDecoration.underline : null,
              decorationColor: Colors.blue,
              decorationThickness: 2.0,
              backgroundColor:
                  activeField == 'name' ? Colors.blue.withOpacity(0.1) : null,
              fontWeight:
                  activeField == 'name' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          TextSpan(text: ', he is '),
          TextSpan(
            text: age,
            style: TextStyle(
              decoration:
                  activeField == 'age' ? TextDecoration.underline : null,
              decorationColor: Colors.blue,
              decorationThickness: 2.0,
              backgroundColor:
                  activeField == 'age' ? Colors.blue.withOpacity(0.1) : null,
              fontWeight:
                  activeField == 'age' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          TextSpan(text: ' years old, his last name is '),
          TextSpan(
            text: lastName,
            style: TextStyle(
              decoration:
                  activeField == 'lastName' ? TextDecoration.underline : null,
              decorationColor: Colors.blue,
              decorationThickness: 2.0,
              backgroundColor:
                  activeField == 'lastName'
                      ? Colors.blue.withOpacity(0.1)
                      : null,
              fontWeight:
                  activeField == 'lastName'
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          TextSpan(text: '.'),
          TextSpan(text: '\n\n'),
          TextSpan(text: 'Patient Summary:\n'),
          TextSpan(text: '• Full Name: '),
          TextSpan(
            text: '${name} ${lastName}',
            style: TextStyle(
              decoration:
                  (activeField == 'name' || activeField == 'lastName')
                      ? TextDecoration.underline
                      : null,
              decorationColor: Colors.green,
              backgroundColor:
                  (activeField == 'name' || activeField == 'lastName')
                      ? Colors.green.withOpacity(0.1)
                      : null,
            ),
          ),
          TextSpan(text: '\n• Age: '),
          TextSpan(
            text: age,
            style: TextStyle(
              decoration:
                  activeField == 'age' ? TextDecoration.underline : null,
              decorationColor: Colors.orange,
              backgroundColor:
                  activeField == 'age' ? Colors.orange.withOpacity(0.1) : null,
            ),
          ),
          TextSpan(text: ' years old'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Text Form'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Left Side - Form Fields
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Name Field
                  Text(
                    'Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter patient name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 24),

                  // Last Name Field
                  Text(
                    'Last Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter last name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 24),

                  // Age Field
                  Text(
                    'Age',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(
                      hintText: 'Enter age',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),

                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Type in any field to see real-time updates\n• Active field will be highlighted on the right\n• Empty fields show placeholder text',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side - Display Text
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generated Text',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: buildHighlightedText(),
                  ),

                  if (activeField != null) ...[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.green[600], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Currently editing: ${activeField == 'name'
                                ? 'Name'
                                : activeField == 'lastName'
                                ? 'Last Name'
                                : 'Age'}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
