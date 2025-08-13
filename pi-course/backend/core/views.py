from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, response, status, views
from rest_framework.decorators import action
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter

from .models import Subject, LessonRequest
from .serializers import (
    RegisterSerializer, UserSerializer, MeUpdateSerializer,
    SubjectSerializer, TutorListSerializer, LessonRequestSerializer
)
from .permissions import IsStudent, IsTutor

User = get_user_model()

# Auth
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

# Me
class MeView(views.APIView):
    def get(self, request):
        return response.Response(UserSerializer(request.user).data)

    def patch(self, request):
        ser = MeUpdateSerializer(data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        data = ser.validated_data
        if request.user.role == User.STUDENT:
            prof = request.user.student_profile
            if "grade_level" in data: prof.grade_level = data["grade_level"]
            if "bio" in data: prof.bio = data["bio"]
            prof.save()
        else:
            prof = request.user.tutor_profile
            if "bio" in data: prof.bio = data["bio"]
            # subjects güncellemesi ayrı uçta yapılabilir
            prof.save()
        return response.Response({"detail": "Updated"}, status=status.HTTP_200_OK)

# Subjects
class SubjectListView(generics.ListAPIView):
    queryset = Subject.objects.all().order_by("name")
    permission_classes = [permissions.AllowAny]   # public liste
    serializer_class = SubjectSerializer

# Tutors
class TutorListView(generics.ListAPIView):
    queryset = User.objects.filter(role="tutor").select_related()
    permission_classes = [permissions.AllowAny]   # public liste
    serializer_class = TutorListSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = {"tutor_profile__subjects": ["exact"]}
    search_fields = ["username","first_name","last_name","tutor_profile__bio","tutor_profile__subjects__name"]
    ordering_fields = ["tutor_profile__rating","username"]

class TutorDetailView(generics.RetrieveAPIView):
    queryset = User.objects.filter(role="tutor")
    permission_classes = [permissions.AllowAny]
    serializer_class = TutorListSerializer
    lookup_field = "id"

# Lesson Requests
class LessonRequestCreateView(generics.CreateAPIView):
    serializer_class = LessonRequestSerializer
    permission_classes = [IsStudent]
    def perform_create(self, serializer):
        serializer.save(student=self.request.user)

class LessonRequestListView(generics.ListAPIView):
    serializer_class = LessonRequestSerializer
    def get_queryset(self):
        u = self.request.user
        role = u.role
        qs = LessonRequest.objects.all()
        status_param = self.request.query_params.get("status")
        if role == "student":
            qs = qs.filter(student=u)
        else:
            qs = qs.filter(tutor=u)
        if status_param:
            qs = qs.filter(status=status_param)
        return qs.select_related("student","tutor","subject")

class LessonRequestUpdateView(generics.UpdateAPIView):
    serializer_class = LessonRequestSerializer
    queryset = LessonRequest.objects.all()
    def partial_update(self, request, *args, **kwargs):
        obj = self.get_object()
        if request.user.role != "tutor" or obj.tutor != request.user:
            return response.Response(status=status.HTTP_403_FORBIDDEN)
        new_status = request.data.get("status")
        if new_status not in ["approved","rejected"]:
            return response.Response({"detail": "status must be approved|rejected"}, status=400)
        obj.status = new_status
        obj.save()
        return response.Response(LessonRequestSerializer(obj).data)
