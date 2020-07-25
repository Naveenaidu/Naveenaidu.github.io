---
title: "GSOC: Phase 1 Overview"
date: 2019-06-28T16:30:06+05:30
draft: false
categories: ["gsoc-2019"]
---

Hiya crawlers!

This post will cover my learnings of phase 1 of GSoC with coala. As I explained
in my previous GSOC post about the 4 different phases of my project. For the
uninitatied, the project for my GSoC is to add functionality into coala which
would enable it into `Linting files that have nested languages`.

I divided my project into 4 phases:
* Information Gathering
* Segregating the nested file
* Linting the file
* Assembling

For the newbies here, I highly suggest that you read the previous blog about
the project. If you do feel lazy(when don't we :P) to go through the 700+ lines 
of content, I better give you a very high level view of the project:

## A higher level view of the implementation

A source file containing multiple programming languages is loaded up by coala. 
The original nested file is broken/split into `n` temporary files, where n is
the number of languages present in the original file. Each temporary file only
contains the snippets belonging to one language. 

These temporary files would then be passed to their respective language bears 
( _chosen by the user_) where the static analysis routines would run. The
temporary files after being linted would then be assembled. 
The above process creates the illusion that the original file is being linted, 
but in reality we divide the files into different parts and lint them one by 
one.

The figure below, would help give a clear picture

![higher_level_view](/images/4-gsoc-overview-nested-languages/high_level_view_handle_nested.jpg)

If it's hard for you imagine - Think of it something like this, You are a 
factory worker working in a ball manufacturing company. This company produces
two kind of balls - One `red` and one `blue`.  Both these balls have differnt 
properties and shapes. This factory is equipped with a Big `Ball Production Unit`,
but alas - This unit produces both red and blue balls at the same time.As a 
result of which after one production cycle the output box/carton has mixture of 
`Red` and `Blue` balls.

Your taks as a factory worker is to segregate the `red` and `blue` balls into 
different boxes and take these to the `Ball Testers`. Since the balls have
different properties, you cannot take it to the same testers, hence you will
take the Blue Ball to the `Blue Ball Validator` and Red Ball to the 
`Red Ball Validator`.

These Validator validates the quality of the ball and discard the bad quality 
balls and replaces them with a nice quality balls.

Once the Validation is done, You now have two boxes - One for Red balls with no
defects and one for Blue Balls with no defects. Your final job is to combine
both these boxes. (Factory worker thinks: _Duh! Why did you make me segregate 
the ball in the first place -.-_)

The above analogy is what my work is all about. The factory worker is the 
coala tool. The ball tester are the coala bears/linters. The carton/box is the
nested file that had mixture of languages(_read balls_). The nested file(_the 
box with the mixture of two different color balls_) is seperated into two different
section where each section contains the lines of only one language(_read, the 
red and blue ball from the box is segeragated into `red box` and `Blue Box`_). 

These sections that contain purely only one language(boxes with only one single 
color ball) is then taken to the respective coala-bears(_read `Ball validators`_),
these coala bears validates the files and fixes the file if any change needs to be 
done (_Note: coala-bears are linters_) and then send theses validated/linted
file back to coala(the  two box with proper quality balls are handed back to
factory worker). coala then finally mereges back both the files (_read: Factory
worker then puts both the validated balls back into the same box_)

-------------------------------------------------------------------------------

## Phase 1 Work

In Phase 1 of GSoC I decided to first handle the task of `segregating the nested
file` into different sections. My aim in this phase was to be able to
identify the sections that belongs to a particular language. 

Let's understand what this means:

Suppose we have the following nested file which has both Jinja and Python.

```python
import sys
import thanos

x = "hulk"

{% raw %}{% if x == "hulk" %}
	print("Thanos is meat") 
{% else %}
	print("Bhubyee! Earth")
{% endif %}{% endraw %}

if(y is not x):
	"Some gibberish"
```

As you see in the above snippet - We have a mixture of `Python` and `Jinja`. And
if we have to be able to lint these files seprately i.e if we have to convert
the above file into `pure jinja` and `pure python` file, we would need to 
maintain the information about what lines belong to which language.

We do this, by divinding the files into different section. I call these section
`NlSection` which stand for `Nested language Section`.

The above snippet can be divided into three sections:

1. __Section 1__

```python
import sys
import thanos

x = hulk

```

2. __Section 2__
{% raw %}
```
{% if x == "hulk" %}
	print("Thanos is meat") 
{% else %}
	print("Bhubyee! Earth")
{% endif %}
```
{% endraw %}


3. __Section 3__

```python
if(y is not x):
	print("Some gibberish")
```

Divinding the files into various sections, makes the work of linting the file
easier. What we do after creating sections is that we group the sections on the
basis of their language and then make `pure python` and a `pure jinja` file.
These pure files would then be passed upon to the respective language bears.

_NOTE: Creating sections does mean that we create new sections rather I mean that
we maintain the infromation such as the `line_start` and `line_end` in the 
original file._ 

### NlSection

Each of the section we made in the nested language file is termed as `NlSection`.
A NlSection has the following information:
* Start line number of the section
* Start column number of the section
* End line number of the section
* End column number of the section
* The path of the nestedfile

The start and end information of the sections are inturn a `NlSectionPosition`
object. 

That means NlSection comprises of two object `start` and `end`, and these objects
are of the type `NlSectionPosition`.

NlSectionPosition has better functionality to store line numbers and column
numbers along with proper testing.

### Parsers

Parsers are responsible to take in the input nested file and split out the 
`NlSections` list. For my case - I have as of now only made a parser that can for
the combination of `Jinja` and `Python`. I named it as `PyJinjaParser`.

This parser can take in a nested Jinja and Python file and emit out the list
of NlSections of Python and Jinja.

The above explanation sums up pretty much my work for Phase 1. I wish to write
about this in more details - but time bounds me :/

------------------------------------------------------------------------------

[__The Link to Phase 1 PR__](https://github.com/Naveenaidu/coala/pull/2)

For now, I would refer you to the above PR link, I have seen to that it is well
documented. Thanks to my mentor Virresh - I did write enough tests to give
me peace of mind that the work until now works.

-----------------------------------------------------------------------------

P.S:

I have __passed__ Phase 1. Hurrah!. I must thank my mentor for his valuable
feedback and his patient reviews. Honestly I myself was skeptical of making it
this far. You know, handling OMP, Exams and GSOC. But everything did work out
fine. My final exam would be on 3rd of July. It's python - So it's pretty chill.

So unofficially - My exams have already ended today :P

Also, the community bonding of Open mainframe is done too. Stipend of both
GSoC and OMP have been released. It kinda feel good. My Second salary :)

Ahaaahhh! I gotta go now - How I wish I can write more. Alas! that's it for
now my dear bots. Saynora until next post :)
