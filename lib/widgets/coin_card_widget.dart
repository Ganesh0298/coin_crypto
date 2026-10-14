import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/coin_model.dart';
import '../bloc/crypto_bloc.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class CoinCardWidget extends StatelessWidget {
  final CoinModel coin;
  final VoidCallback onTap;

  const CoinCardWidget({
    super.key,
    required this.coin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: ColorResource.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.card,
        border: Border.all(color: ColorResource.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 32,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${coin.marketCapRank}',
                    style: AppStyles.medium.copyWith(
                      fontSize: 13,
                      color: ColorResource.textSecondary,
                    ),
                  ),
                ),
                // Coin Image / Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Image.network(
                    coin.image,
                    width: 38,
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: ColorResource.appThemeColor1.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.currency_bitcoin, color: ColorResource.appThemeColor1, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name & Symbol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        style: AppStyles.semiBold.copyWith(
                          fontSize: 15,
                          color: ColorResource.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coin.symbol,
                        style: AppStyles.regular.copyWith(
                          fontSize: 12,
                          color: ColorResource.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Price & 24h Change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(coin.currentPrice),
                      style: AppStyles.semiBold.copyWith(
                        fontSize: 15,
                        color: ColorResource.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? ColorResource.success.withOpacity(0.1)
                            : ColorResource.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                            size: 16,
                            color: isPositive ? ColorResource.success : ColorResource.danger,
                          ),
                          Text(
                            '${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                            style: AppStyles.medium.copyWith(
                              fontSize: 12,
                              color: isPositive ? ColorResource.success : ColorResource.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Watchlist Heart Button
                IconButton(
                  icon: Icon(
                    coin.isWatchlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: coin.isWatchlisted ? ColorResource.danger : ColorResource.textSecondary,
                    size: 22,
                  ),
                  onPressed: () {
                    context.read<CryptoCubit>().toggleWatchlist(coin.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1.0) {
      return '\$${price.toStringAsFixed(price > 1000 ? 2 : 2)}';
    } else {
      return '\$${price.toStringAsFixed(4)}';
    }
  }
}
