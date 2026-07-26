enum DataClearScope { clearActivity, resetAllLocalData }

final class ClearActivityResult {
  const ClearActivityResult({required this.success, this.errorMessage});
  final bool success;
  final String? errorMessage;
}
