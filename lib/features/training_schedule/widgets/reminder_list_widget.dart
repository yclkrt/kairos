import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/features/training_schedule/model/reminder.dart';
import 'package:kairos/features/training_schedule/providers/reminder_provider.dart';

class ReminderListWidget extends ConsumerWidget {
  const ReminderListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final remindersAsync = ref.watch(remindersForSelectedDateProvider);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, selectedDate),
            const SizedBox(height: 12),
            _buildReminderList(remindersAsync, context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hatırlatıcılar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.lightText)),
            const SizedBox(height: 4),
            Text(_formatDate(selectedDate), style: const TextStyle(fontSize: 12, color: AppColors.lightHint)),
          ],
        ),
        IconButton(onPressed: () => _showAddReminderDialog(context, ref), icon: const Icon(Icons.add_circle_rounded), color: AppColors.primary, iconSize: 32),
      ],
    );
  }

  Widget _buildReminderList(AsyncValue<List<Reminder>> remindersAsync, BuildContext context, WidgetRef ref) {
    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Center(child: Text('Bu tarih için hatırlatıcı yok', style: TextStyle(color: AppColors.lightHint, fontSize: 14))));
        }
        return Column(children: reminders.map((r) => _buildReminderItem(context, ref, r)).toList());
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Hata: $e', style: const TextStyle(color: AppColors.error)),
    );
  }

  Widget _buildReminderItem(BuildContext context, WidgetRef ref, Reminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightDivider)),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightText)),
                if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(reminder.description!, style: const TextStyle(fontSize: 12, color: AppColors.lightHint)),
                ],
              ],
            ),
          ),
          IconButton(onPressed: () => _deleteReminder(context, ref, reminder), icon: const Icon(Icons.delete_outline_rounded), color: AppColors.error, iconSize: 20),
        ],
      ),
    );
  }

  void _deleteReminder(BuildContext context, WidgetRef ref, Reminder reminder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hatırlatıcıyı Sil', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${reminder.title}" hatırlatıcısını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(reminderActionsProvider).deleteReminder(reminder.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Hatırlatıcı silindi'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedDate = ref.read(selectedDateProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Yeni Hatırlatıcı Ekle', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(hintText: 'Başlık', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.title_rounded))),
            const SizedBox(height: 12),
            TextField(controller: descController, maxLines: 3, decoration: InputDecoration(hintText: 'Açıklama (opsiyonel)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), prefixIcon: const Icon(Icons.description_rounded))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                ref.read(reminderActionsProvider).addReminder(date: selectedDate, title: titleController.text.trim(), description: descController.text.trim().isEmpty ? null : descController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Hatırlatıcı eklendi'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
