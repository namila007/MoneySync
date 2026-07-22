import 'package:flutter_test/flutter_test.dart';
import 'package:money_sync/core/errors/domain_failure.dart';

void main() {
  test(
    'typed failures expose safe codes and no sensitive diagnostic value',
    () {
      const failure = InvalidStateTransitionFailure(
        from: 'queued',
        to: 'succeeded',
      );

      expect(failure.code, DomainFailureCode.illegalStateTransition);
      expect(
        failure.safeMessage,
        'The requested operation is not allowed now.',
      );
      expect(failure.toString(), contains('illegalStateTransition'));
      expect(failure.toString(), isNot(contains('secret')));
    },
  );
}
