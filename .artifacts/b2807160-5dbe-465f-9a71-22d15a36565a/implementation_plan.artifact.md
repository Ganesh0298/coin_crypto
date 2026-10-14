# CoinPilot - Crypto Market & Research App Implementation Plan

A professional, feature-rich CoinGecko-style crypto market and research mobile application built in Flutter, incorporating advanced design tokens (`ColorResource`, `AppStyles`), custom widgets, search form widget separation, interactive charts, watchlist functionality, market statistics, and robust API loading, error, and empty states.

## User Review Required

- **Dependencies**: Adding `provider` for state management and `http` for REST API requests to CoinGecko demo API / public API with robust offline fallback static data.
- **UI Theme**: Built using `ColorResource` (deep blues/purples, gradients, clean cards, modern bottom navigation).

## Open Questions

- None. Proceeding with clean architecture and standalone widgets as requested in the task description.

## Proposed Changes

### Dependencies & Configuration
#### [MODIFY] [pubspec.yaml](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/pubspec.yaml)
- Add `provider` and `http` dependencies.

### Models & Services
#### [NEW] [coin_model.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/models/coin_model.dart)
- Data model representing cryptocurrency details (id, name, symbol, image, currentPrice, priceChangePercentage24h, marketCap, totalVolume, circulatingSupply, maxSupply, high24h, low24h, sparklineIn7d, description).
- Includes mock/demo dataset generator with 15+ popular coins (Bitcoin, Ethereum, Solana, Cardano, Ripple, etc.).

#### [NEW] [crypto_api_service.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/services/crypto_api_service.dart)
- REST API service fetching live markets from CoinGecko Public API (`https://api.coingecko.com/api/v3/coins/markets`) with seamless fallback to rich mock data ensuring 100% reliable interview demo functionality.

### State Management
#### [NEW] [crypto_provider.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/providers/crypto_provider.dart)
- ChangeNotifier managing coin list state, loading status, error messages, empty states, search query filtering, category tabs (All, Gainers, Losers, Watchlist), sorting options (Rank, Price, 24h Change), and watchlist toggling.

### Custom Widgets
#### [NEW] [search_form_widget.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/widgets/search_form_widget.dart)
- Separate search form widget with clear button, icon, hint styling, and text controller integration.

#### [NEW] [state_widgets.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/widgets/state_widgets.dart)
- Reusable `LoadingStateWidget`, `ErrorStateWidget`, and `EmptyStateWidget` supporting custom messages, retry actions, and modern icons.

#### [NEW] [coin_card_widget.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/widgets/coin_card_widget.dart)
- Professional list card displaying coin ranking, icon/avatar, symbol, name, live price, 24h percentage badge (green/red), sparkline preview, and watchlist toggle heart icon.

#### [NEW] [price_chart_widget.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/widgets/price_chart_widget.dart)
- Interactive price chart supporting timeframe selection (1H, 24H, 7D, 1M, 1Y, ALL) and responsive line chart rendering.

### Screens
#### [NEW] [coin_list_screen.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/view/screens/coin_list_screen.dart)
- Market overview screen containing header banner, separate SearchFormWidget, category filter chips, sorting dropdown, and coin list handling loading, error, and empty states.

#### [NEW] [coin_detail_screen.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/view/screens/coin_detail_screen.dart)
- Detailed coin view featuring current price, interactive price chart, key market statistics grid (Market Cap, 24h Volume, Circulating Supply, High/Low), about/description, and Buy/Watchlist actions.

#### [NEW] [market_stats_screen.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/view/screens/market_stats_screen.dart)
- Global market statistics overview (Total Market Cap, 24h Volume, BTC/ETH Dominance, Top Gainers & Losers, Trending Coins).

#### [NEW] [watchlist_screen.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/view/screens/watchlist_screen.dart)
- Dedicated watchlist screen showing favorited coins or an attractive empty state when no coins are bookmarked.

#### [NEW] [main_navigation_screen.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/view/screens/main_navigation_screen.dart)
- Bottom navigation container switching between Coin List, Market Stats, Watchlist, and Profile screens.

#### [MODIFY] [main.dart](file:///C:/Users/Ganesh/StudioProjects/coin_pilot/lib/main.dart)
- Wire up `MultiProvider` with `CryptoProvider` and launch `MainNavigationScreen` with professional theme settings.

## Verification Plan

### Automated Tests
- Flutter widget test verifying app startup and main screen rendering.

### Manual Verification
- Run app on emulator/device.
- Verify SearchForm widget filters coin list correctly.
- Verify category tabs (All, Gainers, Losers, Watchlist) and sorting function properly.
- Verify coin detail screen displays charts and statistics.
- Verify watchlist toggle updates state and displays correctly in the Watchlist tab.
- Verify loading, error, and empty state widgets function correctly.
