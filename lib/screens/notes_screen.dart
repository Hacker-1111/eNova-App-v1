import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  final List<String> _categories = ['Glass', 'Work', 'Study', 'More'];
  final Map<String, Color> _categoryColors = {
    'Glass': Colors.yellow[100]!,
    'Work': Colors.green[100]!,
    'Study': Colors.blue[100]!,
    'More': Colors.pink[100]!,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // الخلفية أصبحت بيضاء
      body: _buildNotesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('notes')
              .where('userId', isEqualTo: _user?.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final notes = snapshot.data?.docs ?? [];

        if (notes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline, // يمكنك اختيار أي أيقونة تريدها
                  color: Colors.grey,
                  size: 50,
                ),
                SizedBox(height: 10), // مسافة بين الأيقونة والنص
                Text(
                  'No notes found.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final category = note['category'] ?? 'More';
            final color = _categoryColors[category] ?? Colors.grey.shade200;
            final isFavorite =
                note['isFavorite'] ?? false; // تحقق من حالة المفضلة

            return Dismissible(
              key: Key(note.id),
              direction: DismissDirection.startToEnd, // السحب لليمين
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => _deleteNote(note.id),
              child: GestureDetector(
                onLongPress: () => _showNoteOptions(note),
                child: Card(
                  color: color,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      note['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          note['content'] ?? '',
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Category: $category',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: isFavorite ? Colors.yellow : Colors.grey,
                          ),
                          onPressed:
                              () => _toggleFavorite(note.id, !isFavorite),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(note.id),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addNewNote() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = _categories.first;

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add New Note',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: _inputDecoration('Title'),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: contentController,
                          decoration: _inputDecoration('Content'),
                          maxLines: 3,
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          items:
                              _categories.map((String category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          decoration: _inputDecoration('Category'),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (titleController.text.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('notes')
                                  .add({
                                    'title': titleController.text,
                                    'content': contentController.text,
                                    'category': selectedCategory,
                                    'userId': _user?.uid,
                                    'isFavorite':
                                        false, // تعيين القيمة الافتراضية للمفضلة
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                              Navigator.pop(context, true);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
    );

    if (result == true) {
      setState(() {}); // Refresh the list
    }

    titleController.dispose();
    contentController.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _confirmDelete(String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _deleteNote(noteId);
    }
  }

  Future<void> _deleteNote(String noteId) async {
    await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
  }

  Future<void> _toggleFavorite(String noteId, bool isFavorite) async {
    await FirebaseFirestore.instance.collection('notes').doc(noteId).update({
      'isFavorite': isFavorite,
    });
  }

  Future<void> _showNoteOptions(QueryDocumentSnapshot note) async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editNote(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNote(note.id);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _editNote(QueryDocumentSnapshot note) async {
    final titleController = TextEditingController(text: note['title']);
    final contentController = TextEditingController(text: note['content']);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25.0),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Edit Note',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: _inputDecoration('Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contentController,
                      decoration: _inputDecoration('Content'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('notes')
                            .doc(note.id)
                            .update({
                              'title': titleController.text,
                              'content': contentController.text,
                            });
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
