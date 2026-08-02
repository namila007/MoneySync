import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

/// Read-only Wallet metadata transport pinned to the verified public OpenAPI
/// v1.3.0 host and response shape. It intentionally has no mutation API.
final class WalletCatalogReader {
  WalletCatalogReader._(this._dio);

  static const _baseUrl = 'https://rest.budgetbakers.com/wallet';
  static const _host = 'rest.budgetbakers.com';
  static const _accountsPath = '/v1/api/accounts';
  static const _categoriesPath = '/v1/api/categories';
  static const _pageSize = 100;
  static const _maximumPages = 20;
  static const _maximumResponseCharacters = 1024 * 1024;
  static const _maximumItemsPerPage = 100;
  static const _maximumTextLength = 512;

  final Dio _dio;

  /// Production-capable reader using real platform I/O adapter.
  /// Uses the same audited Dio configuration with the platform's native
  /// HTTP client. The guard interceptor enforces GET-only, HTTPS-only,
  /// host-pinned, path-allowlisted transport.
  factory WalletCatalogReader.production() {
    final dio = _createAuditedDio();
    return WalletCatalogReader._(dio);
  }

  /// Contract-test construction using a synthetic [adapter].
  factory WalletCatalogReader.forTesting({required HttpClientAdapter adapter}) {
    final dio = _createAuditedDio();
    dio.httpClientAdapter = adapter;
    return WalletCatalogReader._(dio);
  }

