from django.shortcuts import render
from django.views import generic

# Create your views here.
def index(request):
  return render(request, 'text_game/index.html')
