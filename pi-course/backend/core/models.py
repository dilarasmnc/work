# core/models.py
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone  

class User(AbstractUser):
    STUDENT = "student"
    TUTOR = "tutor"
    ROLE_CHOICES = [(STUDENT, "Student"), (TUTOR, "Tutor")]
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default=STUDENT)

class Subject(models.Model):
    name = models.CharField(max_length=100, unique=True)
    def __str__(self): return self.name

class StudentProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="student_profile")
    grade_level = models.CharField(max_length=50, blank=True, default="")
    bio = models.TextField(blank=True, default="")

class TutorProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="tutor_profile")
    bio = models.TextField(blank=True, default="")
    subjects = models.ManyToManyField(Subject, related_name="tutors", blank=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0)
    hourly_rate = models.PositiveIntegerField(default=0)

class LessonRequest(models.Model):
    PENDING, APPROVED, REJECTED = "pending", "approved", "rejected"
    STATUS_CHOICES = [(PENDING,"Pending"), (APPROVED,"Approved"), (REJECTED,"Rejected")]

    student = models.ForeignKey(User, on_delete=models.CASCADE, related_name="lesson_requests_made")
    tutor   = models.ForeignKey(User, on_delete=models.CASCADE, related_name="lesson_requests_received")
    subject = models.ForeignKey(Subject, on_delete=models.PROTECT)

    
    start_time = models.DateTimeField(default=timezone.now)
    duration_minutes = models.PositiveIntegerField(default=60)
    note = models.TextField(blank=True, default="")

    message = models.TextField(blank=True, default="")
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=PENDING)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]
