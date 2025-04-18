import 'package:edubridge/services/auth_service.dart';
import 'package:edubridge/services/connectivity_service.dart';
import 'package:edubridge/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> firebaseProviders = [
  ChangeNotifierProvider<AuthService>(
    create: (_) => AuthService(),
  ),
  ChangeNotifierProvider<ConnectivityService>(
    create: (_) => ConnectivityService(),
  ),
  ChangeNotifierProxyProvider<ConnectivityService, DatabaseService>(
    create: (context) => DatabaseService(
      Provider.of<ConnectivityService>(context, listen: false),
    ),
    update: (context, connectivityService, previous) => 
      previous ?? DatabaseService(connectivityService),
  ),
];

