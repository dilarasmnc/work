import 'package:flutter/material.dart';
import '../../api/api_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await apiClient.dio.post("auth/login", data: {
        "username": _usernameCtrl.text.trim(),
        "password": _passwordCtrl.text,
      });
      final access = res.data["access"];
      if (access == null) throw Exception("Token yok");
      await apiClient.setToken(access);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/tutors");
    } catch (e) {
      setState(() { _error = "Giriş başarısız. Bilgileri kontrol edin."; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giriş")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: "Kullanıcı Adı"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Şifre"),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Giriş"),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showDemoInfo(context),
              child: const Text("Demo bilgileri"),
            ),
            // ↓↓↓ EKLENEN KISIM
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("Hesabın yok mu? Kayıt ol"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDemoInfo(BuildContext context) {
    showDialog(context: context, builder: (_) {
      return AlertDialog(
        title: const Text("Demo Hesap"),
        content: const Text("Örn: kullanıcı adı: student1\nşifre: Pass!"),
        actions: [ TextButton(onPressed: () => Navigator.pop(context), child: const Text("Kapat")) ],
      );
    });
  }
}
