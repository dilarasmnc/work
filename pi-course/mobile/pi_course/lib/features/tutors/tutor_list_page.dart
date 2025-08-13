import 'package:flutter/material.dart';
import '../../api/api_client.dart';

class TutorListPage extends StatefulWidget {
  const TutorListPage({super.key});
  @override
  State<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends State<TutorListPage> {
  List<dynamic> tutors = [];
  bool loading = true;
  String? error;

  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch({String? q}) async {
    setState(() { loading = true; error = null; });
    try {
      await apiClient.loadToken();
      final res = await apiClient.dio.get("tutors", queryParameters: {
        if (q != null && q.isNotEmpty) "search": q,
        "ordering": "-tutor_profile__rating"
      });
      final data = res.data;
      setState(() {
        tutors = (data is Map && data["results"] != null) ? data["results"] : (data as List);
      });
    } catch (e) {
      setState(() { error = "Liste alınamadı."; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eğitmenler"),
        actions: [
          IconButton(
            onPressed: () async { await apiClient.clearToken(); if (mounted) Navigator.pushReplacementNamed(context, "/"); },
            icon: const Icon(Icons.logout),
            tooltip: "Çıkış",
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(hintText: "Ara (ad/bio/konu)", border: OutlineInputBorder()),
                    onSubmitted: (v) => _fetch(q: v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _fetch(q: _searchCtrl.text), child: const Text("Ara")),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : (error != null)
                    ? Center(child: Text(error!))
                    : ListView.separated(
                        itemCount: tutors.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final t = tutors[i];
                          final profile = t["tutor_profile"] ?? {};
                          final bio = profile["bio"] ?? "";
                          final rating = profile["rating"]?.toString() ?? "-";
                          return ListTile(
                            title: Text(t["username"] ?? "İsimsiz"),
                            subtitle: Text(bio),
                            trailing: Text("⭐ $rating"),
                            onTap: () {
                                final id = t["id"] as int;
                                Navigator.pushNamed(context, "/tutorDetail", arguments: id);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
