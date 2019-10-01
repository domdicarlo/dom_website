from django.db import models

# Create your models here.
class blogPost(models.Model):
  """
  A blogpost
  """
  def __str__(self):
    return self.title

  question_text = models.CharField(max_length=50)
  pub_date = models.DateTimeField('date published')