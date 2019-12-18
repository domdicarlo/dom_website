from django.shortcuts import render, get_object_or_404
from django.http import HttpResponse 
from blog.models import Blog, Category
from django.views import generic
from django.utils import timezone


# Create your views here.
 
# class IndexView(generic.ListView):
#     """
#     Index to look at last five blog posts
#     """
#     # the name of the template file to serve
#     template_name = 'blog/index.html'
#     # what to call the context to reference in template
#     context_object_name = 'categori
#     # what model to grab a list of 
#     model = Category
                
        
        
def index(request):
  return render(request, 'blog/index2.html')


def view_post(request, slug):   
    """
    Look at one post
    """
    blog_post = get_object_or_404(Blog, slug=slug)

    return render(request, 'blog/view_post.html', {'post': blog_post})


def view_category(request, slug):
    """
    Look at posts in a given category
    """
    category = get_object_or_404(Category, slug=slug)
    return render(request, 'blog/view_category.html', {
        'category': category,
        'posts': Blog.objects.filter(category=category)[:5]
    })