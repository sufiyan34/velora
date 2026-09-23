import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/complaint_controller.dart';
import '../../models/complaint_model.dart';
import '../../models/order_model.dart';
import '../../utills/customer_skeleton.dart';

const Color _ink = Color(0xFF202020);
const Color _accent = Color(0xFF6C4CF1);

class ComplaintScreen extends GetView<ComplaintController> {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _ink),
        title: Text(
          'Complaints',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isInitialLoading) {
          return const _ComplaintSkeleton();
        }

        return Column(
          children: [
            _ModeToggle(),
            Expanded(
              child: Obx(() {
                return controller.viewMode.value == 0
                    ? const _NewComplaintBody()
                    : const _HistoryBody();
              }),
            ),
          ],
        );
      }),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MODE TOGGLE                                                               */
/* -------------------------------------------------------------------------- */

class _ModeToggle extends GetView<ComplaintController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEBFB),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: _ToggleTab(
                      label: 'New Complaint',
                      selected: controller.viewMode.value == 0,
                      onTap: () => controller.setViewMode(0),
                    ),
                  ),
                  Expanded(
                    child: _ToggleTab(
                      label: 'My Complaints',
                      selected: controller.viewMode.value == 1,
                      onTap: () => controller.setViewMode(1),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? _accent : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* NEW COMPLAINT — ROOT                                                      */
/* -------------------------------------------------------------------------- */

class _NewComplaintBody extends GetView<ComplaintController> {
  const _NewComplaintBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.submittedComplaintId.value.isNotEmpty) {
        return const _SuccessView();
      }

      return const _ComplaintForm();
    });
  }
}

/* -------------------------------------------------------------------------- */
/* FORM                                                                      */
/* -------------------------------------------------------------------------- */

class _ComplaintForm extends GetView<ComplaintController> {
  const _ComplaintForm();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 700.w),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
          children: [
            Text(
              'Tell us what went wrong',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Our team reviews every complaint and responds within 24–48 hours.',
              style: GoogleFonts.poppins(
                fontSize: 11.5.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20.h),

            _FieldLabel('Subject'),
            SizedBox(height: 8.h),
            _FormTextField(
              hintText: 'A short summary, e.g. "Order arrived damaged"',
              onChanged: controller.setSubject,
            ),

            SizedBox(height: 18.h),
            _FieldLabel('Category'),
            SizedBox(height: 8.h),
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  for (final option in ComplaintCategories.all)
                    _CategoryChip(
                      label: option,
                      selected: controller.category.value == option,
                      onTap: () => controller.setCategory(option),
                    ),
                ],
              ),
            ),

            SizedBox(height: 18.h),
            _FieldLabel('Related order (optional)'),
            SizedBox(height: 8.h),
            const _OrderDropdown(),

            SizedBox(height: 18.h),
            _FieldLabel('Description'),
            SizedBox(height: 8.h),
            _FormTextField(
              hintText: 'Describe what happened in as much detail as you can…',
              onChanged: controller.setDescription,
              maxLines: 5,
            ),

            SizedBox(height: 18.h),
            _FieldLabel('Photos (optional)'),
            SizedBox(height: 8.h),
            const _PhotoPicker(),

            SizedBox(height: 26.h),
            Obx(() {
              if (controller.errorMessage.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  controller.errorMessage.value,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              );
            }),
            const _SubmitBar(),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );
  }
}

class _FormTextField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final int maxLines;

  const _FormTextField({
    required this.hintText,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 12.5.sp, color: _ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _accent),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? _accent : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* RELATED ORDER (OPTIONAL)                                                  */
/* -------------------------------------------------------------------------- */

class _OrderDropdown extends GetView<ComplaintController> {
  const _OrderDropdown();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final orders = controller.orders;
      final selected = controller.selectedOrder.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selected?.id,
            hint: Text(
              orders.isEmpty
                  ? 'No orders on your account'
                  : 'Not related to a specific order',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
            ),
            icon: Icon(
              Iconsax.arrow_down_1,
              size: 16.sp,
              color: Colors.grey.shade600,
            ),
            items: [
              for (final order in orders)
                DropdownMenuItem(
                  value: order.id,
                  child: Text(
                    '#${_shortId(order.id)} · ${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                    style: GoogleFonts.poppins(fontSize: 12.5.sp, color: _ink),
                  ),
                ),
            ],
            onChanged: (id) {
              final order = id == null
                  ? null
                  : orders.firstWhereOrNull((o) => o.id == id);
              controller.selectOrder(order);
            },
          ),
        ),
      );
    });
  }

  String _shortId(String id) {
    if (id.isEmpty) return '—';
    final tail = id.length <= 8 ? id : id.substring(id.length - 8);
    return tail.toUpperCase();
  }
}

