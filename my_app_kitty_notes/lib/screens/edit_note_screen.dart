import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class EditNoteScreen extends StatefulWidget {
  final Note? note;
  final NotesService notesService;

  const EditNoteScreen({
    super.key,
    this.note,
    required this.notesService,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (!NotesService.validateNote(title, content)) {
      _showValidationError();
      return;
    }

    try {
      if (_isEditing) {
        final updatedNote = widget.note!.copyWith(
          title: title,
          content: content,
        );
        await widget.notesService.updateNote(widget.note!.id, updatedNote);
      } else {
        final newNote = Note.create(title: title, content: content);
        await widget.notesService.addNote(newNote);
      }

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Ошибка сохранения: $e');
    }
  }

  void _showValidationError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка валидации'),
        content: const Text('Заголовок и текст заметки не могут быть пустыми.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Редактирование' : 'Новая заметка'),
        actions: [
          IconButton(
            onPressed: _saveNote,
            icon: const Icon(Icons.check, color: Colors.green),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Заголовок заметки',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Текст заметки...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}