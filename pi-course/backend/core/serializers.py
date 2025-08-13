from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Subject, StudentProfile, TutorProfile, LessonRequest

User = get_user_model()

class SubjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Subject
        fields = ["id", "name"]

class StudentProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudentProfile
        fields = ["grade_level", "bio"]

class TutorProfileSerializer(serializers.ModelSerializer):
    subjects = SubjectSerializer(many=True, read_only=True)
    subject_ids = serializers.PrimaryKeyRelatedField(
        many=True, write_only=True, source="subjects", queryset=Subject.objects.all()
    )
    class Meta:
        model = TutorProfile
        fields = ["bio", "hourly_rate", "rating", "subjects", "subject_ids"]

class UserSerializer(serializers.ModelSerializer):
    student_profile = StudentProfileSerializer(read_only=True)
    tutor_profile = TutorProfileSerializer(read_only=True)
    class Meta:
        model = User
        fields = ["id","username","email","first_name","last_name","role","student_profile","tutor_profile"]

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    class Meta:
        model = User
        fields = ["username","email","password","role"]
    def create(self, validated_data):
        role = validated_data.pop("role", User.STUDENT)
        user = User.objects.create_user(**validated_data, role=role)
        if role == User.STUDENT:
            StudentProfile.objects.create(user=user)
        else:
            TutorProfile.objects.create(user=user)
        return user

class MeUpdateSerializer(serializers.Serializer):
    grade_level = serializers.CharField(required=False, allow_blank=True)
    bio = serializers.CharField(required=False, allow_blank=True)

class TutorListSerializer(serializers.ModelSerializer):
    tutor_profile = TutorProfileSerializer(read_only=True)
    class Meta:
        model = User
        fields = ["id","username","first_name","last_name","role","tutor_profile"]

class LessonRequestSerializer(serializers.ModelSerializer):
    tutor_id = serializers.PrimaryKeyRelatedField(source="tutor", queryset=User.objects.filter(role="tutor"), write_only=True)
    subject_id = serializers.PrimaryKeyRelatedField(source="subject", queryset=Subject.objects.all(), write_only=True)

    class Meta:
        model = LessonRequest
        fields = [
            "id",
            "student",
            "tutor","tutor_id",
            "subject","subject_id",
            "start_time","duration_minutes","note","message",
            "status","created_at",
        ]
        read_only_fields = ["student","tutor","subject","status","created_at"]

    def create(self, validated_data):
        tutor = validated_data.pop("tutor")
        subject = validated_data.pop("subject")
        return LessonRequest.objects.create(tutor=tutor, subject=subject, **validated_data)
