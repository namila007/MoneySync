import 'package:dio/dio.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_connection_models.dart';
import 'package:money_sync/features/wallet_connection/domain/wallet_token.dart';

final class WalletApiDataSource {
  WalletApiDataSource({required Dio dio}) : _dio = dio;

  static const _baseUrl = 'https://rest.budgetbakers.com/wallet';
  static const _accountsPath = '/v1/api/accounts';
  static const _categoriesPath = '/v1/api/categories';
  static const _pageSize = 100;
  static const _maxPages = 20;

  final Dio _dio;

  Future<WalletReadFailure?> testConnection(WalletToken token) async {
    try {
      final response = await _dio.get<Object?>(
        '$_baseUrl$_accountsPath',
        queryParameters: {'limit': 1},
        options: Options(
          headers: {'Authorization': 'Bearer ${token.toPersistenceString()}'},
          validateStatus: (status) => true,
          followRedirects: false,
        ),
      );
      return switch (response.statusCode) {
        200 => null,
        401 || 403 => const WalletReadFailure.invalidToken(),
        409 => const WalletReadFailure.initialSyncInProgress(),
        429 => WalletReadFailure.rateLimited(
          retryAfterSeconds: int.tryParse(
            response.headers.value('retry-after') ?? '',
          ),
        ),
        int s when s >= 500 => const WalletReadFailure.service(),
        _ => const WalletReadFailure.protocol(),
      };
    } on DioException catch (e) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => const WalletReadFailure.timeout(),
        DioExceptionType.badCertificate => const WalletReadFailure.tls(),
        DioExceptionType.connectionError => const WalletReadFailure.offline(),
        _ => const WalletReadFailure.service(),
      };
    }
  }

  Future<WalletReadResult> fetchCatalog(WalletToken token) async {
    final accounts = await _fetchAccounts(token);
    if (accounts is WalletReadFailure) return accounts;
    final categories = await _fetchCategories(token);
    if (categories is WalletReadFailure) return categories;
    return WalletReadSuccess(
      WalletCatalog(
        accounts: accounts as List<WalletAccount>,
        categories: categories as List<WalletCategory>,
      ),
    );
  }

  Future<Object> _fetchAccounts(WalletToken token) async {
    final all = <WalletAccount>[];
    var offset = 0;
    for (var page = 0; page < _maxPages; page++) {
      try {
        final response = await _dio.get<Object?>(
          '$_baseUrl$_accountsPath',
          queryParameters: {'limit': _pageSize, 'offset': offset},
          options: Options(
            headers: {'Authorization': 'Bearer ${token.toPersistenceString()}'},
            validateStatus: (s) => true,
            followRedirects: false,
          ),
        );
        if (response.statusCode != 200) {
          return _mapFailure(response.statusCode, response.headers.value('retry-after'));
        }
        final data = response.data;
        if (data is! Map || data['accounts'] is! List) {
          return const WalletReadFailure.protocol();
        }
        for (final item in data['accounts'] as List) {
          if (item is! Map) return const WalletReadFailure.protocol();
          final id = item['id'] as String?;
          final name = item['name'] as String?;
          if (id == null || name == null) return const WalletReadFailure.protocol();
          all.add(WalletAccount(
            id: id,
            name: name,
            currencyCode: (item['balance'] is Map ? (item['balance'] as Map)['currencyCode'] as String? : null) ?? '',
            isArchived: item['archived'] == true,
            isBankSynced: item['isBankSync'] == true,
            isWritable: item['isWritable'] == true,
          ));
        }
        final nextOffset = data['nextOffset'];
        if (nextOffset is! int) break;
        offset = nextOffset;
      } on DioException {
        return const WalletReadFailure.service();
      }
    }
    return all;
  }

  Future<Object> _fetchCategories(WalletToken token) async {
    final all = <WalletCategory>[];
    var offset = 0;
    for (var page = 0; page < _maxPages; page++) {
      try {
        final response = await _dio.get<Object?>(
          '$_baseUrl$_categoriesPath',
          queryParameters: {'limit': _pageSize, 'offset': offset},
          options: Options(
            headers: {'Authorization': 'Bearer ${token.toPersistenceString()}'},
            validateStatus: (s) => true,
            followRedirects: false,
          ),
        );
        if (response.statusCode != 200) {
          return _mapFailure(response.statusCode, response.headers.value('retry-after'));
        }
        final data = response.data;
        if (data is! Map || data['categories'] is! List) {
          return const WalletReadFailure.protocol();
        }
        for (final item in data['categories'] as List) {
          if (item is! Map) return const WalletReadFailure.protocol();
          final id = item['id'] as String?;
          final name = item['name'] as String?;
          if (id == null || name == null) return const WalletReadFailure.protocol();
          all.add(WalletCategory(id: id, name: name));
        }
        final nextOffset = data['nextOffset'];
        if (nextOffset is! int) break;
        offset = nextOffset;
      } on DioException {
        return const WalletReadFailure.service();
      }
    }
    return all;
  }

  WalletReadFailure _mapFailure(int? statusCode, String? retryAfter) => switch (statusCode) {
    401 || 403 => const WalletReadFailure.invalidToken(),
    409 => const WalletReadFailure.initialSyncInProgress(),
    429 => WalletReadFailure.rateLimited(retryAfterSeconds: int.tryParse(retryAfter ?? '')),
    int s when s >= 500 => const WalletReadFailure.service(),
    _ => const WalletReadFailure.protocol(),
  };
}
