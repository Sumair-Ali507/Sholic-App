import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TagSelectionScreen extends StatefulWidget {
  final List<String> selectedTags;

  TagSelectionScreen({required this.selectedTags});

  @override
  _TagSelectionScreenState createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  final _tagController = TextEditingController();
  List<String> _availableTags = [];
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.selectedTags;
    _fetchTags();
  }

  void _fetchTags() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('tags').get();
    setState(() {
      _availableTags = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  void _addTag() async {
    String newTag = _tagController.text.trim();
    if (newTag.isNotEmpty && newTag.length >= 3) {
      await FirebaseFirestore.instance.collection('tags').add({'name': newTag});
      setState(() {
        _availableTags.add(newTag);
        _tagController.clear();
      });
    }
  }

  void _editTag(String oldTag, String newTag) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('tags').where('name', isEqualTo: oldTag).get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await FirebaseFirestore.instance.collection('tags').doc(docId).update({'name': newTag});
      setState(() {
        int index = _availableTags.indexOf(oldTag);
        if (index != -1) {
          _availableTags[index] = newTag;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Tags'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Enter Tag',
                hintText: 'Add a new tag (min. 3 chars)',
                prefixIcon: Icon(Icons.tag, color: Colors.teal),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.teal),
                  onPressed: _addTag,
                ),
                filled: true,
                fillColor: Colors.teal.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _availableTags.length,
                itemBuilder: (context, index) {
                  String tag = _availableTags[index];
                  bool isSelected = _selectedTags.contains(tag);
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Colors.teal : Colors.grey.shade300,
                        child: Icon(
                          isSelected ? Icons.check : Icons.tag,
                          color: isSelected ? Colors.white : Colors.teal,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.teal),
                        onPressed: () {
                          TextEditingController _editController = TextEditingController(text: tag);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Edit Tag'),
                                content: TextField(
                                  controller: _editController,
                                  decoration: InputDecoration(
                                    labelText: 'Tag Name',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      _editTag(tag, _editController.text.trim());
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save', style: TextStyle(color: Colors.teal)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(tag);
                          } else {
                            _selectedTags.add(tag);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context, _selectedTags);
              },
              child: Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
