import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'data/services/rating_api_service.dart';
import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'data/services/member_check_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/movie_home_view_model.dart';
import 'view_models/movie_list_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final movieLogClient = createMovieLogClient(); // 워크북 서버용 (하나만 만들어 공유)

  runApp(
    MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(movieLogClient),
        ),
          Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
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

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

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
      routerConfig: AppRouter.router,
    );
  }
}