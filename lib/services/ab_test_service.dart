import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Serviço para gerenciar testes A/B no aplicativo
/// Permite testar diferentes versões de funcionalidades com usuários
class ABTestService {
  static final ABTestService _instance = ABTestService._internal();
  factory ABTestService() => _instance;
  ABTestService._internal();

  static const String _abTestPrefix = 'ab_test_';
  final Random _random = Random();

  /// Enum para definir os grupos de teste
  enum TestGroup { A, B }

  /// Configuração de um teste A/B
  class ABTestConfig {
    final String testName;
    final String description;
    final double splitPercentage; // Porcentagem para grupo A (0.0 a 1.0)
    final bool isActive;

    ABTestConfig({
      required this.testName,
      required this.description,
      this.splitPercentage = 0.5, // 50/50 por padrão
      this.isActive = true,
    });
  }

  /// Testes A/B disponíveis no app
  static final Map<String, ABTestConfig> _availableTests = {
    'movie_card_design': ABTestConfig(
      testName: 'movie_card_design',
      description: 'Teste do design dos cards de filme',
      splitPercentage: 0.5,
      isActive: true,
    ),
    'profile_layout': ABTestConfig(
      testName: 'profile_layout',
      description: 'Teste do layout da tela de perfil',
      splitPercentage: 0.6, // 60% grupo A, 40% grupo B
      isActive: true,
    ),
    'home_screen_sections': ABTestConfig(
      testName: 'home_screen_sections',
      description: 'Teste da ordem das seções na tela inicial',
      splitPercentage: 0.5,
      isActive: false, // Desativado por enquanto
    ),
  };

  /// Obtém o grupo de teste para um usuário específico
  Future<TestGroup> getTestGroup(String testName, {String? userId}) async {
    final config = _availableTests[testName];
    if (config == null || !config.isActive) {
      return TestGroup.A; // Padrão se teste não existir ou estiver inativo
    }

    final prefs = await SharedPreferences.getInstance();
    final key = '$_abTestPrefix$testName${userId != null ? '_$userId' : ''}';
    
    // Verifica se já existe um grupo salvo para este teste
    final savedGroup = prefs.getString(key);
    if (savedGroup != null) {
      return savedGroup == 'A' ? TestGroup.A : TestGroup.B;
    }

    // Atribui um grupo baseado na porcentagem configurada
    final randomValue = _random.nextDouble();
    final group = randomValue < config.splitPercentage ? TestGroup.A : TestGroup.B;
    
    // Salva o grupo para consistência
    await prefs.setString(key, group.name);
    
    // Log para debug
    print('🧪 Teste A/B [$testName]: Usuário atribuído ao grupo ${group.name}');
    
    return group;
  }

  /// Registra um evento de conversão para análise
  Future<void> trackConversion(String testName, String eventName, {String? userId}) async {
    final group = await getTestGroup(testName, userId: userId);
    final prefs = await SharedPreferences.getInstance();
    
    final key = '${_abTestPrefix}conversion_${testName}_${group.name}_$eventName';
    final currentCount = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentCount + 1);
    
    print('📊 Conversão registrada: $testName - Grupo ${group.name} - Evento: $eventName');
  }

  /// Obtém estatísticas de um teste A/B
  Future<Map<String, dynamic>> getTestStats(String testName) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('${_abTestPrefix}conversion_$testName'));
    
    final stats = <String, Map<String, int>>{
      'A': {},
      'B': {},
    };

    for (final key in keys) {
      final parts = key.split('_');
      if (parts.length >= 5) {
        final group = parts[3];
        final event = parts.sublist(4).join('_');
        final count = prefs.getInt(key) ?? 0;
        
        stats[group]![event] = count;
      }
    }

    return {
      'testName': testName,
      'groupA': stats['A'],
      'groupB': stats['B'],
      'config': _availableTests[testName]?.description ?? 'Teste não encontrado',
    };
  }

  /// Lista todos os testes disponíveis
  Map<String, ABTestConfig> get availableTests => Map.unmodifiable(_availableTests);

  /// Reseta um teste específico (remove dados salvos)
  Future<void> resetTest(String testName) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.contains(testName));
    
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    print('🔄 Teste A/B [$testName] resetado');
  }

  /// Força um usuário para um grupo específico (útil para debug)
  Future<void> forceTestGroup(String testName, TestGroup group, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_abTestPrefix$testName${userId != null ? '_$userId' : ''}';
    await prefs.setString(key, group.name);
    
    print('🎯 Usuário forçado para grupo ${group.name} no teste [$testName]');
  }
}
