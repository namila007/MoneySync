import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/log_levels.dart';

final class DioLogInterceptor extends Interceptor {
  DioLogInterceptor({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    final path = '${uri.scheme}://${uri.host}${uri.path}';
    _logger.info('Request: $path [${options.method}]');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final size = response.data?.toString().length ?? 0;
    _logger.info('Response: ${response.statusCode} (${size}b)');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.uri.path;
    _logger.error('Dio error: ${err.type} on $path (${err.response?.statusCode})');
    handler.next(err);
  }
}
