import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final baseUrl = "https://api.nstack.in/v1/todos";
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List data = [];

  // Post Data
  Future<void> _postData(String title, String description) async {
    try {
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "description": description}),
      );

      if (response.statusCode == 201) {
        showSnackBarMessage("Post Complete");
        _titleController.clear();
        _descriptionController.clear();
        _fetchData();
      } else {
        showSnackBarMessage("Error : ${response.statusCode}");
      }
    } catch (error) {
      showSnackBarMessage("Error: $error");
    }
  }

  // Fetch Data
  Future<void> _fetchData() async {
    try {
      var response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        final result = list["items"];
        setState(() {
          data = result;
        });
      } else {
        showSnackBarMessage("Error : ${response.statusCode}");
      }
    } catch (e) {
      showSnackBarMessage("Error : $e");
    }
  }

  // Delete Data
  Future<void> _deleteData(id) async {
    try {
      var response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        showSnackBarMessage("Delete Complete");
        _fetchData();
      } else {
        showSnackBarMessage("Error : ${response.statusCode}");
      }
    } catch (error) {
      showSnackBarMessage("Error: $error");
    }
  }

  // Update Data
  Future<void> _updateData(id, String title, String description) async {
    try {
      var response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "description": description}),
      );

      if (response.statusCode == 200) {
        showSnackBarMessage("Update Complete");
        _fetchData();
      } else {
        showSnackBarMessage("Error : ${response.statusCode}");
      }
    } catch (error) {
      showSnackBarMessage("Error: $error");
    }
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Learning Approach",
          style: TextStyle(
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                label: const Text("Title"),
                labelStyle: const TextStyle(
                    color: Colors.deepPurpleAccent, fontSize: 16),
                hintText: "Enter Your Title",
                hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.purple),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.purple, width: 2)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                label: const Text("Description"),
                labelStyle: const TextStyle(
                    color: Colors.deepPurpleAccent, fontSize: 16),
                hintText: "Enter Your Description",
                hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.purple),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(width: 2, color: Colors.purple)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  elevation: 0,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _postData(
                    _titleController.text, _descriptionController.text),
                child: const Text(
                  "Post",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0,
                    color: Colors.purpleAccent.shade100.withOpacity(0.3),
                    child: ListTile(
                      title: Text(data[index]['title']),
                      subtitle: Text(data[index]['description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.purpleAccent,
                            ),
                            onPressed: () {
                              _showUpdateBottomSheet(
                                  data[index]['_id'],
                                  data[index]['title'],
                                  data[index]['description']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.purpleAccent,
                            ),
                            onPressed: () {
                              _deleteData(data[index]['_id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Bottom Sheet for Update
  void _showUpdateBottomSheet(
      id, String currentTitle, String currentDescription) {
    TextEditingController _updatedTitleController =
        TextEditingController(text: currentTitle);
    TextEditingController _updatedDescriptionController =
        TextEditingController(text: currentDescription);

    showModalBottomSheet(
      backgroundColor: Colors.purple.shade50.withOpacity(0.8),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _updatedTitleController,
                decoration: InputDecoration(
                  label: const Text("Update Title"),
                  labelStyle: const TextStyle(
                      color: Colors.deepPurpleAccent, fontSize: 16),
                  hintText: "Enter Your Title",
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.purple),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: Colors.purple, width: 2)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _updatedDescriptionController,
                decoration: InputDecoration(
                  label: const Text("Update Description"),
                  labelStyle: const TextStyle(
                      color: Colors.deepPurpleAccent, fontSize: 16),
                  hintText: "Enter Your Description",
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.purple),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(width: 2, color: Colors.purple)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    elevation: 0,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    _updateData(id, _updatedTitleController.text,
                        _updatedDescriptionController.text);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showSnackBarMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.purpleAccent,
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              message,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            )
          ],
        )));
  }
}
