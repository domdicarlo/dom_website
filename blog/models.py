from django.db import models

# Create your models here.
Python
from django.db import models
from django.db.models import permalink

# Create your models here.

class Blog(models.Model):
   title = models.CharField(max_length=100, unique=True)
   slug = models.SlugField(max_length=100, unique=True)
   body = models.TextField()
   posted = models.DateTimeField(db_index=True, auto_now_add=True)
   category = models.ForeignKey('blog.Category')

   def __unicode__(self):
       return '%s' % self.title

   @permalink
   def get_absolute_url(self):
       return ('view_blog_post', None, { 'slug': self.slug })

class Category(models.Model):
   title = models.CharField(max_length=100, db_index=True)
   slug = models.SlugField(max_length=100, db_index=True)

   def __unicode__(self):
       return '%s' % self.title

   @permalink
   def get_absolute_url(self):
       return ('view_blog_category', None, { 'slug': self.slug })
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
	
from django.db import models
from django.db.models import permalink
 
# Create your models here.
 
class Blog(models.Model):
   title = models.CharField(max_length=100, unique=True)
   slug = models.SlugField(max_length=100, unique=True)
   body = models.TextField()
   posted = models.DateTimeField(db_index=True, auto_now_add=True)
   category = models.ForeignKey('blog.Category')
 
   def __unicode__(self):
       return '%s' % self.title
 
   @permalink
   def get_absolute_url(self):
       return ('view_blog_post', None, { 'slug': self.slug })
 
class Category(models.Model):
   title = models.CharField(max_length=100, db_index=True)
   slug = models.SlugField(max_length=100, db_index=True)
 
   def __unicode__(self):
       return '%s' % self.title
 
   @permalink
   def get_absolute_url(self):
       return ('view_blog_category', None, { 'slug': self.slug })