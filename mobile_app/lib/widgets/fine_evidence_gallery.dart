// lib/widgets/fine_evidence_gallery.dart
//
// Loads and shows the violation photos attached to a fine.
// Shared by the officer's FineDetailScreen and the driver's fine screens.
// Tap a photo for a full-screen, swipeable, pinch-to-zoom viewer.

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/fine_service.dart';

class FineEvidenceGallery extends StatefulWidget {
  final String fineId;
  final int photoCount;
  final String emptyText;
  final String retryText;

  const FineEvidenceGallery({
    super.key,
    required this.fineId,
    required this.photoCount,
    this.emptyText = 'No photos were attached to this fine.',
    this.retryText = 'Retry',
  });

  @override
  State<FineEvidenceGallery> createState() => _FineEvidenceGalleryState();
}

class _FineEvidenceGalleryState extends State<FineEvidenceGallery> {
  List<Uint8List> _photos = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.photoCount > 0) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final images = await FineService().getFineEvidence(widget.fineId);
      final decoded = <Uint8List>[];
      for (final img in images) {
        try {
          decoded.add(base64Decode(img.split(',').last));
        } catch (_) {}
      }
      if (mounted) setState(() => _photos = decoded);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.color;
    if (widget.photoCount == 0) {
      return Text(widget.emptyText, style: TextStyle(color: muted));
    }
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Column(
        children: [
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: Text(widget.retryText)),
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EvidencePhotoViewer(photos: _photos, initialIndex: i, heroPrefix: widget.fineId)),
        ),
        child: Hero(
          tag: '${widget.fineId}-$i',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(_photos[i], fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// Full-screen swipeable photo viewer with pinch-to-zoom.
class EvidencePhotoViewer extends StatelessWidget {
  final List<Uint8List> photos;
  final int initialIndex;
  final String heroPrefix;

  const EvidencePhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.heroPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (_, i) => Hero(
          tag: '$heroPrefix-$i',
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
