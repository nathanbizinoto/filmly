import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ab_test_service.dart';

class ABMovieCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool showFavoriteIcon;
  final bool isFavorite;
  final bool isWatched;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onWatchedPressed;

  const ABMovieCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.showFavoriteIcon = true,
    this.isFavorite = false,
    this.isWatched = false,
    this.onFavoritePressed,
    this.onWatchedPressed,
  });

  @override
  State<ABMovieCard> createState() => _ABMovieCardState();
}

class _ABMovieCardState extends State<ABMovieCard> {
  final ABTestService _abTestService = ABTestService();
  ABTestService.TestGroup? _testGroup;

  @override
  void initState() {
    super.initState();
    _loadTestGroup();
  }

  Future<void> _loadTestGroup() async {
    final group = await _abTestService.getTestGroup('movie_card_design');
    setState(() {
      _testGroup = group;
    });
  }

  void _trackInteraction(String action) {
    _abTestService.trackConversion('movie_card_design', action);
  }

  @override
  Widget build(BuildContext context) {
    if (_testGroup == null) {
      return const SizedBox(
          width: 140,
          height: 200,
          child: Center(child: CircularProgressIndicator()));
    }

    return GestureDetector(
      onTap: () {
        _trackInteraction('tap');
        widget.onTap?.call();
      },
      child: _testGroup == ABTestService.TestGroup.A
          ? _buildVersionA()
          : _buildVersionB(),
    );
  }

  // Versão A: Design original (mais compacto)
  Widget _buildVersionA() {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Movie Poster
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              color: Colors.grey.shade200,
            ),
            child: Stack(
              children: [
                // Poster Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              print(
                                  '✅ Imagem carregada com sucesso: ${widget.imageUrl}');
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppTheme.primaryBlue,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                                '💥 Erro ao carregar imagem: ${widget.imageUrl} - $error');
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.movie,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.movie,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),

                // Action Buttons (top right)
                if (widget.showFavoriteIcon)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.white,
                          onPressed: () {
                            _trackInteraction('favorite');
                            widget.onFavoritePressed?.call();
                          },
                        ),
                        const SizedBox(width: 4),
                        _buildActionButton(
                          icon: widget.isWatched
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: widget.isWatched ? Colors.green : Colors.white,
                          onPressed: () {
                            _trackInteraction('watched');
                            widget.onWatchedPressed?.call();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Movie Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Versão B: Design alternativo (mais largo, layout horizontal)
  Widget _buildVersionB() {
    return Container(
      width: 160, // Mais largo
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), // Mais arredondado
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primaryBlue.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Movie Poster com overlay gradient
          Container(
            height: 200, // Mais alto
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              color: Colors.grey.shade200,
            ),
            child: Stack(
              children: [
                // Poster Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppTheme.primaryPurple,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue.withOpacity(0.3),
                                    AppTheme.primaryPurple.withOpacity(0.3)
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.movie,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryBlue.withOpacity(0.3),
                                AppTheme.primaryPurple.withOpacity(0.3)
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.movie,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

                // Action Buttons (bottom center)
                if (widget.showFavoriteIcon)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButtonB(
                          icon: widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.white,
                          onPressed: () {
                            _trackInteraction('favorite');
                            widget.onFavoritePressed?.call();
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildActionButtonB(
                          icon: widget.isWatched
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: widget.isWatched ? Colors.green : Colors.white,
                          onPressed: () {
                            _trackInteraction('watched');
                            widget.onWatchedPressed?.call();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Movie Info com estilo diferente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryBlue.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtonB({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: color == Colors.white ? AppTheme.textPrimary : color,
        ),
      ),
    );
  }
}
