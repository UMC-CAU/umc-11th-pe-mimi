class SessionGuard {
  int _generation = 0;
  String? _accountId;

  int get generation => _generation;
  String? get accountId => _accountId;

  // 검증된 새 세션이 시작될 때만 호출 (같은 계정이라도 새 로그인이면 새 세션)
  int startSession(String accountId) {
    _accountId = accountId;
    return ++_generation;
  }

  void invalidate() {
    _accountId = null;
    _generation++;
  }

  bool isCurrent(int generation, String accountId) =>
      _generation == generation && _accountId == accountId;
}