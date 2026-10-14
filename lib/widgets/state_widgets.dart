import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class LoadingStateWidget extends StatelessWidget {
  final String message;

  const LoadingStateWidget({super.key, this.message = 'Loading live cryptocurrency data...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(ColorResource.appThemeColor1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: AppStyles.medium.copyWith(
                fontSize: 15,
                color: ColorResource.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Please wait while we fetch the latest market stats.',
              style: AppStyles.regular.copyWith(
                fontSize: 13,
                color: ColorResource.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ColorResource.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.card,
            border: Border.all(color: ColorResource.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorResource.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 36,
                  color: ColorResource.danger,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Error',
                style: AppStyles.semiBold.copyWith(
                  fontSize: 18,
                  color: ColorResource.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage.isNotEmpty ? errorMessage : 'Unable to connect to crypto market servers. Showing cached demo data.',
                style: AppStyles.regular.copyWith(
                  fontSize: 14,
                  color: ColorResource.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorResource.appThemeColor1,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Retry Connection',
                  style: AppStyles.medium.copyWith(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Cryptocurrencies Found',
    this.subtitle = 'Try searching with a different keyword or check your filters.',
    this.icon = Icons.search_off_rounded,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorResource.appThemeColor1.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: ColorResource.appThemeColor1,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppStyles.semiBold.copyWith(
                fontSize: 18,
                color: ColorResource.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppStyles.regular.copyWith(
                fontSize: 14,
                color: ColorResource.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorResource.appThemeColor1),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppStyles.medium.copyWith(
                    fontSize: 14,
                    color: ColorResource.appThemeColor1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
