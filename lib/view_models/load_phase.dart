enum LoadPhase {
  idle, // 아직 요청 안 함
  loading, // 첫 로딩 중 (조건이 바뀐 새 첫 page 포함)
  ready, // 표시할 목록 있음
  empty, // 성공했지만 결과 없음
  error, // 첫 조회 실패
}
// 다음 page 로딩은 ready 목록을 지우지 않고 isLoadingMore로 따로 구분