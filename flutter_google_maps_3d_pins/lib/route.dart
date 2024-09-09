import 'dart:convert';

class RoutePoint {
  final double latitude;
  final double longitude;
  final double direction;

  RoutePoint(this.latitude, this.longitude, this.direction);

  factory RoutePoint.fromJson(List<dynamic> json) {
    return RoutePoint(json[0], json[1], json[2]);
  }
}

class DetailedRoute {
  final List<RoutePoint> detailedRoute;

  DetailedRoute(this.detailedRoute);

  factory DetailedRoute.fromJson(Map<String, dynamic> json) {
    var routeList = json['detailed_route'] as List;
    List<RoutePoint> routePoints =
        routeList.map((i) => RoutePoint.fromJson(i)).toList();
    return DetailedRoute(routePoints);
  }
}

List<DetailedRoute> parseRoutes(String jsonString) {
  final parsed = json.decode(jsonString);
  return (parsed as List).map((i) => DetailedRoute.fromJson(i)).toList();
}
