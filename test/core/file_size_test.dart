import 'package:flutter_test/flutter_test.dart';
import 'package:haqani/core/utils/file_size.dart';

void main() {
  test('simple units', () {
    expect(FileSize.format(0), '0 B');
    expect(FileSize.format(900), '900 B');
    expect(FileSize.format(1536), '1.5 KB');
    expect(FileSize.format(20 * 1024), '20 KB');
    expect(FileSize.format((2.5 * 1024 * 1024).round()), '2.5 MB');
    expect(FileSize.format(300 * 1024 * 1024), '300 MB');
    expect(FileSize.format(3 * 1024 * 1024 * 1024), '3.0 GB');
  });
}
