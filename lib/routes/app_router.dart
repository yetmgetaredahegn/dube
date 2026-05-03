import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Route: ${settings.name}')),
        body: Center(child: Text('Implement screens for ${settings.name}')),
      ),
    );
  }
}
