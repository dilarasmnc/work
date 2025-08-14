# Pi Course — Backend API & Flutter Mobile (Implemented Parts)

## Proje Özeti
Bu proje, Pi Course için öğrencilerin eğitmenleri bulup ders talebi oluşturabileceği bir **MVP backend API** ve temel mobil istemciyi içerir.
Backend **Django REST Framework**, mobil istemci **Flutter** ile geliştirilmiştir.

---

## Backend (Django + DRF)

### Uygulanan Özellikler
- Role-based kullanıcı modeli (`student` / `tutor`)
- Subject modeli
- TutorProfile: `bio`, `hourly_rate`, `rating`, `subjects`
- StudentProfile: `grade_level`
- LessonRequest: `student`, `tutor`, `subject`, `start_time`, `duration_minutes`, `note`, `status`, `created_at`
- JWT authentication (SimpleJWT)
- Rol bazlı izinler
- Filtreleme, arama, sıralama, sayfalama
- Swagger/OpenAPI dokümantasyonu (`/api/docs`)
- Seed komutu: 3–5 tutor, 2–3 subject, 1–2 student
- Minimum testler: auth, izin, talep akışı

**API Uç Noktaları**
| Method | URL | Açıklama |
|--------|-----|----------|
| POST | `/api/auth/register` | Kullanıcı kaydı |
| POST | `/api/auth/login` | JWT login |
| GET | `/api/me` | Profil verisi |
| PATCH | `/api/me` | Profil güncelleme |
| GET | `/api/subjects` | Subject listesi |
| GET | `/api/tutors?subject=<id>&ordering=-rating&search=<q>` | Eğitmen listesi |
| GET | `/api/tutors/{id}` | Eğitmen detayı |
| POST | `/api/lesson-requests` | Ders talebi oluşturma |
| GET | `/api/lesson-requests?role=...&status=...` | Talep listesi |
| PATCH | `/api/lesson-requests/{id}` | Talebi onay/ret |

---

## Mobil (Flutter)

### Uygulanan Özellikler
- Giriş (username/password ile JWT login)
- Kayıt (rol seçimi ile)
- Token saklama (`flutter_secure_storage`)
- Eğitmen Listesi (arama + sıralama)
- Eğitmen Detayı
- Ders Talebi Oluşturma (subject, tarih/saat, süre, not)
- Taleplerim (öğrenci görünümü)
- Taleplerim (eğitmen görünümü, onay/ret)
- Temel boş/loading/hata durumları

**Mobil Navigasyon**
- `/` → LoginPage
- `/register` → RegisterPage
- `/tutors` → TutorListPage
- `/tutorDetail` → TutorDetailPage
- `/myRequests` → MyRequestsPage

---

## Kurulum

### Backend
```bash
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install django djangorestframework django-filter djangorestframework-simplejwt drf-spectacular

python manage.py makemigrations
python manage.py migrate
python manage.py seed_demo
python manage.py runserver
```

### Mobil
```bash
cd mobile
flutter pub get
flutter run
```

**Android emülatör için:** Base URL `http://10.0.2.2:8000/api/`  
`ALLOWED_HOSTS` içinde `10.0.2.2` eklenmeli, `AndroidManifest.xml` içinde `usesCleartextTraffic="true"` olmalı.

---

## Demo Hesaplar
- Student: `student1` / `Pass!`
- Tutor: `tutor1` / `Pass!`
