import 'package:flutter/material.dart';

import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Danh sách học sinh',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _students = [];

  bool _isLoading = true;
  void _refreshStudents() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _students = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingStudent =
          _students.firstWhere((element) => element['id'] == id);
      _nameController.text = existingStudent['name'];
      _addressController.text = existingStudent['address'];
      _gpaController.text = existingStudent['gpa'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(hintText: 'Address'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _gpaController,
                    decoration: const InputDecoration(hintText: 'GPA'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      _nameController.text = '';
                      _addressController.text = '';
                      _gpaController.text = '';

                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Tạo mới' : 'Cập nhật'),
                  )
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _nameController.text, _addressController.text, _gpaController.text);
    _refreshStudents();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _nameController.text, _addressController.text, _gpaController.text);
    _refreshStudents();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a student!'),
    ));
    _refreshStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách học sinh'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title:
                        Text('Name: ${_students[index]['name'] ?? 'No Name'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                            'Address: ${_students[index]['address'] ?? 'No Address'}'),
                        const SizedBox(height: 10),
                        Text('GPA: ${_students[index]['gpa'] ?? 'No GPA'}'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_students[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_students[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