  static Dio _createAuditedDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.plain,
        followRedirects: false,
        maxRedirects: 0,
        validateStatus: (_) => true,
      ),
    );
    dio.interceptors.add(_WalletRequestGuard());
    return dio;
  }

  Future<WalletReadResult> readCatalog(WalletToken token) async {
    final accounts = await _readPages<WalletAccount>(
      path: _accountsPath,
      collectionKey: 'accounts',
      token: token,
      decode: _decodeAccount,
    );
    if (accounts case WalletReadFailure()) return accounts;
    final categories = await _readPages<WalletCategory>(
      path: _categoriesPath,
      collectionKey: 'categories',
      token: token,
      decode: _decodeCategory,
    );
    if (categories case WalletReadFailure()) return categories;
    return WalletReadSuccess(
      WalletCatalog(
        accounts: accounts as List<WalletAccount>,
        categories: categories as List<WalletCategory>,
      ),
    );
  }

  Future<Object> _readPages<T>({
    required String path,
    required String collectionKey,
    required WalletToken token,
    required T? Function(Object? value) decode,
  }) async {
    final values = <T>[];
    final seenOffsets = <int>{};
    int? offset;
    for (var page = 0; page < _maximumPages; page++) {
      final responseOrFailure = await _get(path, token, offset);
      if (responseOrFailure case _FailureResponse(:final failure)) {
        return failure;
      }
      final parsed = _asMap(
        (responseOrFailure as _SuccessResponse).response.data,
      );
      final items = parsed?[collectionKey];
      if (parsed == null ||
          items is! List ||
          items.length > _maximumItemsPerPage) {
        return const WalletReadFailure.protocol();
      }
      for (final item in items) {
        final value = decode(item);
        if (value == null) return const WalletReadFailure.protocol();
        values.add(value);
      }
      final nextOffset = parsed['nextOffset'];
      if (nextOffset == null) return values;
      if (nextOffset is! int ||
          nextOffset < 0 ||
          !seenOffsets.add(nextOffset)) {
        return const WalletReadFailure.protocol();
      }
      offset = nextOffset;
    }
    return const WalletReadFailure.protocol();
  }

  Future<_ResponseOrFailure> _get(
    String path,
    WalletToken token,
    int? offset,
  ) async {
    try {
      final query = <String, Object?>{'limit': _pageSize};
      if (offset != null) query['offset'] = offset;
      final response = await _dio.get<Object?>(
        path,
        queryParameters: query,
        options: Options(extra: {_WalletRequestGuard.authorizationKey: token}),
      );
      return switch (response.statusCode) {
        200 => _SuccessResponse(response),
        401 || 403 => const _FailureResponse(WalletReadFailure.invalidToken()),
        409 when _errorCode(response.data) == 'init_sync_in_progress' =>
          const _FailureResponse(WalletReadFailure.initialSyncInProgress()),
        429 => _FailureResponse(
          WalletReadFailure.rateLimited(
            retryAfterSeconds: int.tryParse(
              response.headers.value('retry-after') ?? '',
            ),
          ),
        ),
        int status when status >= 500 => const _FailureResponse(
          WalletReadFailure.service(),
        ),
        _ => const _FailureResponse(WalletReadFailure.protocol()),
      };
    } on DioException catch (exception) {
      return _FailureResponse(_mapException(exception));
    } catch (_) {
      return const _FailureResponse(WalletReadFailure.protocol());
    }
  }

  static WalletReadFailure _mapException(DioException exception) =>
      switch (exception.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout => const WalletReadFailure.timeout(),
        DioExceptionType.badCertificate => const WalletReadFailure.tls(),
        DioExceptionType.connectionError => const WalletReadFailure.offline(),
        DioExceptionType.badResponse ||
        DioExceptionType.cancel ||
        DioExceptionType.unknown => const WalletReadFailure.protocol(),
      };

  static Map<String, Object?>? _asMap(Object? data) {
    try {
      final value = switch (data) {
        String text when text.length <= _maximumResponseCharacters =>
          jsonDecode(text),
        String() => null,
        _ => data,
      };
      if (value is! Map) return null;
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    } on Object {
      return null;
    }
  }

  static String? _errorCode(Object? data) {
    final error = _asMap(data)?['error'];
    return error is String && error.length <= _maximumTextLength ? error : null;
  }

  static WalletAccount? _decodeAccount(Object? value) {
    final map = _asMap(value);
    if (map == null) return null;
    final id = _boundedText(map['id']);
    final name = _boundedText(map['name']);
    final accountType = _boundedText(map['accountType']);
    final archived = map['archived'];
    final bankSynced = map['isBankSync'];
    final initialBalance = _asMap(map['initialBalance']);
    final balance = _asMap(map['balance']);
    final currency =
        _boundedText(initialBalance?['currencyCode']) ??
        _boundedText(balance?['currencyCode']);
    if (id == null ||
        name == null ||
        accountType == null ||
        archived is! bool ||
        bankSynced is! bool) {
      return null;
    }
    return WalletAccount(
      id: id,
      name: name,
      currencyCode: currency ?? '',
      isArchived: archived,
      isBankSynced: bankSynced,
      // OpenAPI v1.3.0 does not provide a writable flag. Stay fail-closed until
      // the separate write-contract spike supplies verified capability evidence.
      isWritable: false,
    );
  }

  static WalletCategory? _decodeCategory(Object? value) {
    final map = _asMap(value);
    final id = _boundedText(map?['id']);
    final name = _boundedText(map?['name']);
    if (id == null || name == null) return null;
    return WalletCategory(id: id, name: name);
  }

  static String? _boundedText(Object? value) =>
      value is String && value.isNotEmpty && value.length <= _maximumTextLength
      ? value
      : null;
}

final class _WalletRequestGuard extends Interceptor {
  static const authorizationKey = 'walletAuthorization';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    final isAllowedPath =
        uri.path == '/wallet/v1/api/accounts' ||
        uri.path == '/wallet/v1/api/categories';
    final token = options.extra.remove(authorizationKey);
    if (options.method != 'GET' ||
        uri.scheme != 'https' ||
        uri.host != WalletCatalogReader._host ||
        !isAllowedPath ||
        options.followRedirects ||
        options.maxRedirects != 0 ||
        token is! WalletToken) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }
    token.attachBearerToAuditedRequest(options.headers);
    handler.next(options);
  }
}

sealed class _ResponseOrFailure {
  const _ResponseOrFailure();
}

final class _SuccessResponse extends _ResponseOrFailure {
  const _SuccessResponse(this.response);
  final Response<Object?> response;
}

final class _FailureResponse extends _ResponseOrFailure {
  const _FailureResponse(this.failure);
  final WalletReadFailure failure;
}
