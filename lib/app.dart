import 'package:flutter/material.dart';

import 'bootstrap.dart';

/// Main application widget
class BazarigoApp extends StatelessWidget {
  /// Bootstrap result from initialization
  final BootstrapResult? bootstrapResult;

  /// Creates the main app widget
  const BazarigoApp({
    super.key,
    this.bootstrapResult,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazarigo',
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      // Dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      // Theme mode
      themeMode: ThemeMode.system,
      
      // Home
      home: _HomePage(bootstrapResult: bootstrapResult),
    );
  }
}

/// Home page widget
class _HomePage extends StatelessWidget {
  /// Bootstrap result
  final BootstrapResult? bootstrapResult;

  /// Creates the home page
  const _HomePage({
    this.bootstrapResult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDegraded = bootstrapResult?.isDegradedMode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazarigo'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon
              Icon(
                Icons.shopping_bag_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(height: 24),
              
              // App title
              Text(
                'Bazarigo Mobile',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                'Production Marketplace',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Status card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Status indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDegraded 
                                ? Icons.warning_rounded 
                                : Icons.check_circle_rounded,
                            color: isDegraded 
                                ? theme.colorScheme.error 
                                : theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isDegraded ? 'Degraded Mode' : 'All Systems OK',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDegraded 
                                  ? theme.colorScheme.error 
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      if (bootstrapResult != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Bootstrap info
                        _InfoRow(
                          label: 'Boot Time',
                          value: '${bootstrapResult!.totalDuration}ms',
                          theme: theme,
                        ),
                        
                        if (bootstrapResult!.failedServices.isNotEmpty)
                          _InfoRow(
                            label: 'Failed Services',
                            value: bootstrapResult!.failedServices.length.toString(),
                            theme: theme,
                            isError: true,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Version info
              Text(
                'v4.0.3+100',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  /// Label text
  final String label;
  
  /// Value text
  final String value;
  
  /// Theme data
  final ThemeData theme;
  
  /// Whether this is an error state
  final bool isError;

  /// Creates an info row
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isError 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
