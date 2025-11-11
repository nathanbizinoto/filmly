import 'package:flutter/material.dart';
import '../services/ab_test_service.dart';
import '../theme/app_theme.dart';

class ABTestScreen extends StatefulWidget {
  const ABTestScreen({super.key});

  @override
  State<ABTestScreen> createState() => _ABTestScreenState();
}

class _ABTestScreenState extends State<ABTestScreen> {
  final ABTestService _abTestService = ABTestService();
  Map<String, dynamic> _allStats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllStats();
  }

  Future<void> _loadAllStats() async {
    setState(() => _loading = true);

    final stats = <String, dynamic>{};
    for (final testName in _abTestService.availableTests.keys) {
      stats[testName] = await _abTestService.getTestStats(testName);
    }

    setState(() {
      _allStats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Testes A/B',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllStats,
            tooltip: 'Atualizar estatísticas',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho explicativo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.science,
                              color: AppTheme.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sistema de Testes A/B',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Os testes A/B permitem comparar diferentes versões de funcionalidades para otimizar a experiência do usuário.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Lista de testes
                  ...(_abTestService.availableTests.entries.map((entry) {
                    final testName = entry.key;
                    final config = entry.value;
                    final stats = _allStats[testName] ?? {};

                    return _buildTestCard(testName, config, stats);
                  }).toList()),

                  const SizedBox(height: 24),

                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _simulateConversions,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Simular Dados'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetAllTests,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Resetar Tudo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTestCard(String testName, ABTestService.ABTestConfig config,
      Map<String, dynamic> stats) {
    final groupAStats = stats['groupA'] as Map<String, int>? ?? {};
    final groupBStats = stats['groupB'] as Map<String, int>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: config.isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                testName.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              '${(config.splitPercentage * 100).toInt()}/${(100 - config.splitPercentage * 100).toInt()}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Text(
          config.description,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estatísticas dos grupos
                Row(
                  children: [
                    Expanded(
                      child: _buildGroupStats(
                          'Grupo A', groupAStats, AppTheme.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGroupStats(
                          'Grupo B', groupBStats, AppTheme.primaryPurple),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botões de ação para o teste
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _forceGroup(testName, ABTestService.TestGroup.A),
                        icon: const Icon(Icons.looks_one, size: 16),
                        label: const Text('Forçar A'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _forceGroup(testName, ABTestService.TestGroup.B),
                        icon: const Icon(Icons.looks_two, size: 16),
                        label: const Text('Forçar B'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          side: const BorderSide(color: AppTheme.primaryPurple),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _resetTest(testName),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupStats(
      String groupName, Map<String, int> stats, Color color) {
    final totalEvents = stats.values.fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total: $totalEvents eventos',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...stats.entries.map((entry) => Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Future<void> _forceGroup(
      String testName, ABTestService.TestGroup group) async {
    await _abTestService.forceTestGroup(testName, group);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Forçado para grupo ${group.name} no teste $testName'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  Future<void> _resetTest(String testName) async {
    await _abTestService.resetTest(testName);
    await _loadAllStats();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Teste $testName resetado'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _resetAllTests() async {
    for (final testName in _abTestService.availableTests.keys) {
      await _abTestService.resetTest(testName);
    }
    await _loadAllStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Todos os testes foram resetados'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _simulateConversions() async {
    // Simula alguns dados para demonstração
    final tests = ['movie_card_design', 'profile_layout'];
    final events = ['click', 'favorite', 'share', 'view'];

    for (final test in tests) {
      for (final event in events) {
        // Simula conversões para grupo A
        for (int i = 0; i < (10 + (i * 3)); i++) {
          await _abTestService.trackConversion(test, event);
        }
      }
    }

    await _loadAllStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados simulados gerados com sucesso!'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }
}
