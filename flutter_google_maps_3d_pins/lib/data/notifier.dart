import 'package:flutter/material.dart';
import 'package:flutter_google_maps_3d_pins/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';

class LatLong {
  final double latitude;
  final double longitude;

  LatLong(this.latitude, this.longitude);
}

class RouteState {
  final LatLong currentPosition;
  final double direction;
  final int currentIndex;
  final bool isReversed;
  final double rotationDelta;

  RouteState({
    required this.currentPosition,
    required this.direction,
    required this.currentIndex,
    required this.isReversed,
    required this.rotationDelta,
  });
}

class RunningState {
  final List<RouteState> routeStates;

  RunningState({required this.routeStates});
}

final runningStateProvider =
    StateNotifierProvider<RunningStateNotifier, RunningState>((ref) {
  return RunningStateNotifier();
});

class RunningStateNotifier extends StateNotifier<RunningState> {
  RunningStateNotifier() : super(RunningState(routeStates: []));

  List<DetailedRoute> routes = [];
  List<Timer> timers = [];

  static const double STRAIGHT_ANGLE = 180.0;
  static const double FULL_ROTATION = 360.0;

  void initializeRoutes(List<DetailedRoute> initialRoutes) {
    routes = initialRoutes;
    state = RunningState(
      routeStates: List.generate(
        routes.length,
        (i) => RouteState(
          currentPosition: LatLong(routes[i].detailedRoute[0].latitude,
              routes[i].detailedRoute[0].longitude),
          direction: routes[i].detailedRoute[0].direction,
          currentIndex: 0,
          isReversed: false,
          rotationDelta: 0,
        ),
      ),
    );
    startRunning();
  }

  void startRunning() {
    for (int i = 0; i < routes.length; i++) {
      timers.add(Timer.periodic(
        Duration(milliseconds: 1000 + Random().nextInt(1500)),
        (timer) => updateRoute(i),
      ));
    }
  }

  void updateRoute(int routeIndex) {
    final route = routes[routeIndex].detailedRoute;
    final currentState = state.routeStates[routeIndex];
    int nextIndex;
    bool isReversed = currentState.isReversed;

    if (isReversed) {
      nextIndex = currentState.currentIndex - 1;
      if (nextIndex < 0) {
        nextIndex = 1;
        isReversed = false;
      }
    } else {
      nextIndex = currentState.currentIndex + 1;
      if (nextIndex >= route.length) {
        nextIndex = route.length - 2;
        isReversed = true;
      }
    }

    final nextPosition =
        LatLong(route[nextIndex].latitude, route[nextIndex].longitude);
    final newDirection = route[nextIndex].direction;
    final rotationDelta = calcMinAngle(currentState.direction, newDirection);

    print(
        "Route $routeIndex: New direction: $newDirection, Rotation delta: $rotationDelta");

    final newRouteState = RouteState(
      currentPosition: nextPosition,
      direction: newDirection,
      currentIndex: nextIndex,
      isReversed: isReversed,
      rotationDelta: rotationDelta,
    );

    final newRouteStates = List<RouteState>.from(state.routeStates);
    newRouteStates[routeIndex] = newRouteState;

    state = RunningState(routeStates: newRouteStates);
  }

  double calcMinAngle(double currentRotation, double nextRotation) {
    double angleDifference = (nextRotation - currentRotation).abs();
    if (angleDifference > STRAIGHT_ANGLE) {
      if (currentRotation < 0) {
        nextRotation = (-FULL_ROTATION + angleDifference) + currentRotation;
      } else {
        nextRotation = (FULL_ROTATION - angleDifference) + currentRotation;
      }
    }
    double result = nextRotation > FULL_ROTATION
        ? nextRotation - FULL_ROTATION
        : nextRotation;
    return result - currentRotation;
  }

  @override
  void dispose() {
    for (var timer in timers) {
      timer.cancel();
    }
    super.dispose();
  }
}
