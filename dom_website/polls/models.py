import datetime

from django.db import models
from django.utils import timezone

# Create your models here.
class Question(models.Model):
  """
  A question for the polling app
  """
  def was_published_recently(self):
    now = timezone.now()
    return now >= self.pub_date >= now - datetime.timedelta(days=1)

  def __str__(self):
    return self.question_text

  question_text = models.CharField(max_length=200)
  pub_date = models.DateTimeField('date published')


class Choice(models.Model):
  """
  An answer for the polling app question
  """
  def __str__(self):
    return self.choice_text

  question = models.ForeignKey(Question, on_delete=models.CASCADE)
  choice_text = models.CharField(max_length=200)
  votes = models.IntegerField(default=0)