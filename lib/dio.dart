import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AskPage extends StatefulWidget {
  @override
  _AskPageState createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  String _response = '';
  bool _isLoading = false;

  Future<void> sendRequest() async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: 60),
      receiveTimeout: Duration(seconds: 60),
    ));

    try {
      final response = await dio.post(
        'http://localhost:5050/ask',
        data: {'message': 'turmush qurish haqida qollanma'},
      );

      setState(() {
        _response = response.data.toString();
      });
    } catch (e) {
      setState(() {
        _response = 'Xatolik yuz berdi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('So‘rov yuborish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : sendRequest,
              child: Text('So‘rov yuborish'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Text(
                    _response,
                    style: TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
