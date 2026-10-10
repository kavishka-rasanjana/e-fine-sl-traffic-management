// lib/screens/police/fine_detail_screen.dart
//
// Opened from the officer's fine history: full fine details plus the
// violation evidence photos captured when the fine was issued.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/app_constants.dart';
import '../../services/police_locale_service.dart';
import '../../widgets/fine_evidence_gallery.dart';

class FineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> fine;

  const FineDetailScreen({super.key, required this.fine});

  String _t(String key) => PoliceLocaleService.instance.translate(key);

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    return date == null ? '-' : DateFormat('yyyy-MM-dd – hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final paid = (fine['status'] ?? '').toString().toUpperCase() == 'PAID';
    final statusColor = paid ? AppColors.successGreen : AppColors.warningOrange;
    final photoCount = (fine['photoCount'] ?? 0) as int;
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
                  _row(context, Icons.card_membership, _t('police.record_license'), fine['licenseNumber']),
                  _row(context, Icons.directions_car, _t('police.record_vehicle'), fine['vehicleNumber']),
                  _row(context, Icons.location_on, _t('police.new_fine_location_label'), fine['place']),
                  _row(context, Icons.access_time, _t('police.new_fine_date_label'), _formatDate(fine['date'])),
                  _row(context, Icons.trending_down, _t('police.new_fine_points_label'), "-${fine['demeritPoints'] ?? 0}"),
                  if (paid && fine['paidAt'] != null)
                    _row(context, Icons.payments, _t('police.fine_detail_paid_on'), _formatDate(fine['paidAt'])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text("${_t('police.evidence_title')} ($photoCount)",
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          FineEvidenceGallery(
            fineId: fine['_id'].toString(),
            photoCount: photoCount,
            emptyText: _t('police.evidence_none'),
            retryText: _t('police.record_retry'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, dynamic value) {
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
