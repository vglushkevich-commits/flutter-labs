import 'package:flutter/material.dart';
import '../services/cats_service.dart';

class CatsScreen extends StatefulWidget {
  const CatsScreen({super.key});

  @override
  State<CatsScreen> createState() => _CatsScreenState();
}

class _CatsScreenState extends State<CatsScreen> {
  final CatsService _catsService = CatsService();
  String? _catImageUrl;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRandomCat();
  }

  Future<void> _loadRandomCat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _catImageUrl = null;
    });

    try {
      final imageUrl = await _catsService.getRandomCatImage();
      
      if (imageUrl != null) {
        setState(() {
          _catImageUrl = imageUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Не удалось получить ссылку на котика';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при загрузке: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Случайные котики'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadRandomCat,
            icon: const Icon(Icons.refresh),
            tooltip: 'Новый котик',
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.pets, size: 24),
                SizedBox(width: 8),
                Text(
                  'Случайные котики',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: _isLoading
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Ищем нового котика...'),
                      ],
                    )
                  : _errorMessage.isNotEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRandomCat,
                              child: const Text('Попробовать снова'),
                            ),
                          ],
                        )
                      : _catImageUrl != null
                          ? SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _catImageUrl!,
                                        fit: BoxFit.contain,
                                        width: 300,
                                        height: 300,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 300,
                                            height: 300,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildErrorState('Не удалось загрузить изображение');
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadRandomCat,
                                    child: const Text('Еще котик!'),
                                  ),
                                ],
                              ),
                            )
                          : _buildErrorState('Котик куда-то пропал...'),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: const Column(
              children: [
                Text(
                  'Реальные котики из Cataas API! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Нажимайте "Еще котик!" для новых изображений',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.pets, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadRandomCat,
          child: const Text('Попробовать снова'),
        ),
      ],
    );
  }
}