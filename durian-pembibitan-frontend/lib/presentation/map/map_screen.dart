import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/shared/providers.dart';
import '../../core/shared/models/bibit_model.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  BibitModel? _selectedBibit;

  @override
  Widget build(BuildContext context) {
    final bibitsFuture = ref.watch(bibitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Lokasi Bibit'),
      ),
      body: bibitsFuture.when(
        data: (list) {
          // Filter only those with valid coordinates
          final mappedBibits = list.where((b) => b.latitude != null && b.longitude != null).toList();

          if (mappedBibits.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Tidak ada data koordinat bibit untuk dipetakan.\nSilakan edit bibit untuk menambahkan garis lintang (latitude) & bujur (longitude).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          // Compute center coordinates
          final double avgLat = mappedBibits.map((b) => b.latitude!).reduce((a, b) => a + b) / mappedBibits.length;
          final double avgLng = mappedBibits.map((b) => b.longitude!).reduce((a, b) => a + b) / mappedBibits.length;
          final center = LatLng(avgLat, avgLng);

          // Convert bibits to map markers
          final markers = mappedBibits.map((bibit) {
            final LatLng position = LatLng(bibit.latitude!, bibit.longitude!);
            Color markerColor = Colors.green;
            if (bibit.status == 'Sakit') markerColor = Colors.orange;
            if (bibit.status == 'Mati') markerColor = Colors.red;

            return Marker(
              point: position,
              width: 45,
              height: 45,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBibit = bibit;
                  });
                },
                child: Icon(
                  Icons.location_on,
                  color: markerColor,
                  size: 40,
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              // Map View
              FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.duriannursery.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Float Details Card
              if (_selectedBibit != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _selectedBibit!.kodeBibit,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                        _selectedBibit!.status,
                                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: _selectedBibit!.status == 'Sehat'
                                          ? Colors.green
                                          : _selectedBibit!.status == 'Sakit'
                                              ? Colors.orange
                                              : Colors.red,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Varietas: ${_selectedBibit!.varietas}'),
                                Text('Blok: ${_selectedBibit!.lokasiBlok}'),
                                Text('Koordinat: ${_selectedBibit!.latitude}, ${_selectedBibit!.longitude}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedBibit = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Gagal memuat peta: $e')),
      ),
    );
  }
}
