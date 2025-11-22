import 'package:flutter/material.dart';
import 'edit_note_screen.dart';
import 'cats_screen.dart';
import '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Note> _notes = [
    Note.demo(
      title: 'Идеи для кода',
      content: 'Оптимизировать алгоритм сортировки данных...',
    ),
    Note.demo(
      title: 'Исправление багов',
      content: 'Починить crash в модуле авторизации...',
    ),
    Note.demo(
      title: 'Изучение Flutter',
      content: 'Изучить Bloc паттерн для управления состоянием...',
    ),
  ];

  List<Note> get _filteredNotes {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return _notes;
    }
    return _notes.where((note) {
      return note.title.toLowerCase().contains(searchText) ||
          note.content.toLowerCase().contains(searchText);
    }).toList();
  }

  void _navigateToEditNote([Note? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );
  }

  void _navigateToCatsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CatsScreen()),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заметка удалена')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Column(
        children: [
          // Поиск и кнопка котиков
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '🔎 Поиск...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _navigateToCatsScreen,
                  icon: const Icon(Icons.pets, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          
          // Кнопка новой заметки
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEditNote(),
                icon: const Icon(Icons.add),
                label: const Text('Новая заметка'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Список заметок
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return _buildNoteCard(note, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          note.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            note.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        onTap: () => _navigateToEditNote(note),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteNote(_notes.indexOf(note)),
        ),
      ),
    );
  }
}