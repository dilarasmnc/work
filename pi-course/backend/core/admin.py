from django.contrib import admin

from .models import User, Subject, StudentProfile, TutorProfile, LessonRequest
admin.site.register([User, Subject, StudentProfile, TutorProfile, LessonRequest])