/* -------------------------------------------------------------------------- */
/* PHOTOS                                                                    */
/* -------------------------------------------------------------------------- */

class _PhotoPicker extends GetView<ComplaintController> {
  const _PhotoPicker();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final urls = controller.photoUrls;
      final uploading = controller.isUploadingPhotos.value;

      return Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          ...urls.map(
            (url) => Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey.shade100,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade100),
                    errorWidget: (_, __, ___) => Icon(
                      Iconsax.image,
                      size: 18.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: InkWell(
                    onTap: () => controller.removePhoto(url),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.close_circle,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (urls.length < 4)
            InkWell(
              onTap: uploading ? null : controller.pickAndUploadPhotos,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: uploading
                    ? Center(
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Icon(
                        Iconsax.camera,
                        size: 20.sp,
                        color: Colors.grey.shade500,
                      ),
              ),
            ),
        ],
      );
    });
  }
}

/* -------------------------------------------------------------------------- */
/* SUBMIT                                                                    */
/* -------------------------------------------------------------------------- */

class _SubmitBar extends GetView<ComplaintController> {
  const _SubmitBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: controller.canSubmit
              ? () => controller.submitComplaint()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: controller.isSubmitting.value
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Submit Complaint',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      );
    });
  }
}

/* -------------------------------------------------------------------------- */
/* SUCCESS                                                                   */
/* -------------------------------------------------------------------------- */

class _SuccessView extends GetView<ComplaintController> {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480.w),
          child: Column(
            children: [
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.tick_circle5,
                  color: const Color(0xFF10B981),
                  size: 42.sp,
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Complaint Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We\'ll review your complaint and get back to you within 24–48 hours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  height: 1.6,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 26.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => controller.setViewMode(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Track My Complaints',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: controller.startAnotherComplaint,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _ink,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'File Another Complaint',
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
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

/* -------------------------------------------------------------------------- */
/* HISTORY                                                                   */
/* -------------------------------------------------------------------------- */

class _HistoryBody extends GetView<ComplaintController> {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingComplaints.value &&
          controller.myComplaints.isEmpty) {
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
          itemCount: 3,
          itemBuilder: (_, __) => const _ComplaintHistorySkeletonCard(),
        );
      }

      if (controller.myComplaints.isEmpty) {
        return const _EmptyState(
          icon: Iconsax.message_question,
          title: 'No complaints yet',
          message: 'Complaints you file will show up here with their status.',
        );
      }

      return Center(
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 30.h),
          itemCount: controller.myComplaints.length,
          itemBuilder: (context, index) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700.w),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _ComplaintHistoryCard(
                    complaint: controller.myComplaints[index],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ComplaintHistoryCard extends StatelessWidget {
  final ComplaintModel complaint;

  const _ComplaintHistoryCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  complaint.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              _StatusChip(status: complaint.status),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            complaint.category,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          if (complaint.createdAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Submitted ${_formatDate(complaint.createdAt!)}',
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
          if (complaint.hasResponse) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F2FC),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Response from our team',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    complaint.adminResponse!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: _ink,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: style.$1.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        style.$2,
        style: GoogleFonts.poppins(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: style.$1,
        ),
      ),
    );
  }

  (Color, String) _styleFor(String status) {
    switch (status) {
      case ComplaintStatuses.inProgress:
        return (const Color(0xFF2563EB), 'In Progress');
      case ComplaintStatuses.resolved:
        return (const Color(0xFF10B981), 'Resolved');
      case ComplaintStatuses.closed:
        return (const Color(0xFF6B7280), 'Closed');
      default:
        return (const Color(0xFFF59E0B), 'Open');
    }
  }
}

class _ComplaintHistorySkeletonCard extends StatelessWidget {
  const _ComplaintHistorySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: CustomerSkeleton.shimmer(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerSkeleton.block(width: 140.w, height: 13.h),
              SizedBox(height: 10.h),
              CustomerSkeleton.block(width: 200.w, height: 10.h),
              SizedBox(height: 8.h),
              CustomerSkeleton.block(width: 120.w, height: 9.h),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SHARED EMPTY STATE + SKELETON                                             */
/* -------------------------------------------------------------------------- */

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52.sp, color: Colors.grey.shade400),
            SizedBox(height: 14.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplaintSkeleton extends StatelessWidget {
  const _ComplaintSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 30.h),
      children: [
        CustomerSkeleton.shimmer(
          child: CustomerSkeleton.block(height: 46.h, radius: 14.r),
        ),
        SizedBox(height: 20.h),
        ...List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CustomerSkeleton.shimmer(
              child: CustomerSkeleton.block(height: 84.h, radius: 16.r),
            ),
          ),
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HELPERS                                                                   */
/* -------------------------------------------------------------------------- */

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
