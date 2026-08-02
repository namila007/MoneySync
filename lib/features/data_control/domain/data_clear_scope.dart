enum DataClearScope { clearActivity, resetAllLocalData }

final class ClearActivityResult {
  const ClearActivityResult({
    required this.success,
    this.errorMessage,
    this.epochAdvanced,
    this.rowsDeleted,
  });
  final bool success;
  final String? errorMessage;
  final bool? epochAdvanced;
  final int? rowsDeleted;
}

final class ResetAllDataResult {
  const ResetAllDataResult({
    required this.success,
    this.errorMessage,
    this.epochAdvanced,
    this.keysDeleted,
    this.databaseRemoved,
  });
  final bool success;
  final String? errorMessage;
  final bool? epochAdvanced;
  final bool? keysDeleted;
  final bool? databaseRemoved;

  int get succeededSteps {
    var count = 0;
    if (epochAdvanced == true) count++;
    if (keysDeleted == true) count++;
    if (databaseRemoved == true) count++;
    return count;
  }

  int get failedSteps {
    var count = 0;
    if (epochAdvanced == false) count++;
    if (keysDeleted == false) count++;
    if (databaseRemoved == false) count++;
    return count;
  }

  List<String> get stepDetails {
    final details = <String>[];
    if (epochAdvanced == true) {
      details.add('Privacy epoch advanced');
    } else if (epochAdvanced == false) {
      details.add('Privacy epoch advance failed');
    }
    if (keysDeleted == true) {
      details.add('Security keys deleted');
    } else if (keysDeleted == false) {
      details.add('Security key deletion failed');
    }
    if (databaseRemoved == true) {
      details.add('Database and logs removed');
    } else if (databaseRemoved == false) {
      details.add('Database removal failed');
    }
    return details;
  }
}
