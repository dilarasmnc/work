import 'package:flutter/material.dart';
import '../../api/api_client.dart';

class CreateRequestPage extends StatefulWidget {
  final int tutorId;
  const CreateRequestPage({super.key, required this.tutorId});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  List<dynamic> subjects = [];
  int? subjectId;
  DateTime? startDate;
  TimeOfDay? startTime;
  final _duration = TextEditingController(text: "60");
  final _note = TextEditingController();
  bool submitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final res = await apiClient.dio.get("subjects");
      setState(() { subjects = (res.data as List); });
    } catch (e) {
      setState(() { error = "Konular alınamadı."; });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 365)), initialDate: now);
    if (d != null) setState(() => startDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => startTime = t);
  }

  String? _validate() {
    if (subjectId == null) return "Konu seçin.";
    if (startDate == null || startTime == null) return "Tarih ve saat seçin.";
    if (int.tryParse(_duration.text) == null) return "Süre dakika olarak sayı olmalı.";
    return null;
    }

  Future<void> _submit() async {
    final v = _validate();
    if (v != null) { setState(()=>error=v); return; }

    final dt = DateTime(
      startDate!.year, startDate!.month, startDate!.day,
      startTime!.hour, startTime!.minute,
    ).toUtc().toIso8601String();

    setState(() { submitting = true; error = null; });
    try {
      await apiClient.loadToken();
      final data = {
        "tutor_id": widget.tutorId,
        "subject_id": subjectId,
        "start_time": dt,
        "duration_minutes": int.parse(_duration.text),
        "note": _note.text.trim(),
      };
      final res = await apiClient.dio.post("lesson-requests", data: data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Talep gönderildi."))
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() { error = "Talep gönderilemedi."; });
    } finally {
      setState(() { submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ders Talebi Oluştur")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButtonFormField<int>(
            value: subjectId,
            items: subjects.map<DropdownMenuItem<int>>((s) =>
              DropdownMenuItem(value: s["id"] as int, child: Text(s["name"]))
            ).toList(),
            onChanged: (v) => setState(()=>subjectId=v),
            decoration: const InputDecoration(labelText: "Konu"),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _pickDate, child: Text(startDate==null?"Tarih Seç": "${startDate!.day}.${startDate!.month}.${startDate!.year}"))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: _pickTime, child: Text(startTime==null?"Saat Seç": startTime!.format(context)))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _duration, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Süre (dk)")),
          const SizedBox(height: 12),
          TextField(controller: _note, maxLines: 3, decoration: const InputDecoration(labelText: "Not (opsiyonel)")),
          if (error != null) Padding(
            padding: const EdgeInsets.only(top: 8), child: Text(error!, style: const TextStyle(color: Colors.red))
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: submitting ? null : _submit,
              child: submitting ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2))
                                : const Text("Talep Gönder"),
            ),
          ),
        ]),
      ),
    );
  }
}
