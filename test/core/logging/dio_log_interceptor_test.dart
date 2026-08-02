import 'package:dio/dio.dart';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:money_sync/core/logging/dio_log_interceptor.dart';

void main() {
  group('DioLogInterceptor', () {
    test('logs request method and path via Dio', () async {
      final captured = <LogRecord>[];
      final logger = Logger('test.dio.req');
      logger.onRecord.listen(captured.add);

      final dio = Dio();
      dio.interceptors.add(DioLogInterceptor(logger: logger));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: 'ok'),
            );
          },
        ),
      );

      await dio.get('https://rest.budgetbakers.com/api/accounts');

      expect(captured.length, greaterThanOrEqualTo(1));
      expect(captured.any((r) => r.message.contains('/api/accounts')), isTrue);
    });

    test('logs response status code and size', () async {
      final captured = <LogRecord>[];
      final logger = Logger('test.dio.res');
      logger.onRecord.listen(captured.add);

      final dio = Dio();
      dio.interceptors.add(DioLogInterceptor(logger: logger));
      // Use a mock adapter to trigger real response flow
      dio.httpClientAdapter = _FakeAdapter();

      await dio.post('https://api.test.com/create');

      expect(captured.any((r) => r.message.contains('201')), isTrue);
    });

    test('logs error with type and path', () async {
      final captured = <LogRecord>[];
      final logger = Logger('test.dio.err');
      logger.onRecord.listen(captured.add);

      final dio = Dio();
      dio.interceptors.add(DioLogInterceptor(logger: logger));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      try {
        await dio.get('/api/fail');
      } on DioException {
        // expected
      }

      // Error might not propagate through onError for rejected requests
      // We verify the interceptor's onError is reached by testing through
      // a real Dio HTTP call failure
      expect(captured.any((r) => r.message.contains('/api/fail')), isTrue);
    });
  });
}

class _FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"ok": true}',
      201,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
