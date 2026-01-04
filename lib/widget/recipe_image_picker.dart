import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RecipeImagePicker extends StatefulWidget {
  final String? initialPath;
  final void Function(String path, Uint8List? webBytes) onImageSelected; // callback trả về khi người dùng chọn ảnh
                                  // dữ liệu ảnh dạng Uint8List (dùng cho Web)
  const RecipeImagePicker({
    super.key,
    this.initialPath,
    required this.onImageSelected,
  });

  @override
  State<RecipeImagePicker> createState() => _RecipeImagePickerState();
}

class _RecipeImagePickerState extends State<RecipeImagePicker> {
  File? selectedImage;
  Uint8List? webImageBytes;
  String imagePath = '';

  // Nếu có initialPath-đường dẫn ảnh ban đầu và là đường dẫn file nội bộ (bắt đầu bằng /), khởi tạo selectedImage
  @override
  void initState() {
    super.initState();
    imagePath = widget.initialPath ?? '';
    if (imagePath.startsWith('/') && !kIsWeb) {
      selectedImage = File(imagePath);
    }
  }

  Future<void> _pickFromGallery() async {
    final assetNames = [ 
      'banhflan.jpg',
      'banhxeo.jpg',
      'banhmithit.jpg', 
      'bunbo.jpg', 
      'comga.jpg', 
      'canhmangkho.jpg', 
      'chaoga.jpg', 
      'comga.jpg',
      'goicuon.jpg', 
      'kemtuoi.jpg', 
      'miquang.jpg', 
      'phobo.jpg', 
      'phokhotron.jpg', 
      'pumpkinpudding.jpg', 
      'suabo.jpg',
      'suadaunanh.jpg',
      'suahat.jpg',
      'suachuanepcam.jpg', 
      'thitnuong.jpg', 
      'traicaydia.jpg', 
      'xoidauphong.jpg', 
    ];

    final chosen = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn ảnh từ assets'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: assetNames.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, 
            ),
            itemBuilder: (_, i) {
              final assetPath = 'assets/images/${assetNames[i]}';
              return GestureDetector(
                onTap: () => Navigator.pop(context, assetPath),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(assetPath, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        actions: [ 
          TextButton( 
            onPressed: () => Navigator.pop(context), 
            child: const Text('Hủy'), 
          ), 
          TextButton( 
            onPressed: () { Navigator.pop(context, imagePath); }, 
            child: const Text('Lưu'), 
          ), 
        ],
      ),
    );

    if (chosen != null) { 
      setState(() { 
        imagePath = chosen; // lưu asset path 
        selectedImage = null; // bỏ File 
        webImageBytes = null; // bỏ base64 
      }); 
      widget.onImageSelected(imagePath, null); 
    }
  }

  Future<void> _pickFromCamera() async {
    if (!kIsWeb) {
      // Dùng package image_picker để mở camera
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() {
          selectedImage = File(picked.path);
          imagePath = picked.path;
        });
        widget.onImageSelected(imagePath, null);
      }
    }
  }

  // Hiển thị ảnh
  Widget _buildPreview() {
    if (imagePath.trim().isNotEmpty) {
      return Image.asset(
        imagePath.trim(),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/images/no_image.jpg', fit: BoxFit.contain),
      );
    }
    return Image.asset('assets/images/no_image.jpg', fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ảnh món ăn', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(height: 180, width: double.infinity, child: _buildPreview()),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Chọn từ máy'),
                onPressed: _pickFromGallery,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh'),
                onPressed: _pickFromCamera,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
