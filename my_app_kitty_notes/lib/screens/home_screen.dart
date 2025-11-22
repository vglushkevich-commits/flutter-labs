import 'package:flutter/material.dart';
import 'edit_note_screen.dart';
import 'cats_screen.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NotesService _notesService = NotesService();
  late List<Note> _displayedNotes;

  @override
  void initState() {
    super.initState();
    _displayedNotes = _notesService.getAllNotes();
  }

  void _refreshNotes() {
    setState(() {
      _displayedNotes = _notesService.searchNotes(_searchController.text);
    });
  }

  void _navigateToEditNote([Note? note]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          note: note,
          notesService: _notesService,
        ),
      ),
    );

    if (result == true) {
      _refreshNotes();
      _showSnackBar(note == null ? 'Заметка создана' : 'Заметка обновлена');
    }
  }

  void _navigateToCatsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CatsScreen()),
    );
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: Text('Заметка "${note.title}" будет удалена безвозвратно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _notesService.deleteNote(note.id);
              _refreshNotes();
              Navigator.pop(context);
              _showSnackBar('Заметка удалена');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _refreshNotes();
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
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onChanged: (value) => _refreshNotes(),
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
                  tooltip: 'Случайные котики',
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
          
          // Список заметок или пустое состояние
          Expanded(
            child: _displayedNotes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _displayedNotes.length,
                    itemBuilder: (context, index) {
                      final note = _displayedNotes[index];
                      return _buildNoteCard(note);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
          onPressed: () => _deleteNote(note),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isEmpty ? Icons.note_add : Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty 
                ? 'Нет заметок\nСоздайте первую заметку!'
                : 'Ничего не найдено\nПопробуйте изменить запрос',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Очистить поиск'),
            ),
          ],
        ],
      ),
    );
  }
}