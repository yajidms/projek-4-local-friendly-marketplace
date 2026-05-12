// File: lib/app/presentation/features/seller/widgets/image_picker_box.dart
//
// NFR-OPR-01: Touch target ≥ 48×48 dp.
// NFR-ATR-03: Scale animation ≤ 300ms.
// NFR-UND-02: Label "Unggah Tanda Pengenal" dalam Bahasa Indonesia.

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../theme/seller_theme.dart';

/// Kotak pemilih gambar dengan border putus-putus (dashed) sesuai Figma.
/// Menampilkan ikon '+' saat belum ada gambar; thumbnail saat sudah dipilih.
class ImagePickerBox extends StatefulWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final double size;
  final String label;

  const ImagePickerBox({
    super.key,
    this.imagePath,
    required this.onTap,
    this.size = 120,
    this.label = 'Unggah Tanda Pengenal',
  });

  @override
  State<ImagePickerBox> createState() => _ImagePickerBoxState();
}

class _ImagePickerBoxState extends State<ImagePickerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // NFR-ATR-03: ≤ 300ms
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: SellerTheme.labelStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scale,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: widget.imagePath != null
                  ? _ImagePreview(path: widget.imagePath!, size: widget.size)
                  : _DashedBox(size: widget.size),
            ),
          ),
        ),
        if (widget.imagePath != null) ...[
          const SizedBox(height: 6),
          Row(children: const [
            Icon(Icons.check_circle_outline,
                size: 14, color: SellerTheme.primaryGreen),
            SizedBox(width: 4),
            Text('Foto dipilih',
                style: TextStyle(
                    fontSize: 12, color: SellerTheme.primaryGreen)),
          ]),
        ],
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String path;
  final double size;
  const _ImagePreview({required this.path, required this.size});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius:
            BorderRadius.circular(SellerTheme.borderRadiusSmall),
        // Web tidak mendukung Image.file — gunakan Image.network
        // (image_picker di web mengembalikan blob URL)
        child: kIsWeb
            ? Image.network(
                path,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _DashedBox(size: 120),
              )
            : Image.file(
                File(path),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _DashedBox(size: 120),
              ),
      );
}

class _DashedBox extends StatelessWidget {
  final double size;
  const _DashedBox({required this.size});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedPainter(),
        child: Container(
          width: size,
          height: size,
          color: const Color(0xFFF9FBF9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline,
                  size: 34, color: SellerTheme.primaryGreenLight),
              SizedBox(height: 8),
              Text('Ketuk untuk\nmemilih foto',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
        ),
      );
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 6.0, gap = 4.0, r = SellerTheme.borderRadiusSmall;
    final paint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          const Radius.circular(r)));
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
