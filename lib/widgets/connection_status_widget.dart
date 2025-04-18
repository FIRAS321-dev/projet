import 'package:flutter/material.dart';
import 'package:edubridge/services/connectivity_service.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:provider/provider.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        final isOffline = connectivityService.lastStatus == ConnectivityStatus.offline;
        
        if (!isOffline) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: AppTheme.warningColor,
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Vous êtes hors ligne. Les modifications seront synchronisées lorsque vous serez de nouveau en ligne.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () async {
                  await connectivityService._checkConnection();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
}

