import 'dart:async';

import '../gredu_unleash.dart';
import '../gredu_unleash_config.dart';

Future<void> main() async {
  // Setup Configuration
  final GreduUnleashConfig config = GreduUnleashConfig(
    proxyUrl: 'https://api.example.unleash/proxy',
    headers: {'Authorization': '934jhxxxxfdfndf4o'},
  );

  // Initialize GreduUnleash
  final unleash = await GreduUnleash.init(config: config);

  // Use isFeatureEnabled function to get feature toggle
  if (unleash.isFeatureEnabled('payment')) {
    // Enable Payment Feature
  } else {
    // Disable Payment Feature
  }

}