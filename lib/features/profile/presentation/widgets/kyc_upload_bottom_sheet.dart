import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/profile_controller.dart';

class KycUploadBottomSheet extends ConsumerStatefulWidget {
  const KycUploadBottomSheet({super.key});

  @override
  ConsumerState<KycUploadBottomSheet> createState() =>
      _KycUploadBottomSheetState();
}

class _KycUploadBottomSheetState extends ConsumerState<KycUploadBottomSheet> {
  final ImagePicker _picker = ImagePicker();
  String _selectedDocType = 'national_id';
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

  final Map<String, String> _docTypes = {
    'national_id': 'National ID / NIN Slip',
    'drivers_license': "Driver's License",
    'passport': 'International Passport',
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = photo.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text(
              'Could not access image: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedFileBytes == null || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.surface,
          content: Text(
            'Please select or snap a photo of your ID first',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final success = await ref
        .read(profileControllerProvider.notifier)
        .submitKycDocument(
          fileBytes: _selectedFileBytes!,
          fileName: _selectedFileName!,
          documentType: _selectedDocType,
        );

    if (mounted && success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.positiveGreen,
          content: Text(
            'Document uploaded to Supabase Vault! Status: Under Review',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final isDark = AppColors.isDarkMode(context);
    final bg = AppColors.surfElevated(context);
    final border = AppColors.border(context);
    final text = AppColors.text(context);
    final textSub = AppColors.textSub(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.accentCyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identity Verification',
                          style: TextStyle(
                            color: text,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Upgrade to Tier 2 (\$25,000/day limit)',
                          style: TextStyle(color: textSub, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Document Type Selector
              Text(
                '1. Select Document Type',
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _docTypes.entries.map((entry) {
                  final isSelected = _selectedDocType == entry.key;
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDocType = entry.key);
                      }
                    },
                    selectedColor: isDark
                        ? AppColors.pureWhite
                        : AppColors.pureBlack,
                    backgroundColor: isDark
                        ? AppColors.surface
                        : AppColors.lightSurface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? AppColors.pureBlack : AppColors.pureWhite)
                          : text,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : border,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // File Picker / Preview Box
              Text(
                '2. Upload Photo of ID',
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              if (_selectedFileBytes != null) ...[
                // Image Preview Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _selectedFileBytes!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName ?? 'id_document.jpg',
                              style: TextStyle(
                                color: text,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_selectedFileBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB • Ready to submit',
                              style: TextStyle(
                                color: AppColors.positiveGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: textSub,
                        onPressed: () {
                          setState(() {
                            _selectedFileBytes = null;
                            _selectedFileName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Upload Buttons (Camera & Gallery)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickImage(ImageSource.camera),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surface
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.camera_alt_rounded,
                                  color: text, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'Take Photo',
                                style: TextStyle(
                                  color: text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickImage(ImageSource.gallery),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surface
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.photo_library_rounded,
                                  color: text, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'From Gallery',
                                style: TextStyle(
                                  color: text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 26),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.isUploadingKyc ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.pureWhite
                        : AppColors.pureBlack,
                    foregroundColor: isDark
                        ? AppColors.pureBlack
                        : AppColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: state.isUploadingKyc
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? AppColors.pureBlack
                                    : AppColors.pureWhite,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Encrypting & Uploading...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Submit to Supabase Vault',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
