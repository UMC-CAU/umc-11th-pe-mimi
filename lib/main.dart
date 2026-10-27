import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'view_models/movie_list_view_model.dart';
import 'core/network/tmdb_client.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'view_models/movie_home_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
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