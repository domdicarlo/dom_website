from django.urls import path

from . import views

app_name = 'blog'

urlpatterns = [
   #path('', views.IndexView.as_view(), name='index'),
    path('', views.index, name='index'),
    path('view/<str:slug>/', views.view_post, name='view_post'),
    path('category/<str:slug>/', views.view_category, name='view_category'),
]
