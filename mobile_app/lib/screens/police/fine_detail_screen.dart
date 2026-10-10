// lib/screens/police/fine_detail_screen.dart
//
// Opened from the officer's fine history: full fine details plus the
// violation evidence photos captured when the fine was issued.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';
import '../../services/fine_service.dart';
import '../../services/police_locale_service.dart';

class FineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> fine;

  const FineDetailScreen({super.key, required this.fine});

  @override
  State<FineDetailScreen> createState() => _FineDetailScreenState();
}

class _FineDetailScreenState extends State<FineDetailScreen> {
  List<Uint8List> _photos = [];
  bool _loadingPhotos = false;
  String? _photoError;

  String _t(String key) => PoliceLocaleService.instance.translate(key);

  int get _photoCount => (widget.fine['photoCount'] ?? 0) as int;

  @override
  void initState() {
    super.initState();
    if (_photoCount > 0) _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _loadingPhotos = true;
      _photoError = null;
    });
    try {
      final images = await FineService().getFineEvidence(widget.fine['_id'].toString());
      final decoded = <Uint8List>[];
      for (final img in images) {
        try {
          decoded.add(base64Decode(img.split(',').last));
        } catch (_) {}
      }
      if (mounted) setState(() => _photos = decoded);
    } catch (e) {
      if (mounted) setState(() => _photoError = e.toString().replaceAll("Exception:", "").trim());
    } finally {
      if (mounted) setState(() => _loadingPhotos = false);
    }
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    return date == null ? '-' : DateFormat('yyyy-MM-dd – hh:mm a').format(date);
  }

  void _openViewer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PhotoViewer(photos: _photos, initialIndex: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fine = widget.fine;
    final paid = (fine['status'] ?? '').toString().toUpperCase() == 'PAID';
    final statusColor = paid ? AppColors.successGreen : AppColors.warningOrange;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('police.fine_detail_title')),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          fine['offenseName'] ?? '-',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          paid ? _t('police.history_status_paid') : _t('police.history_status_unpaid'),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Rs. ${fine['amount'] ?? 0}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                  const Divider(height: 24),
                  _row(Icons.card_membership, _t('police.record_license'), fine['licenseNumber']),
                  _row(Icons.directions_car, _t('police.record_vehicle'), fine['vehicleNumber']),
                  _row(Icons.location_on, _t('police.new_fine_location_label'), fine['place']),
                  _row(Icons.access_time, _t('police.new_fine_date_label'), _formatDate(fine['date'])),
                  _row(Icons.trending_down, _t('police.new_fine_points_label'), "-${fine['demeritPoints'] ?? 0}"),
                  if (paid && fine['paidAt'] != null)
                    _row(Icons.payments, _t('police.fine_detail_paid_on'), _formatDate(fine['paidAt'])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text("${_t('police.evidence_title')} ($_photoCount)",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          _buildPhotos(),
        ],
      ),
    );
  }

  Widget _buildPhotos() {
    if (_photoCount == 0) {
      return Text(_t('police.evidence_none'),
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color));
    }
    if (_loadingPhotos) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_photoError != null) {
      return Column(
        children: [
          Text(_photoError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.errorRed)),
          TextButton.icon(
            onPressed: _loadPhotos,
            icon: const Icon(Icons.refresh),
            label: Text(_t('police.record_retry')),
          ),
        ],
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => _openViewer(i),
        child: Hero(
          tag: 'evidence-$i',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(_photos[i], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                Text((value ?? '-').toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen swipeable photo viewer with pinch-to-zoom.
class _PhotoViewer extends StatelessWidget {
  final List<Uint8List> photos;
  final int initialIndex;

  const _PhotoViewer({required this.photos, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (_, i) => Hero(
          tag: 'evidence-$i',
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(child: Image.memory(photos[i])),
          ),
        ),
      ),
    );
  }
}
