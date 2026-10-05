import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/branch_model.dart';

class BranchMapScreen extends StatefulWidget {
  final List<BranchModel> branches;
  final BranchModel? initialSelectedBranch;

  const BranchMapScreen({
    super.key,
    required this.branches,
    this.initialSelectedBranch,
  });

  @override
  State<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends State<BranchMapScreen> {
  GoogleMapController? _mapController;
  BranchModel? _selectedBranch;
  bool _mapFailed = false;

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.initialSelectedBranch ??
        (widget.branches.isNotEmpty ? widget.branches.first : null);
  }

  LatLng get _initialCenter {
    if (_selectedBranch != null &&
        _selectedBranch!.latitude != 0.0 &&
        _selectedBranch!.longitude != 0.0) {
      return LatLng(_selectedBranch!.latitude, _selectedBranch!.longitude);
    }
    if (widget.branches.isNotEmpty) {
      final firstWithCoords = widget.branches.firstWhere(
        (b) => b.latitude != 0.0 && b.longitude != 0.0,
        orElse: () => widget.branches.first,
      );
      return LatLng(firstWithCoords.latitude, firstWithCoords.longitude);
    }
    // Default coordinates (e.g. New Delhi)
    return const LatLng(28.6139, 77.2090);
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    for (final branch in widget.branches) {
      if (branch.latitude == 0.0 && branch.longitude == 0.0) continue;
      markers.add(
        Marker(
          markerId: MarkerId('marker_${branch.id}'),
          position: LatLng(branch.latitude, branch.longitude),
          infoWindow: InfoWindow(
            title: branch.name,
            snippet: '${branch.radius.toInt()}m geofence radius',
          ),
          onTap: () {
            setState(() {
              _selectedBranch = branch;
            });
          },
        ),
      );
    }
    return markers;
  }

  Set<Circle> _buildCircles() {
    final circles = <Circle>{};
    for (final branch in widget.branches) {
      if (branch.latitude == 0.0 && branch.longitude == 0.0) continue;
      final isSelected = _selectedBranch?.id == branch.id;
      circles.add(
        Circle(
          circleId: CircleId('circle_${branch.id}'),
          center: LatLng(branch.latitude, branch.longitude),
          radius: branch.radius,
          fillColor: isSelected
              ? AppColors.primary.withOpacity(0.25)
              : AppColors.accent.withOpacity(0.15),
          strokeColor: isSelected ? AppColors.primary : AppColors.accent,
          strokeWidth: isSelected ? 3 : 1,
        ),
      );
    }
    return circles;
  }

  void _selectAndCenterBranch(BranchModel branch) {
    setState(() => _selectedBranch = branch);
    if (_mapController != null &&
        branch.latitude != 0.0 &&
        branch.longitude != 0.0) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(branch.latitude, branch.longitude),
            zoom: 16,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Boundary Map'),
      ),
      body: Stack(
        children: [
          // Google Map with Circles and Markers
          if (!_mapFailed)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCenter,
                zoom: 14.5,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _buildMarkers(),
              circles: _buildCircles(),
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: false,
            )
          else
            _buildMapFallback(theme),

          // Bottom Branch Selector Overlay Card
          if (widget.branches.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.store_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedBranch?.name ?? 'Select Branch',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (_selectedBranch?.address.isNotEmpty ?? false)
                                  Text(
                                    _selectedBranch!.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.info.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '${_selectedBranch?.radius.toInt() ?? 0}m Geofence',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Horizontal branch quick selector list
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: widget.branches.map((b) {
                            final isSel = b.id == _selectedBranch?.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(b.name),
                                selected: isSel,
                                onSelected: (_) => _selectAndCenterBranch(b),
                                selectedColor: AppColors.primaryLight.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: isSel ? AppColors.primary : AppColors.textSecondary,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapFallback(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Map Render Fallback',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Showing ${widget.branches.length} configured branch boundaries.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
