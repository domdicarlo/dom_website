from django.shortcuts import render
from django.http import HttpResponse

# Create your views here.
def index(request):
  headings = {'main_heading':"Dominic DiCarlo"}
  return render(request, 'blog/index.html', context=headings)