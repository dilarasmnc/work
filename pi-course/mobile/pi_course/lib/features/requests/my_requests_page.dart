import 'package:flutter/material.dart';
import '../../api/api_client.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});
  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  String role = "student"; // me'den gelsin
  String? statusFilter;     // null=hepsi
  List<dynamic> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await apiClient.loadToken();
    try {
      final me = await apiClient.dio.get("me");
      role = me.data["role"] ?? "student";
    } catch (_) {}
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { loading = true; error = null; });
    try {
      final qp = {"role": role, if (statusFilter!=null) "status": statusFilter};
      final res = await apiClient.dio.get("lesson-requests", queryParameters: qp);
      final data = res.data;
      setState(() {
        items = (data is Map && data["results"] != null) ? data["results"] : (data as List);
      });
    } catch (e) {
      setState(() { error = "Liste alınamadı."; });
    } finally {
      setState(() { loading = false; });
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await apiClient.dio.patch("lesson-requests/$id", data: {"status": newStatus});
      _fetch();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncellenemedi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Taleplerim")),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            DropdownButton<String>(
              value: statusFilter,
              hint: const Text("Durum"),
              items: const [
                DropdownMenuItem(value: "pending", child: Text("Bekliyor")),
                DropdownMenuItem(value: "approved", child: Text("Onaylandı")),
                DropdownMenuItem(value: "rejected", child: Text("Reddedildi")),
              ],
              onChanged: (v){ setState(()=>statusFilter=v); _fetch(); },
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text("Öğrenci"),
              selected: role=="student",
              onSelected: (_) { setState(()=>role="student"); _fetch(); },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text("Eğitmen"),
              selected: role=="tutor",
              onSelected: (_) { setState(()=>role="tutor"); _fetch(); },
            ),
          ]),
        ),
        Expanded(
          child: loading ? const Center(child: CircularProgressIndicator())
           : (error!=null) ? Center(child: Text(error!))
           : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height:1),
              itemBuilder: (context, i){
                final it = items[i];
                final status = it["status"];
                final when = (it["start_time"] ?? "").toString().replaceAll("T", " ").replaceAll("Z", "");
                return ListTile(
                  title: Text("Ders: ${it["subject"] ?? ""}  •  $when"),
                  subtitle: Text("Öğrenci #${it["student"]}  •  Eğitmen #${it["tutor"]}"),
                  trailing: role=="tutor" && status=="pending"
                    ? Wrap(spacing: 8, children: [
                        OutlinedButton(onPressed: ()=>_updateStatus(it["id"], "rejected"), child: const Text("Reddet")),
                        ElevatedButton(onPressed: ()=>_updateStatus(it["id"], "approved"), child: const Text("Onayla")),
                      ])
                    : Text(status.toString()),
                );
              },
            ),
        )
      ]),
    );
  }
}
