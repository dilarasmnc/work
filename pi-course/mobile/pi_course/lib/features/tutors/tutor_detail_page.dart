import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../requests/create_request_page.dart';

class TutorDetailPage extends StatefulWidget {
  final int tutorId;
  const TutorDetailPage({super.key, required this.tutorId});

  @override
  State<TutorDetailPage> createState() => _TutorDetailPageState();
}

class _TutorDetailPageState extends State<TutorDetailPage> {
  Map<String, dynamic>? tutor;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await apiClient.dio.get("tutors/${widget.tutorId}");
      setState(() { tutor = res.data; });
    } catch (e) {
      setState(() { error = "Detay alınamadı."; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tutor;
    return Scaffold(
      appBar: AppBar(title: const Text("Eğitmen Detayı")),
      body: loading ? const Center(child: CircularProgressIndicator())
           : (error != null) ? Center(child: Text(error!))
           : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t?["username"] ?? "-", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(t?["tutor_profile"]?["bio"] ?? ""),
                const SizedBox(height: 8),
                Wrap(spacing: 10, children: [
                  Text("⭐ ${t?["tutor_profile"]?["rating"] ?? "-"}"),
                  if (t?["tutor_profile"]?["hourly_rate"] != null)
                    Text("₺ ${t?["tutor_profile"]["hourly_rate"]} / saat"),
                ]),
                const Divider(height: 24),
                Text("Dersler:", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: List<Widget>.from(
                    (t?["tutor_profile"]?["subjects"] ?? []).map<Widget>(
                      (s) => Chip(label: Text(s["name"] ?? "-"))
                    )
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CreateRequestPage(tutorId: widget.tutorId),
                      ));
                    },
                    child: const Text("Ders Talep Et"),
                  ),
                )
              ]),
            ),
    );
  }
}
