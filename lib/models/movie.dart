class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.runtime,
    required this.synopsis,
  });

  final int id;             // 영화 번호 (주소에 들어감)
  final String title;       // 제목
  final String genre;       // 장르 (필터링에 씀)
  final int year;           // 개봉 연도
  final String posterAsset; // 포스터 이미지 경로
  final double rating;      // 평균 평점
  final int runtime;        // 상영 시간(분)
  final String synopsis;    // 줄거리 (상세 화면)
}

const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.5,
    runtime: 124,
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 작은 천문대에서 만나 서로의 상처를 치유해 가는 이야기.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    runtime: 138,
    synopsis: '인류의 마지막 희망을 싣고 떠난 탐사선이 우주의 끝에서 예상치 못한 신호를 발견한다.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    runtime: 105,
    synopsis: '속삭이는 숲에 들어간 소녀가 잃어버린 기억의 조각을 찾아 떠나는 신비로운 모험.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    runtime: 117,
    synopsis: '비 내리는 골목에서 벌어진 사건을 쫓던 형사가 도시의 어두운 비밀과 마주한다.',
  ),
    Movie(
    id: 5,
    title: '미션: 임프로버블',
    genre: '액션',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.0,
    runtime: 129,
    synopsis: '돌아온 요원 맥스 스틸러가 이번엔 폭소와 폭발이 뒤섞인 임무에 뛰어든다.',
  ),
  Movie(
    id: 6,
    title: '네 번째 오후',
    genre: '드라마',
    year: 2022,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.3,
    runtime: 112,
    synopsis: '매주 같은 카페에서 마주치던 두 사람이 네 번째 오후에 처음으로 말을 건넨다.',
  ),
];

// ID로 영화 찾기 (없으면 null)
Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}