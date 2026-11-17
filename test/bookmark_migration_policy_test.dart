import 'package:flutter_test/flutter_test.dart';

Set<int> mergeBookmarkSets(Set<int> anonymous, Set<int> account) => {...anonymous, ...account};

void main() {
  test('merges anonymous and account bookmarks after sign-in', () {
    expect(mergeBookmarkSets({3, 8}, {8, 21}), {3, 8, 21});
  });

  test('does not mutate either source set', () {
    final anonymous = {3};
    final account = {21};

    mergeBookmarkSets(anonymous, account);

    expect(anonymous, {3});
    expect(account, {21});
  });
}
