import '../models/note.dart';

class NotesService {
  final List<Note> _notes = [
    Note.create(
      title: 'Идеи для кода',
      content: 'Оптимизировать алгоритм сортировки данных и добавить кэширование часто используемых запросов.',
    ),
    Note.create(
      title: 'Исправление багов',
      content: 'Починить crash в модуле авторизации, возникающий при нестабильном интернет-соединении.',
    ),
    Note.create(
      title: 'Изучение Flutter',
      content: 'Изучить Bloc паттерн для управления состоянием приложения и внедрить в текущий проект.',
    ),
    Note.create(
      title: 'План на неделю',
      content: '1. Завершить ЛР5\n2. Начать ЛР6\n3. Подготовить документацию\n4. Протестировать приложение',
    ),
    Note.create(
      title: 'Покупки',
      content: '- Молоко\n- Хлеб\n- Фрукты\n- Крупы\n- Кофе',
    ),
  ];

  // Получить все заметки (отсортированные по дате обновления)
  List<Note> getAllNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.from(_notes);
  }

  // Добавить новую заметку
  void addNote(Note note) {
    _notes.add(note);
  }

  // Обновить существующую заметку
  void updateNote(String id, Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = updatedNote;
    }
  }

  // Удалить заметку
  void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
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
}