from django.contrib import admin

# Register your models here.
from django.contrib import admin
from blog.models import Blog, Category
 
admin.site.register(Blog)
admin.site.register(Category)

