import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../Controller/language_controller.dart';
import '../../Resources/colors.dart';
import '../../Resources/style.dart';
import 'helper/map_helper.dart';
import 'map_marker.dart';
import '../../widgets/drawer.dart';
import '../home_base.dart';

class PoliceMap extends StatefulWidget {
  const PoliceMap({Key? key}) : super(key: key);

  @override
  _PoliceMapState createState() => _PoliceMapState();
}

class _PoliceMapState extends State<PoliceMap> {
  late GoogleMapController _googleMapController;
  final Set<Marker> _markers = Set();
  final Completer<GoogleMapController> _mapController = Completer();
  bool _isMapLoading = true;
  final String _markerImageUrl =
      "https://lh3.googleusercontent.com/pw/AM-JKLXvI4IDsOOSWgYsFwter5CJtGJ88X9LgqgW2HSJMn0Q9du2gVV3RrqEkUQNgoNkX9dzWdQZuBE6bAp5KoCcifS7bQvM8OuXjpWIGcgJOSOj4D0lGwbNMzX0PJx_UhjzRclItgqbNAaGkzZB82E2YuES=s80-no?authuser=0";
  Fluster<MapMarker>? _clusterManager;

  final int _maxClusterZoom = 20;
  final int _minClusterZoom = 0;
  double _currentZoom = 15;
  bool _areMarkersLoading = true;
  final Color _clusterColor = Colors.red;
  final Color _clusterTextColor = Colors.white;

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  void _initMarkers() async {
    final List<MapMarker> markers = [];

    for (LatLng markerLocation in _markerLocations) {
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

      markers.add(
        MapMarker(
          id: _markerLocations.indexOf(markerLocation).toString(),
          position: markerLocation,
          icon: markerImage,
          // PhoneNumber: phoneNumber,
          // PoliceStationName: policeStationName,
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
  }

  final List<LatLng> _markerLocations = [
    const LatLng(7.1525, 80.0688),
    const LatLng(7.1497, 80.1005),
    const LatLng(7.1973648, 80.0948561),
    const LatLng(6.878388486, 79.87413764),
    const LatLng(7.088306435, 80.01228422),
    const LatLng(7.067123415, 79.9597508),
    const LatLng(7.17451295, 79.95786307),
    const LatLng(6.983202519, 80.11108211),
    const LatLng(7.043245048, 80.12048138),
    const LatLng(6.949399045, 80.05767345),
    const LatLng(7.076866378, 80.02067605),
    const LatLng(7.034791604, 80.02612595),
    const LatLng(7.097560267, 80.06037714),
    const LatLng(7.054660362, 80.06930082),
    const LatLng(7.24545656, 80.12859375),
    const LatLng(6.878388486, 79.87413764),
    const LatLng(6.914295559, 79.84901581),
    const LatLng(6.892327926, 79.85580768),
    const LatLng(6.873449478, 79.86124585),
    const LatLng(6.91546866, 79.87834324),
    const LatLng(6.892066424, 79.87669354),
    const LatLng(6.909617551, 79.86435438),
    const LatLng(6.965101387, 79.86853347),
    const LatLng(6.949955245, 79.85716288),
    const LatLng(6.951048995, 79.86254944),
    const LatLng(6.930715259, 79.87715047),
    const LatLng(6.949297145, 79.87296134),
    const LatLng(6.941648278, 79.84250743),
    const LatLng(6.976180686, 79.87974577),
    const LatLng(6.958329742, 79.86721155),
    const LatLng(6.933645154, 79.84277658),
    const LatLng(6.9366115, 79.84976631),
    const LatLng(6.928226458, 79.86544964),
    const LatLng(6.934764851, 79.86962679),
    const LatLng(6.935152205, 79.85895665),
    const LatLng(6.938587003, 79.85640125),
    const LatLng(6.9416301, 79.85669383),
    const LatLng(6.927507626, 79.84899214),
    const LatLng(7.049022554, 79.89741833),
    const LatLng(6.955576291, 79.88609834),
    const LatLng(6.97824953, 79.92942227),
    const LatLng(6.989223574, 80.00030235),
    const LatLng(7.03516512, 79.92415443),
    const LatLng(6.994011167, 79.89462411),
    const LatLng(7.081229794, 79.89059078),
    const LatLng(7.014941917, 79.89842327),
    const LatLng(6.962667385, 80.00891868),
    const LatLng(6.950475145, 79.9174586),
    const LatLng(7.001711474, 79.95007291),
    const LatLng(6.970884182, 79.95356664),
    const LatLng(7.211134967, 79.83530057),
    const LatLng(7.1658503, 79.88265615),
    const LatLng(7.128707905, 79.87736418),
    const LatLng(7.265155388, 79.85705384),
    const LatLng(7.226565106, 80.00354789),
    const LatLng(7.283642234, 80.06648839),
    const LatLng(7.078919902, 79.85958169),
    const LatLng(7.140708819, 79.90028416),
    const LatLng(7.174280919, 79.88972787),
    const LatLng(7.224794857, 79.87997408),
    const LatLng(7.139230997, 79.83359361),
    const LatLng(6.873823017, 79.90187984),
    const LatLng(6.910887991, 79.92929173),
    const LatLng(6.909509211, 79.89515568),
    const LatLng(6.924635457, 79.9123651),
    const LatLng(6.937748601, 79.89630893),
    const LatLng(6.927435954, 79.92913664),
    const LatLng(6.925371456, 80.0172066),
    const LatLng(6.845602985, 79.92896058),
    const LatLng(6.841565149, 79.90129821),
    const LatLng(6.836421109, 80.00337794),
    const LatLng(6.841502934, 79.96353164),
    const LatLng(6.872631075, 79.99591305),
    const LatLng(6.842514568, 80.0924705),
    const LatLng(6.901092424, 80.08758133),
    const LatLng(6.825006348, 79.87008978),
    const LatLng(6.772951673, 79.88505518),
    const LatLng(6.8301, 79.8801),
    const LatLng(6.867289696, 79.88365929),
    const LatLng(6.80217254, 79.92259074),
    const LatLng(6.783147815, 79.98601247),
    const LatLng(6.787307951, 79.89506438),
    const LatLng(6.805772816, 79.86978003),
    const LatLng(6.7253408, 79.90085869),
    const LatLng(6.720964056, 79.90684835),
    const LatLng(6.749896135, 79.90028945),
    const LatLng(6.664405553, 79.92985053),
    const LatLng(6.715177056, 79.98767373),
    const LatLng(6.714623244, 80.06909335),
    const LatLng(6.743606177, 80.17507388),
    const LatLng(6.654973343, 80.05819006),
    const LatLng(6.785833956, 80.06522548),
    const LatLng(6.681693726, 80.02084678),
    const LatLng(6.660106495, 79.97246348),
    const LatLng(6.602241234, 79.95609524),
    const LatLng(6.585094572, 79.96102174),
    const LatLng(6.541356975, 79.97483344),
    const LatLng(6.480532041, 79.98343322),
    const LatLng(6.43304466, 79.99804263),
    const LatLng(6.467790654, 80.10830277),
    const LatLng(6.553566652, 80.02361211),
    const LatLng(6.595010544, 80.05712213),
    const LatLng(6.521125862, 80.11788654),
    const LatLng(6.437079891, 80.19427834),
    const LatLng(6.516979945, 80.22673775),
    const LatLng(6.650648585, 80.17695489),
    const LatLng(6.410720439, 80.32864765),
    const LatLng(6.542818205, 80.15713281),
    const LatLng(6.631309808, 80.09791711),
    const LatLng(6.033018864, 80.21711885),
    const LatLng(6.145339106, 80.09962892),
    const LatLng(6.092579275, 80.13998058),
    const LatLng(6.033391647, 80.23430901),
    const LatLng(5.988177755, 80.32722163),
    const LatLng(5.972532202, 80.36521409),
    const LatLng(6.03465623, 80.39102311),
    const LatLng(6.073592088, 80.27676697),
    const LatLng(6.12160931, 80.21081149),
    const LatLng(6.125859709, 80.25299623),
    const LatLng(6.106385971, 80.34876684),
    const LatLng(6.211167979, 80.34002419),
    const LatLng(6.197712291, 80.27523281),
    const LatLng(6.379929904, 80.35984365),
    const LatLng(6.279165632, 80.14291625),
    const LatLng(6.244866391, 80.04750862),
    const LatLng(6.172566155, 80.17496583),
    const LatLng(6.189421029, 80.09472143),
    const LatLng(6.335782492, 80.03018293),
    const LatLng(6.343757125, 80.0806788),
    const LatLng(6.299873474, 80.03855999),
    const LatLng(6.335202333, 80.22115005),
    const LatLng(6.271775054, 80.08469304),
    const LatLng(6.227444998, 80.11857884),
    const LatLng(6.422234496, 79.99689588),
    const LatLng(6.125201501, 80.18071676),
    const LatLng(5.94784363, 80.5470919),
    const LatLng(5.973300652, 80.42645524),
    const LatLng(5.94163542, 80.61404722),
    const LatLng(5.96426543, 80.69320565),
    const LatLng(6.013326403, 80.56793159),
    const LatLng(6.0848243, 80.6432274),
    const LatLng(6.073742527, 80.56413554),
    const LatLng(6.198063338, 80.58704566),
    const LatLng(6.310257462, 80.62901306),
    const LatLng(6.341435495, 80.55871997),
    const LatLng(6.099045802, 80.47760009),
    const LatLng(6.041373306, 80.407221),
    const LatLng(6.203687361, 80.4750265),
    const LatLng(6.256783398, 80.49367835),
    const LatLng(5.967561202, 80.49391938),
    const LatLng(6.290055523, 80.56035463),
    const LatLng(6.010515633, 80.51743633),
    const LatLng(6.229547479, 80.55909752),
    const LatLng(6.023955549, 80.79725457),
    const LatLng(6.04691403, 80.73538735),
    const LatLng(6.154104396, 80.69825506),
    const LatLng(6.153902308, 80.76726261),
    const LatLng(6.269720382, 80.6909633),
    const LatLng(6.248273897, 80.76501722),
    const LatLng(6.111261289, 80.93264199),
    const LatLng(6.165388976, 80.89708842),
    const LatLng(6.125161768, 81.02398264),
    const LatLng(6.125872139, 81.12520842),
    const LatLng(6.306024103, 81.00383214),
    const LatLng(6.341544641, 81.20270724),
    const LatLng(6.274922423, 81.29052567),
    const LatLng(6.413493733, 81.33137645),
    const LatLng(6.261104608, 81.23671531),
    const LatLng(6.222719275, 81.33588757),
    const LatLng(7.292943198, 80.63364436),
    const LatLng(7.26734326, 80.60190734),
    const LatLng(7.227284966, 80.57440965),
    const LatLng(7.256288076, 80.51690655),
    const LatLng(7.331841589, 80.62305336),
    const LatLng(7.25180943, 80.68956447),
    const LatLng(7.176512939, 80.77738825),
    const LatLng(7.336889614, 80.47181178),
    const LatLng(7.388286635, 80.61882461),
    const LatLng(7.43882245, 80.57193556),
    const LatLng(7.373670486, 80.52618298),
    const LatLng(7.27879309, 80.72071947),
    const LatLng(7.372941812, 80.58759975),
    const LatLng(7.201768869, 80.54424704),
    const LatLng(7.317915555, 80.76296687),
    const LatLng(7.317177749, 80.70225161),
    const LatLng(7.350601812, 80.68335006),
    const LatLng(7.362355607, 80.71373249),
    const LatLng(7.330901287, 80.7735562),
    const LatLng(7.318107604, 80.87908966),
    const LatLng(7.353091873, 80.95443807),
    const LatLng(7.162680036, 80.57096338),
    const LatLng(7.057354283, 80.53607482),
    const LatLng(7.115332664, 80.63555217),
    const LatLng(7.126559568, 80.53030745),
    const LatLng(7.196285079, 80.66994224),
    const LatLng(7.129954233, 80.66368467),
    const LatLng(7.462773565, 80.62615136),
    const LatLng(7.589369447, 80.61023492),
    const LatLng(7.52068422, 80.67880921),
    const LatLng(7.563522215, 80.56796509),
    const LatLng(7.692057634, 80.64963154),
    const LatLng(7.549867883, 80.83540674),
    const LatLng(7.542007542, 80.91649723),
    const LatLng(7.862080541, 80.64916635),
    const LatLng(7.763242952, 80.57414914),
    const LatLng(7.942427603, 80.73250251),
    const LatLng(6.974147128, 80.7676272),
    const LatLng(7.063870533, 80.68512042),
    const LatLng(6.997872456, 80.82334552),
    const LatLng(6.939990101, 80.74410979),
    const LatLng(6.856852141, 80.83132712),
    const LatLng(6.938464452, 80.66209447),
    const LatLng(6.952682994, 80.62840532),
    const LatLng(6.854919451, 80.74892903),
    const LatLng(6.884033176, 80.69280181),
    const LatLng(7.093571476, 80.86252413),
    const LatLng(7.012624358, 80.85843362),
    const LatLng(7.0800329, 80.80184964),
    const LatLng(7.038313339, 80.78220387),
    const LatLng(7.074633174, 80.91826355),
    const LatLng(6.894271828, 80.59868038),
    const LatLng(6.945967797, 80.53785974),
    const LatLng(6.989381124, 80.4940274),
    const LatLng(7.297055324, 80.2357779),
    const LatLng(7.628245567, 80.24197346),
    const LatLng(7.416370964, 80.32825283),
    const LatLng(7.47586941, 80.24544418),
    const LatLng(7.554618416, 80.36923892),
    const LatLng(7.433389929, 80.45089873),
    const LatLng(7.675844314, 80.42303372),
    const LatLng(7.333483375, 80.30081341),
    const LatLng(7.595631654, 80.48060671),
    const LatLng(7.548347877, 80.49272776),
    const LatLng(7.486097055, 80.36450208),
    const LatLng(7.471385636, 80.0241391),
    const LatLng(7.328025307, 80.02169702),
    const LatLng(7.336091226, 80.12504246),
    const LatLng(7.433294229, 80.21534978),
    const LatLng(7.607026555, 80.08155005),
    const LatLng(7.494077313, 79.91231889),
    const LatLng(7.5973117, 79.94891525),
    const LatLng(7.531523992, 80.18741624),
    const LatLng(7.742792922, 80.12122031),
    const LatLng(7.660810722, 80.12665881),
    const LatLng(7.809266428, 80.07798803),
    const LatLng(7.785020464, 80.01204849),
    const LatLng(7.835795011, 80.40065855),
    const LatLng(7.917240752, 80.24379732),
    const LatLng(8.001134258, 80.27784524),
    const LatLng(8.117906119, 80.18904004),
    const LatLng(8.056958945, 80.3561631),
    const LatLng(7.576184276, 79.78800505),
    const LatLng(7.415075393, 79.83977247),
    const LatLng(7.339620165, 79.84301512),
    const LatLng(7.300403212, 79.88259353),
    const LatLng(7.37439592, 79.89838195),
    const LatLng(7.494993989, 79.84024988),
    const LatLng(7.659456856, 79.83777573),
    const LatLng(8.029903669, 79.83439467),
    const LatLng(8.235139939, 79.76456601),
    const LatLng(7.808859494, 79.82574013),
    const LatLng(7.808862629, 79.82573091),
    const LatLng(7.691903169, 79.92257278),
    const LatLng(7.998654951, 80.10227379),
    const LatLng(8.055065552, 79.9558145),
    const LatLng(8.193404575, 80.09085028),
    const LatLng(8.012442934, 79.72627181),
    const LatLng(7.759745014, 79.78850044),
    const LatLng(9.657041722, 80.02366844),
    const LatLng(9.666723306, 80.13244807),
    const LatLng(9.697656761, 79.86822756),
    const LatLng(9.680657619, 80.2211695),
    const LatLng(9.687105886, 80.03835455),
    const LatLng(9.745531447, 80.02911861),
    const LatLng(9.727383334, 79.99691603),
    const LatLng(9.803891281, 80.03367674),
    const LatLng(9.827240393, 80.23329379),
    const LatLng(9.778800942, 80.02955045),
    const LatLng(9.776231719, 79.98315633),
    const LatLng(9.804368252, 80.19749093),
    const LatLng(9.826435264, 80.16985525),
    const LatLng(9.811474153, 80.04681931),
    const LatLng(9.392486978, 80.40777129),
    const LatLng(9.612255915, 80.33026601),
    const LatLng(8.071233691, 80.5427579),
    const LatLng(9.254748601, 80.14149581),
    const LatLng(8.756632837, 80.49866109),
    const LatLng(8.847189214, 80.4978361),
    const LatLng(8.84186542, 80.62343117),
    const LatLng(8.978345839, 79.91152388),
    const LatLng(9.148597158, 79.72568683),
    const LatLng(8.838577008, 80.03833308),
    const LatLng(8.747006111, 79.95501724),
    const LatLng(9.0844, 79.8187),
    const LatLng(9.267554459, 80.81772428),
    const LatLng(9.124786176, 80.4490369),
    const LatLng(9.326004991, 80.7093874),
    const LatLng(9.21298395, 80.76113572),
    const LatLng(9.161247593, 80.65328274),
    const LatLng(9.134464449, 80.31285177),
    const LatLng(8.980772692, 80.77372001),
    const LatLng(8.330616406, 80.40790754),
    const LatLng(8.360221616, 80.5126727),
    const LatLng(8.251423177, 80.42433931),
    const LatLng(8.170582943, 80.2926813),
    const LatLng(8.228842232, 80.15947037),
    const LatLng(8.229213794, 80.34584003),
    const LatLng(8.265236216, 80.21281883),
    const LatLng(8.485220245, 80.19410402),
    const LatLng(8.149819301, 80.41064938),
    const LatLng(8.037946116, 80.477922),
    const LatLng(7.933392813, 80.56398864),
    const LatLng(8.039809351, 80.59946509),
    const LatLng(8.290444111, 80.71548257),
    const LatLng(8.427519128, 80.68916469),
    const LatLng(8.554080074, 80.8314426),
    const LatLng(8.540165442, 80.49081632),
    const LatLng(8.642286415, 80.67072644),
    const LatLng(8.837357517, 80.7572579),
    const LatLng(8.071244313, 80.54315487),
    const LatLng(8.4703315, 80.47096924),
    const LatLng(8.343667415, 80.40032835),
    const LatLng(7.940692901, 80.99950255),
    const LatLng(8.048791298, 80.96577762),
    const LatLng(8.03634132, 80.90448845),
    const LatLng(8.150845171, 80.98449312),
    const LatLng(8.039452334, 80.75668162),
    const LatLng(7.778813354, 80.81607247),
    const LatLng(8.028321847, 81.0323758),
    const LatLng(7.785675882, 81.18564263),
    const LatLng(7.946621233, 81.24530599),
    const LatLng(6.996321171, 81.05766914),
    const LatLng(7.335420051, 80.99309659),
    const LatLng(7.469276686, 81.01692767),
    const LatLng(7.216606104, 81.12381462),
    const LatLng(7.198213165, 81.02064614),
    const LatLng(7.066375393, 81.19505409),
    const LatLng(6.934683552, 81.15482838),
    const LatLng(7.033150353, 81.16543251),
    const LatLng(6.831728701, 80.98681847),
    const LatLng(6.880607449, 81.04857846),
    const LatLng(6.90086484, 80.90587377),
    const LatLng(6.95854769, 80.93035162),
    const LatLng(6.928642506, 80.8981288),
    const LatLng(6.853728021, 80.86685197),
    const LatLng(6.767812506, 80.95725028),
    const LatLng(6.806228353, 80.96033823),
    const LatLng(6.7368229, 81.01621183),
    const LatLng(6.765587332, 80.88687412),
    const LatLng(6.875650029, 81.34836864),
    const LatLng(7.165546424, 81.22544194),
    const LatLng(6.907063814, 81.54758687),
    const LatLng(7.033842053, 81.2767075),
    const LatLng(6.979029231, 81.37205836),
    const LatLng(6.438229635, 81.13112987),
    const LatLng(6.751223615, 81.09972739),
    const LatLng(6.762690271, 81.25042394),
    const LatLng(6.889197868, 81.23546246),
    const LatLng(6.822508822, 81.53629484),
    const LatLng(6.546078885, 80.94783421),
    const LatLng(6.625700239, 81.26918703),
    const LatLng(6.928252362, 81.62729929),
    const LatLng(6.532364479, 81.13136171),
    const LatLng(6.750877789, 81.30683506),
    const LatLng(7.296835246, 81.67729014),
    const LatLng(7.200592725, 81.65454601),
    const LatLng(7.220710257, 81.5452821),
    const LatLng(7.362722185, 81.63606758),
    const LatLng(7.415304046, 81.77686856),
    const LatLng(7.524638959, 81.5397012),
    const LatLng(7.561330001, 81.36175811),
    const LatLng(7.401413637, 81.24349498),
    const LatLng(7.672401611, 81.04411225),
    const LatLng(7.414686978, 81.82484792),
    const LatLng(7.369522207, 81.81179492),
    const LatLng(7.216350491, 81.85324337),
    const LatLng(7.115872135, 81.85161799),
    const LatLng(6.878663637, 81.82688046),
    const LatLng(6.752354292, 81.79336437),
    const LatLng(7.718225317, 81.69912274),
    const LatLng(7.698077948, 81.65419725),
    const LatLng(7.702368463, 81.53659691),
    const LatLng(7.777204718, 81.60361493),
    const LatLng(7.919372419, 81.56564586),
    const LatLng(7.516088818, 81.78698682),
    const LatLng(7.694757484, 81.7245636),
    const LatLng(8.564041177, 81.2339478),
    const LatLng(8.592245112, 81.21694297),
    const LatLng(8.654251254, 81.20029277),
    const LatLng(8.819183237, 81.10039458),
    const LatLng(8.940346956, 80.98213701),
    const LatLng(8.49604636, 81.19087487),
    const LatLng(8.443596932, 81.26744141),
    const LatLng(8.356372837, 81.00778181),
    const LatLng(8.322117875, 81.29934316),
    const LatLng(8.630550156, 81.0313109),
    const LatLng(8.674709922, 80.96764103),
    const LatLng(8.499890536, 81.09518981),
    const LatLng(8.41034623, 81.11166003),
    const LatLng(8.320970239, 80.96931148),
    const LatLng(6.679647303, 80.40220864),
    const LatLng(6.593053058, 80.45953541),
    const LatLng(6.530844387, 80.39061201),
    const LatLng(6.591714127, 80.56898424),
    const LatLng(6.470314424, 80.61372721),
    const LatLng(6.632915493, 80.52134698),
    const LatLng(6.637971704, 80.31260734),
    const LatLng(6.779137402, 80.36479783),
    const LatLng(6.707446869, 80.55552638),
    const LatLng(6.649644702, 80.70029786),
    const LatLng(7.300080939, 80.38663598),
    const LatLng(6.596585762, 80.72359824),
    const LatLng(6.660755454, 80.8862445),
    const LatLng(6.608544033, 80.61927433),
    const LatLng(7.256119567, 80.35310275),
    const LatLng(7.257274239, 80.4459125),
    const LatLng(7.227647849, 80.19966391),
    const LatLng(7.205384119, 80.26186556),
    const LatLng(7.324785979, 80.38763431),
    const LatLng(7.17565727, 80.50027014),
    const LatLng(7.186750319, 80.45521975),
    const LatLng(7.1566985, 80.2950919),
    const LatLng(6.947698246, 80.21546451),
    const LatLng(6.946778146, 80.13780432),
    const LatLng(6.936039152, 80.3350732),
    const LatLng(7.046401751, 80.25421651),
    const LatLng(7.027462353, 80.29068852),
    const LatLng(6.995352721, 80.41247607),
    const LatLng(7.10687593, 80.33482894),
    const LatLng(6.338766252, 80.91574696),
    const LatLng(6.260954514, 80.90733495),
    const LatLng(6.402473592, 80.68770083),
    const LatLng(6.344267532, 80.77167848),
    const LatLng(6.360993242, 80.91852311),
    const LatLng(6.422242549, 80.81410168),
    const LatLng(6.502484771, 80.65566386),
  ];

  static const CameraPosition _kInitialLocation = const CameraPosition(
    target: LatLng(7.1525, 80.0688),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageController>();
    double sysHeight = MediaQuery.of(context).size.height;
    double sysWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mainBGColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mainBGColor,
        // iconTheme: IconThemeData(color: iconColor),
        title: Text(
          "Police_Map".tr(),
          style: TextStyle(
              fontSize: 18,
              color: secondary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins-Light'),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                "assets/icons/menu.svg",
                height: sysWidth / 100 * 8,
                color: buttonColor,
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
              Icons.arrow_back,
              color: primaryColor,
              size: 30,
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
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapToolbarEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.hybrid,
            initialCameraPosition: _kInitialLocation,
            markers: _markers,
            onMapCreated: (controller) => _onMapCreated(controller),
            onCameraMove: (position) => _updateMarkers(position.zoom),
          ),
        ],
      ),
    );
  }
}
