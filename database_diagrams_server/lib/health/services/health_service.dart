import 'package:database_diagrams_common/logger/logger.dart';
import 'package:database_diagrams_server/health/models/health_check_result.dart';
import 'package:database_diagrams_server/postgres/implementations/postgres_service.dart';
import 'package:postgres/postgres.dart';

class HealthService {
  const HealthService({required this.postgresService});

  final PostgresService postgresService;

  Future<Map<String, dynamic>> checkHealth() async {
    final HealthCheckResult healthCheck = await _checkDatabase();

    return {
      'status': healthCheck.status,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'database': healthCheck.toJson(),
    };
  }

  Future<HealthCheckResult> _checkDatabase() async {
    final stopwatch = Stopwatch()..start();
    try {
      await postgresService.execute(Sql.named('SELECT 1;'));
      stopwatch.stop();

      return HealthCheckResult(
        status: 'UP',
        latency: '${stopwatch.elapsedMilliseconds}ms',
      );
    } on Exception catch (e) {
      LOG.e('Database health check failed: $e');
      stopwatch.stop();
      return HealthCheckResult(
        status: 'DOWN',
        latency: '${stopwatch.elapsedMilliseconds}ms',
      );
    }
  }
}
