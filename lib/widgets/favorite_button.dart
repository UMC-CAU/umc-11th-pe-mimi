import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/favorite_detail_view_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  // 서버 결과에 따라 Snackbar 안내
  Future<void> _toggle(BuildContext context, FavoriteDetailViewModel vm) async {
    await vm.toggle();
    if (!context.mounted || vm.isDisposed) return;
    final message = vm.errorMessage ??
        (vm.isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Consumer<FavoriteDetailViewModel>(
      builder: (context, vm, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 62,
              height: 48,
              child: vm.isLoading || vm.isSaving
                  ? Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: color),
                      ),
                    )
                  : IconButton(
                      color: color,
                      onPressed: vm.hasLoadedStatus ? () => _toggle(context, vm) : null,
                      icon: Icon(vm.isFavorite ? Icons.bookmark : Icons.bookmark_border),
                    ),
            ),
            const Text('즐겨찾기', style: TextStyle(fontSize: 12)),
            // 첫 여부 조회에 실패했을 때만 새로고침 버튼
            if (!vm.hasLoadedStatus && !vm.isLoading)
              SizedBox(
                width: 62,
                child: IconButton(
                  tooltip: '여부 다시 확인',
                  color: color,
                  onPressed: vm.load,
                  icon: const Icon(Icons.refresh),
                ),
              ),
          ],
        );
      },
    );
  }
}