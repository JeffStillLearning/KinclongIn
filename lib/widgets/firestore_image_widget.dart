import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/firestore_image_service.dart';

class FirestoreImageWidget extends StatefulWidget {
  final String? imageRef;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const FirestoreImageWidget({
    super.key,
    required this.imageRef,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<FirestoreImageWidget> createState() => _FirestoreImageWidgetState();
}

class _FirestoreImageWidgetState extends State<FirestoreImageWidget> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(FirestoreImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageRef != widget.imageRef) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageRef == null || widget.imageRef!.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _imageBytes = null;
    });

    try {
      // Handle different types of image references
      if (FirestoreImageService.isFirestoreReference(widget.imageRef)) {
        // Load from Firestore
        final bytes = await FirestoreImageService.getImageBytes(widget.imageRef!);
        if (bytes != null) {
          setState(() {
            _imageBytes = bytes;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      } else if (FirestoreImageService.isLocalPlaceholder(widget.imageRef)) {
        // Handle local placeholder
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      } else {
        // Handle other types (network URLs, etc.)
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print('❌ Error loading image: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalPlaceholder() {
    IconData icon;
    Color color;
    String text;
    
    if (widget.imageRef!.contains('laundry')) {
      icon = Icons.local_laundry_service;
      color = Colors.blue;
      text = 'Laundry Photo\n(Placeholder)';
    } else if (widget.imageRef!.contains('payment')) {
      icon = Icons.payment;
      color = Colors.green;
      text = 'Payment Proof\n(Placeholder)';
    } else {
      icon = Icons.image;
      color = Colors.grey;
      text = 'Placeholder\nImage';
    }
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 48),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Text(
                'PLACEHOLDER',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child = _buildPlaceholder();
    } else if (_hasError) {
      child = _buildErrorWidget();
    } else if (FirestoreImageService.isLocalPlaceholder(widget.imageRef)) {
      child = _buildLocalPlaceholder();
    } else if (_imageBytes != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Image.memory(
          _imageBytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        ),
      );
    } else {
      child = _buildErrorWidget();
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: child,
      );
    }

    return child;
  }
}
