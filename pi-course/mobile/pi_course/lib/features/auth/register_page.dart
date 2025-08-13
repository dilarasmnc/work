import 'package:flutter/material.dart';
import '../../api/api_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = "student";
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      await apiClient.dio.post("auth/register", data: {
        "username": _username.text.trim(),
        "email": _email.text.trim(),
        "password": _password.text,
        "role": _role,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarılı, giriş yapabilirsin."))
      );
      Navigator.pop(context); // login'e dön
    } catch (e) {
      setState(() { _error = "Kayıt başarısız. Alanları kontrol edin."; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _username, decoration: const InputDecoration(labelText: "Kullanıcı Adı")),
          const SizedBox(height: 8),
          TextField(controller: _email, decoration: const InputDecoration(labelText: "E‑posta (opsiyonel)")),
          const SizedBox(height: 8),
          TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: "Şifre")),
          const SizedBox(height: 12),
          Row(children: [
            const Text("Rol: "),
            Expanded(child: RadioListTile(
              value: "student", groupValue: _role, onChanged: (v){ setState(()=>_role="student"); },
              title: const Text("Öğrenci"), contentPadding: EdgeInsets.zero)),
            Expanded(child: RadioListTile(
              value: "tutor", groupValue: _role, onChanged: (v){ setState(()=>_role="tutor"); },
              title: const Text("Eğitmen"), contentPadding: EdgeInsets.zero)),
          ]),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2))
                              : const Text("Kayıt Ol"),
            ),
          ),
        ]),
      ),
    );
  }
}
