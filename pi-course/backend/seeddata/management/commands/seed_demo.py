from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from core.models import Subject, TutorProfile, StudentProfile

class Command(BaseCommand):
    help = "Demo subject/tutor/student verisi oluşturur."

    def handle(self, *args, **kwargs):
        User = get_user_model()

        # Dersler (Türkçe)
        matematik, _ = Subject.objects.get_or_create(name="Matematik")
        fizik, _     = Subject.objects.get_or_create(name="Fizik")
        tarih, _     = Subject.objects.get_or_create(name="Tarih")

        # Eğitmenler (Türkçe biyografi + puan)
        tutors = [
            ("ogretmen1", "Eğitmen", 4.7, [matematik, fizik]),
            ("ogretmen2", "Fizik eğitmeni", 4.9, [fizik, tarih]),
            ("ogretmen3", "Matematik Eğitmeni", 4.5, [matematik, tarih]),
        ]

        for username, bio, rating, subjects in tutors:
            u, created = User.objects.get_or_create(username=username, defaults={"role": "tutor"})
            if created:
                u.set_password("Pass")
                u.save()
            tp, _ = TutorProfile.objects.get_or_create(user=u)
            tp.bio = bio
            tp.rating = rating
            tp.save()
            tp.subjects.set(subjects)

        # Öğrenciler (Türkçe seviye)
        for i in range(1, 3):
            u, created = User.objects.get_or_create(username=f"ogrenci{i}", defaults={"role": "student"})
            if created:
                u.set_password("Pass")
                u.save()
            sp, _ = StudentProfile.objects.get_or_create(user=u)
            sp.grade_level = "11. sınıf"
            sp.bio = "Deneme öğrenci"
            sp.save()

        self.stdout.write(self.style.SUCCESS("Seed demo verisi."))
