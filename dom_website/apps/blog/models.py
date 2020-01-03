from django.db import models
from django.urls import reverse

# for markup body in blog post
from markupfield.fields import MarkupField
 
# Create your models here.
 
class Blog(models.Model):
   title = models.CharField(max_length=100, unique=True)
   slug = models.SlugField(max_length=100, unique=True)
   body = MarkupField()
   pub_date = models.DateTimeField(db_index=True)
   # can't delete a category if it has posts assigned to it.
   category = models.ForeignKey('blog.Category', on_delete=models.PROTECT)
 
   def __str__(self):
       return self.title
 
   def get_absolute_url(self):
       return reverse('view_blog_post', kwargs={ 'slug': self.slug })
 
class Category(models.Model):
   title = models.CharField(max_length=100, db_index=True)
   slug = models.SlugField(max_length=100, db_index=True)
 
   def __str__(self):
       return self.title
 
   def get_absolute_url(self):
       return reverse('view_blog_category', kwargs={ 'slug': self.slug })