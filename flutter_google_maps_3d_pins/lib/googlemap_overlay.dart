import 'package:flutter/material.dart';
import 'package:flutter_google_maps_3d_pins/data/notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

const int carWidth = 60;

class MapWithOverlay extends ConsumerStatefulWidget {
  @override
  _MapWithOverlayState createState() => _MapWithOverlayState();
}

class _MapWithOverlayState extends ConsumerState<MapWithOverlay>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  List<LatLng> _markerPositions = [];
  List<AnimationController> _positionControllers = [];
  List<AnimationController> _rotationControllers = [];
  List<Animation<Offset>> _positionAnimations = [];
  List<Animation<double>> _rotationAnimations = [];
  List<double> _currentRotations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimations();
    });
  }

  @override
  void dispose() {
    for (var controller in _positionControllers) {
      controller.dispose();
    }
    for (var controller in _rotationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    final runningState = ref.read(runningStateProvider);
    _markerPositions = runningState.routeStates
        .map((state) => LatLng(
            state.currentPosition.latitude, state.currentPosition.longitude))
        .toList();
    _currentRotations =
        runningState.routeStates.map((state) => state.direction).toList();

    _positionControllers = List.generate(
      _markerPositions.length,
      (_) => AnimationController(
        duration: Duration(milliseconds: 2000),
        vsync: this,
      ),
    );

    _rotationControllers = List.generate(
      _markerPositions.length,
      (_) => AnimationController(
        duration: Duration(milliseconds: 2000),
        vsync: this,
      ),
    );

    _positionAnimations = List.generate(
      _markerPositions.length,
      (index) => Tween<Offset>(begin: Offset.zero, end: Offset.zero)
          .animate(_positionControllers[index]),
    );

    _rotationAnimations = List.generate(
      _markerPositions.length,
      (index) => Tween<double>(begin: 0.0, end: 0.0)
          .animate(_rotationControllers[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final runningState = ref.watch(runningStateProvider);
    _updateAnimations(runningState);
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _markerPositions.isNotEmpty
                ? _markerPositions[0]
                : LatLng(45.5268846, -122.6244951),
            zoom: 17,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          onCameraMove: (_) => _updatePixelPositions(),
        ),
        ..._buildMarkers(),
      ],
    );
  }

  void _updateAnimations(RunningState runningState) {
    if (runningState.routeStates.length != _markerPositions.length) {
      _initializeAnimations();
    }

    for (int i = 0; i < runningState.routeStates.length; i++) {
      final newPosition = LatLng(
        runningState.routeStates[i].currentPosition.latitude,
        runningState.routeStates[i].currentPosition.longitude,
      );
      final newRotation = normalizeAngle(runningState.routeStates[i].direction);

      if (newPosition != _markerPositions[i]) {
        _animateMarkerPosition(i, _markerPositions[i], newPosition);
        _markerPositions[i] = newPosition;
      }

      if (newRotation != _currentRotations[i]) {
        _animateMarkerRotation(i, _currentRotations[i], newRotation);
        _currentRotations[i] = newRotation;
      }
    }
  }

  void _animateMarkerPosition(
      int index, LatLng oldPosition, LatLng newPosition) async {
    if (_mapController == null) return;

    final oldScreenCoordinate =
        await _mapController!.getScreenCoordinate(oldPosition);
    final newScreenCoordinate =
        await _mapController!.getScreenCoordinate(newPosition);

    final oldOffset = Offset(
        oldScreenCoordinate.x.toDouble(), oldScreenCoordinate.y.toDouble());
    final newOffset = Offset(
        newScreenCoordinate.x.toDouble(), newScreenCoordinate.y.toDouble());

    setState(() {
      _positionAnimations[index] = Tween<Offset>(
        begin: oldOffset,
        end: newOffset,
      ).animate(CurvedAnimation(
        parent: _positionControllers[index],
        curve: Curves.easeInOut,
      ));

      _positionControllers[index].forward(from: 0);
    });
  }

  void _animateMarkerRotation(
      int index, double oldRotation, double newRotation) {
    setState(() {
      _rotationAnimations[index] = Tween<double>(
        begin: oldRotation,
        end: newRotation,
      ).animate(CurvedAnimation(
        parent: _rotationControllers[index],
        curve: Curves.easeInOut,
      ));

      _rotationControllers[index].forward(from: 0);
    });
  }

  double normalizeAngle(double angle) {
    while (angle >= 360) angle -= 360;
    while (angle < 0) angle += 360;
    return angle;
  }

  List<Widget> _buildMarkers() {
    print("_markerPositions.length = ${_markerPositions.length}");
    return List.generate(_markerPositions.length, (index) {
      return AnimatedBuilder(
        animation: Listenable.merge(
            [_positionAnimations[index], _rotationAnimations[index]]),
        builder: (context, child) {
          print(
              "_rotationAnimations[index].value = ${_rotationAnimations[index].value}");
          return Positioned(
            left: _positionAnimations[index].value.dx - carWidth / 2,
            top: _positionAnimations[index].value.dy - carWidth / 2,
            child: _buildCustomMarker(_rotationAnimations[index].value),
          );
        },
      );
    });
  }

  Widget _buildCustomMarker(double rotation) {
    return CarMarkerWidget(
      key: ValueKey('car_marker_$rotation'),
      imageIndex: _getImageIndexForAngle(rotation),
    );
  }

  // int _getImageIndexForAngle(double angle) {
  //   final int imageCount = 60;
  //   final double angleBetweenImages = 360 / imageCount;
  //   angle = (angle + 360) % 360;
  //   // print("------ angle: $angle");
  //   int index = ((angle / angleBetweenImages).round() % imageCount) + 1;
  //   // print("------ index: $index");
  //   return index > imageCount ? 1 : index;
  // }

  int _getImageIndexForAngle(double angle) {
    const int imageCount = 60;
    const double angleBetweenImages = 360 / imageCount;
    angle = normalizeAngle(angle);
    int index = ((angle / angleBetweenImages).round() % imageCount) + 1;
    return index > imageCount ? 1 : index;
  }

  void _updatePixelPositions() {
    for (int i = 0; i < _markerPositions.length; i++) {
      _animateMarkerPosition(i, _markerPositions[i], _markerPositions[i]);
    }
  }
}

//--------------------------------------------------------------------------------------------------
//Car marker

class CarMarkerWidget extends StatelessWidget {
  final int imageIndex;

  CarMarkerWidget({Key? key, required this.imageIndex}) : super(key: key);

  String _getImagePath(int index) {
    return 'assets/images/truck/${index.toString().padLeft(4, '0')}.png';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Image.asset(
        _getImagePath(imageIndex),
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }
}
