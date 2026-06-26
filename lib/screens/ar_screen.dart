import 'dart:io';

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../models/furniture_model.dart';
import '../widgets/ar_controls.dart';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  ArCoreController? arCoreController;
  bool _isLoading = true;
  bool _surfaceDetected = false;
  String? _selectedFurnitureId;
  final List<ArCoreNode> _placedNodes = [];
  String? _selectedNodeName;
  List<FurnitureItem> _furnitureItems = [];
  final Map<String, double> _nodeScales = {};
  final Map<String, double> _nodeRotations = {};
  final Map<String, String> _modelPathCache = {};
  final Map<String, vector.Vector3> _nodePositions = {};
  final Map<String, String> _nodeFurnitureIds = {};

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _furnitureItems = FurnitureItem.getSampleFurniture();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the furniture item passed from product detail screen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is FurnitureItem) {
      // Select the furniture item that was passed
      if (_selectedFurnitureId == null) {
        setState(() {
          _selectedFurnitureId = args.id;
        });
      }
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera permission to use AR features. Please grant camera permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    if (!mounted) {
      controller.dispose();
      return;
    }

    // Dispose old controller if it exists
    if (arCoreController != null) {
      try {
        arCoreController?.dispose();
      } catch (e) {
        print('Error disposing old controller: $e');
      }
    }

    arCoreController = controller;

    try {
      arCoreController!.onPlaneTap = _handlePlaneTap;
      arCoreController!.onPlaneDetected = _handlePlaneDetected;
      arCoreController!.onNodeTap = _handleNodeTap;

      // Enable better tracking and plane detection
      _configurePlaneDetection();
    } catch (e) {
      print('Error initializing AR controller: $e');
      if (mounted) {
        _showSnackBar('AR initialization failed. Please try again.');
      }
    }
  }

  void _handleNodeTap(String nodeName) {
    print('NodeTap: Tapped node $nodeName');
    // Select the tapped object
    if (_placedNodes.any((node) => node.name == nodeName)) {
      setState(() {
        _selectedNodeName = nodeName;
      });
      _showSnackBar('✓ Object selected. Use controls to adjust');
      print('NodeTap: Selected $nodeName');
    } else {
      print('NodeTap: WARNING - Node $nodeName not found in placed nodes!');
    }
  }

  void _configurePlaneDetection() {
    // ARCore automatically handles plane detection
    // The improved detection happens through better user guidance
    // and visual feedback in the UI
  }

  void _handlePlaneDetected(ArCorePlane plane) {
    if (!_surfaceDetected) {
      setState(() {
        _surfaceDetected = true;
      });

      // Provide helpful feedback on surface detection
      _showSnackBar('✅ Floor detected! White dots show detected areas');
    }
  }

  void _handlePlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      // Only place new furniture if a furniture type is selected
      if (_selectedFurnitureId != null) {
        _placeFurniture(hits.first);
      }
    }
  }

  bool _isTooCloseToExisting(vector.Vector3 newPosition) {
    const minDistance = 0.3; // 30cm minimum distance between objects

    for (var pos in _nodePositions.values) {
      final distance = (newPosition - pos).length;
      if (distance < minDistance) {
        return true;
      }
    }
    return false;
  }

  Future<void> _placeFurniture(ArCoreHitTestResult hit) async {
    if (arCoreController == null || !mounted) {
      print('Cannot place furniture: controller is null or widget disposed');
      return;
    }

    try {
      final furniture = _furnitureItems.firstWhere(
        (item) => item.id == _selectedFurnitureId,
      );

      final position = hit.pose.translation;

      // Check for collision with existing furniture
      if (_isTooCloseToExisting(position)) {
        _showSnackBar('⚠️ Too close to another object! Try a different spot');
        return;
      }

      final modelPath = await _prepareLocalModel(furniture.modelUrl);

      final nodeName = 'furniture_${DateTime.now().millisecondsSinceEpoch}';
      const initialRotation = 0.0;
      const initialScale = 1.0; // Start at normal size (100%)

      final node = ArCoreReferenceNode(
        name: nodeName,
        objectUrl: modelPath,
        position: position,
        rotation: _buildRotationQuaternion(initialRotation),
        scale: vector.Vector3(initialScale, initialScale, initialScale),
      );

      // Use the hit result to create a proper anchor at the detected surface
      await arCoreController!.addArCoreNodeWithAnchor(node);

      if (!mounted) return;

      setState(() {
        _placedNodes.add(node);
        _selectedNodeName = nodeName;
        _nodePositions[nodeName] = position;
        _nodeRotations[nodeName] = initialRotation;
        _nodeScales[nodeName] = initialScale;
        _nodeFurnitureIds[nodeName] = _selectedFurnitureId!;
      });

      _showSnackBar('${furniture.name} placed! Tap object to select');
    } catch (e) {
      print('Error placing furniture: $e');
      if (mounted) {
        _showSnackBar('Failed to place furniture. Please try again.');
      }
    }
  }

  Future<void> _rotateFurniture(double angle) async {
    if (_selectedNodeName == null) return;

    setState(() {
      _nodeRotations[_selectedNodeName!] =
          (_nodeRotations[_selectedNodeName!] ?? 0.0) + angle;
    });

    await _rebuildNode(_selectedNodeName!);
  }

  void _deleteFurniture() {
    if (_selectedNodeName != null && arCoreController != null) {
      arCoreController!.removeNode(nodeName: _selectedNodeName!);

      setState(() {
        _placedNodes.removeWhere((node) => node.name == _selectedNodeName);
        _nodePositions.remove(_selectedNodeName);
        _nodeRotations.remove(_selectedNodeName);
        _nodeScales.remove(_selectedNodeName);
        _nodeFurnitureIds.remove(_selectedNodeName);
        _selectedNodeName = null;
      });

      _showSnackBar('Furniture removed');
    }
  }

  Future<String> _prepareLocalModel(String assetPath) async {
    if (_modelPathCache.containsKey(assetPath)) {
      return _modelPathCache[assetPath]!;
    }

    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
      flush: true,
    );

    final uri = file.uri.toString();
    _modelPathCache[assetPath] = uri;
    return uri;
  }

  Future<void> _rebuildNode(String nodeName) async {
    print('RebuildNode: Starting for $nodeName');
    if (arCoreController == null) {
      print('RebuildNode: Controller is null!');
      return;
    }

    final position = _nodePositions[nodeName];
    final rotation = _nodeRotations[nodeName] ?? 0.0;
    final scale = _nodeScales[nodeName] ?? 1.0;
    final furnitureId = _nodeFurnitureIds[nodeName];

    print(
        'RebuildNode: position=$position, rotation=$rotation, scale=$scale, furnitureId=$furnitureId');

    if (position == null || furnitureId == null) {
      print('RebuildNode: Missing position or furnitureId!');
      return;
    }

    // Get furniture and model path
    final furniture =
        _furnitureItems.firstWhere((item) => item.id == furnitureId);
    final modelPath = await _prepareLocalModel(furniture.modelUrl);

    print('RebuildNode: Removing old node...');
    // Remove old node
    await arCoreController!.removeNode(nodeName: nodeName);

    print(
        'RebuildNode: Creating new node with scale Vector3($scale, $scale, $scale)...');
    // Create new node with updated transform
    final newNode = ArCoreReferenceNode(
      name: nodeName,
      objectUrl: modelPath,
      position: position,
      rotation: _buildRotationQuaternion(rotation),
      scale: vector.Vector3(scale, scale, scale),
    );

    print('RebuildNode: Adding node with anchor...');
    await arCoreController!.addArCoreNodeWithAnchor(newNode);

    // Update in list
    setState(() {
      final index = _placedNodes.indexWhere((node) => node.name == nodeName);
      if (index != -1) {
        _placedNodes[index] = newNode;
        print('RebuildNode: Updated node in list at index $index');
      } else {
        print('RebuildNode: WARNING - Node not found in list!');
      }
    });

    print('RebuildNode: Complete!');
  }

  vector.Vector4 _buildRotationQuaternion(double angle) {
    final quaternion = vector.Quaternion.axisAngle(
      vector.Vector3(0, 1, 0),
      angle,
    );
    return vector.Vector4(
      quaternion.x,
      quaternion.y,
      quaternion.z,
      quaternion.w,
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose AR controller FIRST before clearing data
    try {
      arCoreController?.dispose();
    } catch (e) {
      print('Error disposing AR controller: $e');
    }
    arCoreController = null;

    // Then clean up all resources
    _placedNodes.clear();
    _nodeScales.clear();
    _nodeRotations.clear();
    _modelPathCache.clear();
    _nodePositions.clear();
    _nodeFurnitureIds.clear();
    _selectedNodeName = null;

    super.dispose();
  }

  @override
  void deactivate() {
    // Additional cleanup when widget is deactivated
    if (arCoreController != null) {
      try {
        arCoreController?.dispose();
      } catch (e) {
        print('Error in deactivate: $e');
      }
      arCoreController = null;
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to use AR'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'White Dots (Plane Indicators):',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0058A3)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'White dots show detected surfaces. They may not always appear because:\n'
                          '• Low lighting conditions\n'
                          '• Plain/smooth floor (carpet, white tiles)\n'
                          '• Moving camera too fast\n'
                          '• ARCore needs time to build the map\n\n'
                          'TIP: You can still place furniture even without seeing white dots!',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Surface Scanning:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Move device slowly in circular motion\n'
                          '• Point at floor/table at 45° angle\n'
                          '• Ensure good lighting conditions\n'
                          '• Look for textured, non-reflective surfaces',
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Placing Furniture:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '1. Wait for surface detection\n'
                          '2. Select a furniture item from carousel\n'
                          '3. Tap on detected surface to place\n'
                          '4. Use controls to adjust position',
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Controls:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Rotate: Turn furniture left/right\n'
                          '• Scale: Make furniture bigger/smaller\n'
                          '• Delete: Remove current furniture',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                // AR View
                ArCoreView(
                  onArCoreViewCreated: _onArCoreViewCreated,
                  enableTapRecognizer: true,
                ),

                // Compact surface detection indicator
                if (!_surfaceDetected)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFBD914),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Scanning...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Furniture selection
                Positioned(
                  bottom: 140,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _furnitureItems.length,
                      itemBuilder: (context, index) {
                        final item = _furnitureItems[index];
                        final isSelected = _selectedFurnitureId == item.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFurnitureId = item.id;
                            });
                            _showSnackBar(
                                '${item.name} selected. Tap on floor to place');
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0058A3)
                                    : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Show PNG image if available, otherwise show icon
                                item.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          item.imagePath!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              _getCategoryIcon(item.category),
                                              size: 40,
                                              color: isSelected
                                                  ? const Color(0xFF0058A3)
                                                  : Colors.grey,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        _getCategoryIcon(item.category),
                                        size: 40,
                                        color: isSelected
                                            ? const Color(0xFF0058A3)
                                            : Colors.grey,
                                      ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? const Color(0xFF0058A3)
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // AR Controls
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: ARControls(
                    onRotateLeft: () => _rotateFurniture(-0.5),
                    onRotateRight: () => _rotateFurniture(0.5),
                    onScaleUp: null,
                    onScaleDown: null,
                    onDelete: _deleteFurniture,
                    isEnabled: _selectedNodeName != null,
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Chairs':
        return Icons.chair;
      case 'Tables':
        return Icons.table_restaurant;
      case 'Sofas':
        return Icons.weekend;
      case 'Beds':
        return Icons.bed;
      case 'Storage':
        return Icons.shelves;
      default:
        return Icons.home;
    }
  }
}
