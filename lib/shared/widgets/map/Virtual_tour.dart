// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class ExampleScreen3 extends StatefulWidget {
  const ExampleScreen3({super.key, this.title});

  final String? title;

  @override
  ExampleScreen3State createState() => ExampleScreen3State();
}

class ExampleScreen3State extends State<ExampleScreen3> {
  bool _showDebugInfo = false;
  double _lon = 0;
  double _lat = 0;
  double _tilt = 0;
  int _panoId = 0;

  final List<String> panoImages = [
    'assets/images/shot-panoramic-composition-bedroom.jpg',
    'assets/images/istockphoto-1321116143-1024x1024.jpg',
    'assets/images/shot-panoramic-composition-living-room.jpg',
  ];

  void onViewChanged(longitude, latitude, tilt) {
    setState(() {
      _lon = longitude;
      _lat = latitude;
      _tilt = tilt;
    });
  }

  Widget hotspotButton({
    String? text,
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(const CircleBorder()),
            backgroundColor: MaterialStateProperty.all(Colors.black38),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: onPressed,
          child: Icon(icon),
        ),
        if (text != null)
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Center(child: Text(text)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Virtual Tour'),
      ),
      body: Stack(
        children: [
          PanoramaViewer(
            animSpeed: 0.1,
            sensorControl: SensorControl.orientation,
            onViewChanged: onViewChanged,
            onTap: (longitude, latitude, tilt) =>
                print('onTap: $longitude, $latitude, $tilt'),
            onLongPressStart: (longitude, latitude, tilt) =>
                print('onLongPressStart: $longitude, $latitude, $tilt'),
            onLongPressMoveUpdate: (longitude, latitude, tilt) =>
                print('onLongPressMoveUpdate: $longitude, $latitude, $tilt'),
            onLongPressEnd: (longitude, latitude, tilt) =>
                print('onLongPressEnd: $longitude, $latitude, $tilt'),
            hotspots: [
              if (_panoId == 0)
                Hotspot(
                  latitude: -15.0,
                  longitude: -129.0,
                  width: 90,
                  height: 80,
                  widget: hotspotButton(
                    text: "Next scene",
                    icon: Icons.open_in_browser,
                    onPressed: () => setState(() => _panoId = 1),
                  ),
                ),
              if (_panoId == 1)
                Hotspot(
                  latitude: 0.0,
                  longitude: -46.0,
                  width: 90.0,
                  height: 80.0,
                  widget: hotspotButton(
                    text: "Next scene",
                    icon: Icons.double_arrow,
                    onPressed: () => setState(() => _panoId = 2),
                  ),
                ),
              if (_panoId == 2)
                Hotspot(
                  latitude: 0.0,
                  longitude: 160.0,
                  width: 90.0,
                  height: 80.0,
                  widget: hotspotButton(
                    text: "Next scene",
                    icon: Icons.double_arrow,
                    onPressed: () => setState(() => _panoId = 0),
                  ),
                ),
            ],
            child: Image.asset(panoImages[_panoId]),
          ),
          if (_showDebugInfo)
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lon: ${_lon.toStringAsFixed(3)}\n'
                      'Lat: ${_lat.toStringAsFixed(3)}\n'
                      'Tilt: ${_tilt.toStringAsFixed(3)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Toggle debug info',
        onPressed: () => setState(() => _showDebugInfo = !_showDebugInfo),
        child: Icon(_showDebugInfo ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }
}