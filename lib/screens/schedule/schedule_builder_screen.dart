import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../services/notification_service.dart';

class ScheduleBuilderScreen extends StatefulWidget {
  final Schedule? schedule;
  final int? index;
  const ScheduleBuilderScreen({super.key, this.schedule, this.index});

  @override
  State<ScheduleBuilderScreen> createState() => _ScheduleBuilderScreenState();
}

class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'quran';
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecurring = false;
  bool _hasAlarm = true;
  List<int> _selectedDays = [];
  
  final Map<String, String> _activityTypes = {
    'quran': 'Quran Reading',
    'tasbih': 'Tasbih',
    'dua': 'Dua',
    'hadith': 'Hadith',
    'custom': 'Custom',
  };

  final Map<int, String> _weekDays = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.description;
      _selectedType = widget.schedule!.type;
      _selectedTime = TimeOfDay.fromDateTime(widget.schedule!.time);
      _isRecurring = widget.schedule!.isRecurring;
      _hasAlarm = widget.schedule!.hasAlarm;
      _selectedDays = List.from(widget.schedule!.recurringDays);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Create Schedule' : 'Edit Schedule'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Activity Type', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _activityTypes.entries.map((entry) {
                        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _selectedTime);
                  if (time != null) setState(() => _selectedTime = time);
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Recurring'),
                    subtitle: const Text('Repeat this schedule'),
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                        if (!value) _selectedDays.clear();
                      });
                    },
                  ),
                  if (_isRecurring) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Days:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _weekDays.entries.map((e) {
                              final isSelected = _selectedDays.contains(e.key);
                              return FilterChip(
                                label: Text(e.value),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedDays.add(e.key);
                                    } else {
                                      _selectedDays.remove(e.key);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Alarm'),
                subtitle: const Text('Play alarm sound at scheduled time'),
                value: _hasAlarm,
                secondary: const Icon(Icons.alarm),
                onChanged: (value) => setState(() => _hasAlarm = value),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveSchedule,
              icon: const Icon(Icons.save),
              label: Text(widget.schedule == null ? 'Save Schedule' : 'Update Schedule'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isRecurring && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }
    
    final now = DateTime.now();
    var scheduleTime = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }
    
    final schedule = Schedule(
      title: _titleController.text,
      description: _descriptionController.text,
      time: scheduleTime,
      type: _selectedType,
      isRecurring: _isRecurring,
      recurringDays: _selectedDays,
      hasAlarm: _hasAlarm,
      completionCount: widget.schedule?.completionCount ?? 0,
    );
    
    final List<int> notificationIds = [];
    
    if (_hasAlarm) {
      try {
        await NotificationService().requestPermission();
        
        final baseId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        
        if (_isRecurring && _selectedDays.isNotEmpty) {
          for (int day in _selectedDays) {
            final nextDate = _getNextDateForDay(day, _selectedTime);
            final notifId = baseId + day;
            notificationIds.add(notifId);
            
            await NotificationService().scheduleNotification(
              id: notifId,
              title: '🕌 ${schedule.title}',
              body: schedule.description.isEmpty ? 'Time for ${schedule.title}' : schedule.description,
              scheduledTime: nextDate,
              isRecurring: true,
            );
          }
        } else {
          notificationIds.add(baseId);
          await NotificationService().scheduleNotification(
            id: baseId,
            title: '🕌 ${schedule.title}',
            body: schedule.description.isEmpty ? 'Time for ${schedule.title}' : schedule.description,
            scheduledTime: scheduleTime,
            isRecurring: false,
          );
        }
      } catch (e) {
        debugPrint('Notification error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ Failed: $e'), backgroundColor: Colors.orange),
          );
        }
      }
    }
    
    if (!mounted) return;
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    
    if (widget.schedule == null) {
      await provider.addSchedule(schedule, notificationIds);
    } else {
      await provider.updateSchedule(widget.index!, schedule, notificationIds);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.schedule == null ? '✅ Schedule created!' : '✅ Schedule updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  DateTime _getNextDateForDay(int weekday, TimeOfDay time) {
    final now = DateTime.now();
    var nextDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    int daysToAdd = (weekday - now.weekday) % 7;
    if (daysToAdd == 0 && (nextDate.isBefore(now) || nextDate.isAtSameMomentAs(now))) {
      daysToAdd = 7;
    }
    return nextDate.add(Duration(days: daysToAdd));
  }
}
