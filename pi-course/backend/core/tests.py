from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from core.models import Subject

User = get_user_model()

class AuthFlowTests(APITestCase):
    def test_register_login_me(self):
        r = self.client.post("/api/auth/register", {
            "username":"s1","email":"s1@ex.com","password":"Passw0rd!","role":"student"
        }, format="json")
        self.assertEqual(r.status_code, 201)

        r = self.client.post("/api/auth/login", {
            "username":"s1","password":"Passw0rd!"
        }, format="json")
        self.assertEqual(r.status_code, 200)
        access = r.data["access"]

        r = self.client.get("/api/me", HTTP_AUTHORIZATION=f"Bearer {access}")
        self.assertEqual(r.status_code, 200)

class LessonRequestFlowTests(APITestCase):
    def setUp(self):
        self.math = Subject.objects.create(name="Mathematics")
        self.tutor = User.objects.create_user(username="t1", password="Passw0rd!", role="tutor")
        self.student = User.objects.create_user(username="s1", password="Passw0rd!", role="student")

    def login(self, u):
        r = self.client.post("/api/auth/login", {"username":u.username,"password":"Passw0rd!"}, format="json")
        return r.data["access"]

    def test_student_can_create_and_tutor_can_approve(self):
        a_student = self.login(self.student)
        
        r = self.client.post("/api/lesson-requests", {
            "tutor_id": self.tutor.id,
            "subject_id": self.math.id,
            "start_time": "2025-08-15T10:00:00Z",
            "duration_minutes": 60,
            "note": "Konu: limit"
        }, format="json", HTTP_AUTHORIZATION=f"Bearer {a_student}")
        self.assertIn(r.status_code, (201, 200))
        req_id = r.data["id"]

        
        a_tutor = self.login(self.tutor)
        r = self.client.patch(f"/api/lesson-requests/{req_id}", {"status":"approved"}, format="json",
                              HTTP_AUTHORIZATION=f"Bearer {a_tutor}")
        self.assertEqual(r.status_code, 200)
        self.assertEqual(r.data["status"], "approved")

    def test_tutor_cannot_create_request(self):
        a_tutor = self.login(self.tutor)
        r = self.client.post("/api/lesson-requests", {
            "tutor_id": self.tutor.id, "subject_id": self.math.id,
            "start_time": "2025-08-15T10:00:00Z", "duration_minutes": 60
        }, format="json", HTTP_AUTHORIZATION=f"Bearer {a_tutor}")
        self.assertIn(r.status_code, (403, 405))
