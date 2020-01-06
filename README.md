# Dominic DiCarlo's Website 2019

## About

I am working on a django based website, with my blog, resume, and general info about me for employers and the curious.

The website at branch master is currently hosted at [domdicarlo.com](https://domdicarlo.com), or [dominicdicarlo.azurewebsites.com](https://dominicdicarlo.azurewebsites.com)

Because I am on a free tier, the site is not always on. It takes around 15 seconds to load, but after that refershing is quite quick.


## Progress

### October-November 2019 - Inception

I wanted to work on web development skills, so I started this website as a small project. I had a really busy school schedule at this time,
so I didn't get to work on this much at all. After doing some research and deciding my goals, I went with a Django backend. I wanted to work with Python since I was going to make this my go-to coding interview language. I also read Django is a good framework to learn to nail down good organization habits for a project. I bought a cheap course on Udemy for Full stack Django web dev, but honestly you can just use free resources that are just as good/better. The django tutorial for a polls app found [here](https://docs.djangoproject.com/en/3.0/intro/tutorial01/#creating-the-polls-app) is very insightful and got me running pretty quickly. 

Since I am more of a CSS tinkerer then designer and creator, I went with a template found here: https://colorlib.com/wp/template/jackson/. I would like to make my own from-scratch design at some point, but I wanted to get something up asap that still looks nice. I made the homepage its own django app, since I liked the organization this allowed me to do (I could keep homepage static files all in one place), and I didn't know what other app package I would include it in. I will make my blog its own app, with making eventual 'apps' for my game and portfolio. 

### December 2019

I got the first real thing on my webpage going - my blog. I started a blog in Summer 2018 since I had some philosophical ideas I was itching to put down on paper and really articulate properly. I managed to do so, but I didn't manage to sustain the blog going forward. It would be nice to continue it some time, as I still do have ideas. Life has just been a bit busy as of late, as I try to keep up with UChicago and find my way through life moving forward. Perhaps once things settle down some more I can get to writing again.

To get my blog online, I did some free style django-python coding. I created a model called Blog in my models.py file in the Blog app. This was a simple model with just a few fields for title, publication date, text body, and a slug field for creating a post's url. I also added a category field that I may use later to organize blog posts, as well as eventually changed text body to a markup text field using [django-markupfield](https://github.com/jamesturk/django-markupfield). By doing this, I can write my blog posts in markdown and render the markdown directly in a django template. This provides a simple and easy way to create basic and pretty blog posts. 

I write the blog posts in markdown, and then simply copy and paste my work into a new post by using the Django admin site to add a new blog post to my blog post model. Posts are stored in a MySQL database, and I am using a free remote one at remotemysql.com .

My blog consists of two possible views, the index - where I simply list all posts and their links and dates, and view_post - where a template is used to load the blog post into a pretty page. Both of these were quite simple to code in Django. The index view simply gets the top 5 latest posts from the blog model, and then uses this to render the index page and populate it with post names. The post view uses the slug to build a url (which is what a slug is in web-dev). It then populates the blog template with the blog data. Overall, these work simply but it was nice to get acquainted with Django in this way.

