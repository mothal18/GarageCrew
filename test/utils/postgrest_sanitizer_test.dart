import 'package:flutter_test/flutter_test.dart';
import 'package:garage_crew/utils/postgrest_sanitizer.dart';

void main() {
  group('PostgrestSanitizer.sanitize', () {
    test('passes through normal text', () {
      expect(PostgrestSanitizer.sanitize('hello world'), 'hello world');
    });

    test('passes through alphanumeric input', () {
      expect(PostgrestSanitizer.sanitize('user123'), 'user123');
    });

    test('strips commas', () {
      expect(PostgrestSanitizer.sanitize('a,b,c'), 'abc');
    });

    test('strips dots', () {
      expect(PostgrestSanitizer.sanitize('login.ilike.admin'), 'loginilikeadmin');
    });

    test('strips parentheses', () {
      expect(PostgrestSanitizer.sanitize('test(value)'), 'testvalue');
    });

    test('strips backslashes', () {
      expect(PostgrestSanitizer.sanitize(r'test\value'), 'testvalue');
    });

    test('handles injection attempt with filter manipulation', () {
      // This input would try to add an extra filter condition
      final result = PostgrestSanitizer.sanitize('user,id.eq.admin');
      expect(result, 'userideqadmin');
      expect(result.contains(','), isFalse);
      expect(result.contains('.'), isFalse);
    });

    test('preserves spaces and hyphens', () {
      expect(PostgrestSanitizer.sanitize('my garage-name'), 'my garage-name');
    });

    test('preserves unicode characters', () {
      expect(PostgrestSanitizer.sanitize('Garaż Mothal'), 'Garaż Mothal');
    });

    test('handles empty string', () {
      expect(PostgrestSanitizer.sanitize(''), '');
    });

    test('strips percent signs used in like patterns', () {
      // % is allowed in ilike patterns but not dangerous in PostgREST filter syntax
      // Our sanitizer does not strip % because it's used legitimately in ilike
      final result = PostgrestSanitizer.sanitize('test%value');
      expect(result, 'test%value');
    });
  });
}
