import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../data/police_stations.dart';
import 'helper/map_helper.dart';
import 'map_marker.dart';
import '../../widgets/drawer.dart';
import '../home_base.dart';

class PoliceMap extends StatefulWidget {
  const PoliceMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  _PoliceMapState createState() => _PoliceMapState();
}

class _PoliceMapState extends State<PoliceMap> {
  final Set<Marker> _markers = {};
  final Set<Marker> _displayMarkers = {};
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _userPosition;
  List<NearestPoliceStation> _nearestStations = [];
  BitmapDescriptor? _personMarkerIcon;
  final Map<int, BitmapDescriptor> _numberedMarkerIcons = {};
  final String _markerImageUrl =
      "https://lh3.googleusercontent.com/pw/AM-JKLXvI4IDsOOSWgYsFwter5CJtGJ88X9LgqgW2HSJMn0Q9du2gVV3RrqEkUQNgoNkX9dzWdQZuBE6bAp5KoCcifS7bQvM8OuXjpWIGcgJOSOj4D0lGwbNMzX0PJx_UhjzRclItgqbNAaGkzZB82E2YuES=s80-no?authuser=0";
  Fluster<MapMarker>? _clusterManager;

  final int _maxClusterZoom = 20;
  final int _minClusterZoom = 0;
  double _currentZoom = 15;
  bool _areMarkersLoading = true;
  final Color _clusterColor = Colors.red;
  final Color _clusterTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      if (widget.initialLatitude != null &&
          widget.initialLongitude != null &&
          widget.initialLatitude != 0 &&
          widget.initialLongitude != 0) {
        final position = Position(
          latitude: widget.initialLatitude!,
          longitude: widget.initialLongitude!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        if (!mounted) return;
        setState(() => _userPosition = position);
        await _onUserLocationReady(position);
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() => _userPosition = position);
      await _onUserLocationReady(position);
    } catch (e) {
      debugPrint('Police map location unavailable: $e');
    }
  }

  Future<void> _onUserLocationReady(Position position) async {
    _nearestStations = PoliceStationsData.findNearest(
      position.latitude,
      position.longitude,
      count: 3,
    );
    _personMarkerIcon ??= await MapHelper.createPersonMarker();
    for (var i = 0; i < _nearestStations.length; i++) {
      _numberedMarkerIcons[i] ??= await MapHelper.createNumberedMarker(i + 1);
    }
    if (!mounted) return;
    setState(() {});
    _refreshDisplayMarkers();
    await _moveToCurrentLocation(position);
    await _fitUserAndNearestStations();
  }

  Future<void> _fitUserAndNearestStations() async {
    if (_userPosition == null || _nearestStations.isEmpty) return;
    if (!_mapController.isCompleted) return;

    final controller = await _mapController.future;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _userPosition!.latitude,
        _userPosition!.longitude,
      ),
      northeast: LatLng(
        _userPosition!.latitude,
        _userPosition!.longitude,
      ),
    );

    var fittedBounds = bounds;
    for (final station in _nearestStations) {
      fittedBounds = _expandBounds(fittedBounds, station.position);
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(fittedBounds, 80),
    );
  }

  LatLngBounds _expandBounds(LatLngBounds bounds, LatLng point) {
    return LatLngBounds(
      southwest: LatLng(
        point.latitude < bounds.southwest.latitude
            ? point.latitude
            : bounds.southwest.latitude,
        point.longitude < bounds.southwest.longitude
            ? point.longitude
            : bounds.southwest.longitude,
      ),
      northeast: LatLng(
        point.latitude > bounds.northeast.latitude
            ? point.latitude
            : bounds.northeast.latitude,
        point.longitude > bounds.northeast.longitude
            ? point.longitude
            : bounds.northeast.longitude,
      ),
    );
  }

  Future<void> _moveToCurrentLocation(Position position) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> _focusStation(NearestPoliceStation station) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(station.position, 16),
    );
  }

  void _refreshDisplayMarkers() {
    final markers = <Marker>{..._markers};

    if (_userPosition != null && _personMarkerIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _userPosition!.latitude,
            _userPosition!.longitude,
          ),
          icon: _personMarkerIcon!,
          zIndex: 3,
          infoWindow: InfoWindow(title: 'You_Are_Here'.tr()),
        ),
      );
    }

    for (var i = 0; i < _nearestStations.length; i++) {
      final station = _nearestStations[i];
      final icon = _numberedMarkerIcons[i];
      if (icon == null) continue;

      markers.add(
        Marker(
          markerId: MarkerId('nearest_${station.id}'),
          position: station.position,
          icon: icon,
          zIndex: 2,
          infoWindow: InfoWindow(
            title: station.name,
            snippet: station.distanceLabel,
          ),
        ),
      );
    }

    setState(() => _displayMarkers
      ..clear()
      ..addAll(markers));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    if (_userPosition != null) {
      _moveToCurrentLocation(_userPosition!);
      _fitUserAndNearestStations();
    }

    _initMarkers();
  }

  void _initMarkers() async {
    final List<MapMarker> markers = [];

    for (final station in PoliceStationsData.stations) {
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

      markers.add(
        MapMarker(
          id: station.id.toString(),
          position: station.position,
          policeStationName: station.name,
          icon: markerImage,
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
      markers,
      _minClusterZoom,
      _maxClusterZoom,
    );

    await _updateMarkers();
  }

  Future<void> _updateMarkers([double? updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
      _clusterManager,
      _currentZoom,
      _clusterColor,
      _clusterTextColor,
      80,
    );

    _markers
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
    _refreshDisplayMarkers();
  }

  Widget _buildNearestStationsPanel() {
    if (_nearestStations.isEmpty) return const SizedBox.shrink();

    return Positioned(
      right: 12,
      top: 12,
      bottom: 12,
      width: 156,
      child: Material(
        elevation: 8,
        shadowColor: secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        color: appSurfaceElevated,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(color: appBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_police_rounded,
                      size: 16,
                      color: secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Nearest_Police_Stations'.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: secondary,
                          fontFamily: 'Poppins-Bold',
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: _nearestStations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final station = _nearestStations[index];
                    return _NearestStationTile(
                      rank: index + 1,
                      title: station.name,
                      distance: station.distanceLabel,
                      onTap: () => _focusStation(station),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearestStationsBottomSheet(ScrollController scrollController) {
    if (_nearestStations.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: appSurfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appBorder),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: appBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.local_police_rounded,
                    size: 16,
                    color: secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Nearest_Police_Stations'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: secondary,
                        fontFamily: 'Poppins-Bold',
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: _nearestStations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final station = _nearestStations[index];
                  return _NearestStationTile(
                    rank: index + 1,
                      title: station.name,
                    distance: station.distanceLabel,
                    onTap: () => _focusStation(station),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const CameraPosition _kInitialLocation = CameraPosition(
    target: LatLng(7.1525, 80.0688),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: appSurface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: appSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Police_Map".tr(),
          style: TextStyle(
            fontSize: 17,
            color: secondary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            color: appAccent.withValues(alpha: 0.85),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                "assets/icons/menu.svg",
                height: sysWidth / 100 * 7,
                colorFilter: ColorFilter.mode(secondary, BlendMode.srcIn),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: secondary,
              size: 26,
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeBase()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: DrawerWidget(),
      ),
      body: GoogleMap(
        mapToolbarEnabled: true,
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
        mapType: MapType.hybrid,
        initialCameraPosition: _kInitialLocation,
        markers: _displayMarkers,
        onMapCreated: (controller) => _onMapCreated(controller),
        onCameraMove: (position) => _updateMarkers(position.zoom),
      ),
      bottomSheet: _nearestStations.isEmpty
          ? null
          : DraggableScrollableSheet(
              initialChildSize: 0.22,
              minChildSize: 0.16,
              maxChildSize: 0.42,
              expand: false,
              builder: (context, scrollController) {
                return _buildNearestStationsBottomSheet(scrollController);
              },
            ),
    );
  }
}

class _NearestStationTile extends StatelessWidget {
  const _NearestStationTile({
    required this.rank,
    required this.title,
    required this.distance,
    required this.onTap,
  });

  final int rank;
  final String title;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: appSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      secondary,
                      Color.lerp(secondary, appAccent, 0.35)!,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins-Bold',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: secondary,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: 10,
                        color: appTextMuted,
                        fontFamily: 'Poppins-Light',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
