import 'dart:math';

class CatsService {
  static const String _baseUrl = 'https://cataas.com';
  
  // Список запасных прямых ссылок на котиков
  final List<String> _fallbackUrls = [
    '$_baseUrl/cat',
    '$_baseUrl/cat/gif',
    '$_baseUrl/cat/says/Hello!',
    '$_baseUrl/cat/says/Meow!',
    '$_baseUrl/cat/says/Flutter!',
    '$_baseUrl/cat/says/Notes!',
  ];

  // Получить случайную картинку кота
  Future<String?> getRandomCatImage() async {
    try {
      final random = Random();
      // Используем запасные ссылки с добавлением timestamp для избежания кэширования
      final url = _fallbackUrls[random.nextInt(_fallbackUrls.length)];
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Ошибка получения картинки кота: $e');
      return null;
    }
  }
}