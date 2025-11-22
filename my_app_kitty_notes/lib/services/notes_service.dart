import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesService {
  static const String _notesKey = 'notes';
  List<Note> _notes = [];

  NotesService() {
    _loadNotes();
  }

  // Загрузить заметки из SharedPreferences
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      
      if (notesJson != null && notesJson.isNotEmpty) {
        final List<dynamic> notesList = _parseNotesJson(notesJson);
        _notes = notesList.map((noteMap) => Note.fromMap(noteMap)).toList();
      } else {
        // Пустой список при первом запуске (без демо-данных)
        _notes = [];
        await _saveNotes();
      }
    } catch (e) {
      print('Ошибка загрузки заметок: $e');
      _notes = [];
    }
  }

  // Сохранить заметки в SharedPreferences
  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = _notes.map((note) => note.toMap()).toList();
      await prefs.setString(_notesKey, notesJson.toString());
    } catch (e) {
      print('Ошибка сохранения заметок: $e');
    }
  }

  // Парсинг JSON строки
  List<dynamic> _parseNotesJson(String jsonString) {
    try {
      // Упрощенный парсинг для демонстрации
      final cleanedString = jsonString.replaceAll(RegExp(r'^\[|\]$'), '');
      final noteStrings = cleanedString.split('}, {');
      
      return noteStrings.map((noteString) {
        final fullString = noteString.startsWith('{') ? noteString : '{$noteString}';
        final fullString2 = fullString.endsWith('}') ? fullString : '$fullString}';
        
        final Map<String, dynamic> map = {};
        final pairs = fullString2.replaceAll(RegExp(r'[{}]'), '').split(', ');
        
        for (final pair in pairs) {
          final keyValue = pair.split(': ');
          if (keyValue.length == 2) {
            final key = keyValue[0].replaceAll("'", '');
            var value = keyValue[1].replaceAll("'", '');
            
            // Обработка числовых значений
            if (key == 'createdAt' || key == 'updatedAt') {
              map[key] = int.tryParse(value) ?? 0;
            } else {
              map[key] = value;
            }
          }
        }
        return map;
      }).toList();
    } catch (e) {
      print('Ошибка парсинга JSON: $e');
      return [];
    }
  }

  // Получить все заметки (отсортированные по дате обновления)
  List<Note> getAllNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.from(_notes);
  }

  // Добавить новую заметку
  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveNotes();
  }

  // Обновить существующую заметку
  Future<void> updateNote(String id, Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = updatedNote;
      await _saveNotes();
    }
  }

  // Удалить заметку
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
  }

  // Поиск по заметкам
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return getAllNotes();
    
    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery);
    }).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // Получить заметку по ID
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Валидация заметки
  static bool validateNote(String title, String content) {
    return title.trim().isNotEmpty && content.trim().isNotEmpty;
  }

  // Очистить все заметки (для тестирования)
  Future<void> clearAllNotes() async {
    _notes.clear();
    await _saveNotes();
  }
}