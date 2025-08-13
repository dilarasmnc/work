import 'package:flutter/material.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/tutors/tutor_list_page.dart';
import 'features/tutors/tutor_detail_page.dart';
import 'features/requests/create_request_page.dart';
import 'features/requests/my_requests_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pi Course',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF3A0CA3)),
      onGenerateRoute: (settings) {
        if (settings.name == "/tutorDetail") {
          final id = settings.arguments as int;
          return MaterialPageRoute(builder: (_) => TutorDetailPage(tutorId: id));
        }
        return null;
      },
      routes: {
        "/": (context) => const LoginPage(),
        "/register": (context) => const RegisterPage(),
        "/tutors": (context) => const TutorListPage(),
        "/createRequest": (context) => const CreateRequestPage(tutorId: 0), // kullanılmıyor (detaydan gidiyoruz)
        "/myRequests": (context) => const MyRequestsPage(),
      },
    );
  }
}
