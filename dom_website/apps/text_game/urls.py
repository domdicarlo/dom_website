from django.urls import path

from . import views

app_name = 'text_game'

urlpatterns = [
    path('', views.index, name='index'),
]
