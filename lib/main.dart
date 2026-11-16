import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'core/storage/token_storage.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_api_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/sign_up_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/learning_member_session.dart';
import 'view_models/movie_home_view_model.dart';
import 'view_models/movie_list_view_model.dart';
import 'view_models/session_rating_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final tokenStorage = SecureTokenStorage(const FlutterSecureStorage());
  final publicClient = createMovieLogClient(); // 토큰 X
  final authClient = createAuthMovieLogClient(tokenStorage); // 토큰 자동 첨부

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        ChangeNotifierProvider<SessionRatingStore>(
          create: (_) => SessionRatingStore(),
        ),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 공개 Client
        Provider<AuthApiService>(create: (_) => AuthApiService(publicClient)),
        Provider<SignUpService>(create: (_) => SignUpService(publicClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(publicClient, authClient),
        ),        // 보호 Client
        Provider<MemberApiService>(create: (_) => MemberApiService(authClient)),
        // ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
            context.read<SessionRatingStore>(),
          ),
        ),
        ChangeNotifierProvider<MovieHomeViewModel>(
          create: (context) =>
              MovieHomeViewModel(context.read<TmdbMovieService>())..loadPopular(),
        ),
        ChangeNotifierProvider<MovieListViewModel>(
          create: (context) =>
              MovieListViewModel(context.read<TmdbMovieService>())..init(),
        ),
      ],
      child: const MovieLogApp(),
    ),
  );
}

// Router는 앱이 살아있는 동안 한 번만 만들어야 해서 StatefulWidget으로 분리
class MovieLogApp extends StatefulWidget {
  const MovieLogApp({super.key});

  @override
  State<MovieLogApp> createState() => _MovieLogAppState();
}

class _MovieLogAppState extends State<MovieLogApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(authViewModel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) authViewModel.restoreSession(); // 첫 화면 뒤 세션 복원 시작
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MovieLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light.copyWith(
        textTheme: AppTheme.light.textTheme.apply(
          fontFamilyFallback: ['NotoSansKR'],
        ),
      ),
      routerConfig: _router,
    );
  }
}