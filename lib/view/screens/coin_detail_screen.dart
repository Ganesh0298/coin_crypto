// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../widgets/price_chart_widget.dart';
// import '../../utils/app_colors.dart';
// import '../../utils/app_styles.dart';
//
// class CoinDetailScreen extends StatelessWidget {
//   final CoinModel coin;
//
//   const CoinDetailScreen({super.key, required this.coin});
//
//   @override
//   Widget build(BuildContext context) {
//     final isPositive = coin.priceChangePercentage24h >= 0;
//
//     return Scaffold(
//       backgroundColor: ColorResource.appMainBgColor,
//       appBar: AppBar(
//         backgroundColor: ColorResource.appThemeColor1,
//         elevation: 0,
//         title: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(AppRadius.pill),
//               child: Image.network(
//                 coin.image,
//                 width: 28,
//                 height: 28,
//                 errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: Colors.white, size: 20),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               coin.name,
//               style: AppStyles.semiBold.copyWith(fontSize: 18, color: Colors.white),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               '(${coin.symbol})',
//               style: AppStyles.regular.copyWith(fontSize: 14, color: Colors.white70),
//             ),
//           ],
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           BlocBuilder<CryptoCubit, CryptoState>(
//             builder: (context, state) {
//               // Find latest watchlisted state from cubit
//               final currentCoin = state.allCoins.firstWhere(
//                 (c) => c.id == coin.id,
//                 orElse: () => coin,
//               );
//               return IconButton(
//                 icon: Icon(
//                   currentCoin.isWatchlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
//                   color: currentCoin.isWatchlisted ? Colors.redAccent : Colors.white,
//                 ),
//                 onPressed: () {
//                   context.read<CryptoCubit>().toggleWatchlist(coin.id);
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Price & Change Banner
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: ColorResource.surface,
//                 borderRadius: BorderRadius.circular(AppRadius.lg),
//                 boxShadow: AppShadows.card,
//                 border: Border.all(color: ColorResource.border),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Current Price',
//                         style: AppStyles.regular.copyWith(fontSize: 13, color: ColorResource.textSecondary),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice > 10 ? 2 : 4)}',
//                         style: AppStyles.bold.copyWith(fontSize: 26, color: ColorResource.textPrimary),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: isPositive ? ColorResource.success.withOpacity(0.1) : ColorResource.danger.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(AppRadius.sm),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
//                           size: 20,
//                           color: isPositive ? ColorResource.success : ColorResource.danger,
//                         ),
//                         Text(
//                           '${isPositive ? '+' : ''}${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
//                           style: AppStyles.semiBold.copyWith(
//                             fontSize: 14,
//                             color: isPositive ? ColorResource.success : ColorResource.danger,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Interactive Price Chart Widget
//             PriceChartWidget(
//               prices: coin.sparklineIn7d,
//               isPositive: isPositive,
//             ),
//             const SizedBox(height: 20),
//             // Market Statistics Grid
//             Text(
//               'Market Statistics',
//               style: AppStyles.semiBold.copyWith(fontSize: 18, color: ColorResource.textPrimary),
//             ),
//             const SizedBox(height: 12),
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               childAspectRatio: 2.2,
//               children: [
//                 _buildStatCard('Market Cap', _formatLargeNumber(coin.marketCap), Icons.pie_chart_rounded),
//                 _buildStatCard('24h Volume', _formatLargeNumber(coin.totalVolume), Icons.bar_chart_rounded),
//                 _buildStatCard('Market Rank', '#${coin.marketCapRank}', Icons.military_tech_rounded),
//                 _buildStatCard('24h High / Low', '\$${coin.high24h.toStringAsFixed(1)} / \$${coin.low24h.toStringAsFixed(1)}', Icons.swap_vert_rounded),
//                 _buildStatCard('Circulating Supply', _formatLargeNumber(coin.circulatingSupply), Icons.donut_large_rounded),
//                 _buildStatCard('Max Supply', coin.maxSupply != null ? _formatLargeNumber(coin.maxSupply!) : 'Infinite', Icons.all_inclusive_rounded),
//               ],
//             ),
//             const SizedBox(height: 24),
//             // About Section
//             Text(
//               'About ${coin.name}',
//               style: AppStyles.semiBold.copyWith(fontSize: 18, color: ColorResource.textPrimary),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: ColorResource.surface,
//                 borderRadius: BorderRadius.circular(AppRadius.lg),
//                 boxShadow: AppShadows.card,
//                 border: Border.all(color: ColorResource.border),
//               ),
//               child: Text(
//                 coin.description,
//                 style: AppStyles.regular.copyWith(fontSize: 14, color: ColorResource.textSecondary, height: 1.5),
//               ),
//             ),
//             const SizedBox(height: 32),
//             // Action Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Trading simulation for ${coin.name} coming soon!'),
//                       backgroundColor: ColorResource.appThemeColor1,
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: ColorResource.appThemeColor1,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(AppRadius.md),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   'Trade ${coin.symbol}',
//                   style: AppStyles.semiBold.copyWith(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: ColorResource.surface,
//         borderRadius: BorderRadius.circular(AppRadius.md),
//         border: Border.all(color: ColorResource.border),
//         boxShadow: AppShadows.card,
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: ColorResource.appThemeColor1.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(AppRadius.sm),
//             ),
//             child: Icon(icon, size: 20, color: ColorResource.appThemeColor1),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: AppStyles.regular.copyWith(fontSize: 11, color: ColorResource.textSecondary),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: AppStyles.semiBold.copyWith(fontSize: 13, color: ColorResource.textPrimary),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatLargeNumber(double number) {
//     if (number >= 1e12) {
//       return '\$${(number / 1e12).toStringAsFixed(2)}T';
//     } else if (number >= 1e9) {
//       return '\$${(number / 1e9).toStringAsFixed(2)}B';
//     } else if (number >= 1e6) {
//       return '\$${(number / 1e6).toStringAsFixed(2)}M';
//     } else {
//       return '\$${number.toStringAsFixed(0)}';
//     }
//   }
// }
