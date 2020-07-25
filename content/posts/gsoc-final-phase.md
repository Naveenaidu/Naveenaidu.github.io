---
title: "GSOC: Handle Nested Languages Overview"
date: 2019-08-30T16:30:06+05:30
draft: false
categories: ["gsoc-2019"]
---
Hiya Everyone!!

This post will explain in brief about the work I had done during the Google
Summer of Code 2019 with [coala](https://coala.io/#/home?lang=Python). For the 
unitiated, my project was to give coala the capability to handle nested 
programming language in a single file.

* The Official link to the project is [here](https://summerofcode.withgoogle.com/projects/#5842650266075136)
* My Proposal for the project is [here](https://docs.google.com/document/d/1lVfE4f2jLzYBKyuxYOpx9G8Gsvil4rV4nWeebtwX8Rg/edit?usp=sharing)

I must say, there is a huge contrast between the project proposal I submitted
and the actual implementation. Though the core concept remains the same but
the implemenation of the various parts are a little different.

**Please do note that this project currently only support the combination
of files having Python and Jinja2. Work is in progress to support other 
languages.** 

So let's dive in to the project and see what all has been done :D

-------------------------------------------------------------------------------

## For the enthusiast

This is for the people who are really interested and want to try this feature(
_I know which most of you aren't xD_). Follow the below steps:

**NOTE: Switch on your virtual env, if you don't want your working coala be
disturpted by this feature from hell xD(reviews are left to be done on this
feature)**

1. Clone [Naveenaidu/coala](https://github.com/Naveenaidu/coala/tree/gsoc-master-handle-nested) 
repository
2. cd into the directory `coala`
3. Run `pip install -r requirement.txt`
4. Install coala using `pip3 install -e .`

Once you have followed the above steps, you now have coala with the feature of
handling nested languages. If you aren't bored already go on to the next section
to find out how you can use this awesome featureee(Shameless praising of 
oneself xD)

## How to activate Nested Language Mode

Use the following file to test this mode:
```python

		def hello():
	{% raw %}{%set x='thanos'%} {{var}} print(  "yo!!") {%set y='he rocks'%}
	{% endraw %}

print("Holaaa Amigos"        )
```

Save the above snippet in a file `test.py`. We'll now go ahead and run
`PEP8Bear`, `Jinja2Bear` and `SpaceConsistencyBear` upon the file.

You can do that by using:
```bash
 coala --handle-nested --languages=python,jinja2 --files=test.py.jj2
--bears=PEP8Bear,Jinja2Bear,SpaceConsistencyBear
```

And tada!!! You'll be prompted by coala to fix the patches as it usually does
in normal execution.

The argument `--handle-nested` is used to specify that the files has a combination
of nested languages. The argument `--languages` is to mention the languages that 
exists in the files. Note that, it is important to mention the `--languages` 
argument since coala cannot auto detect the languages present in the nested 
language file.

Also special care has been taken to keep the signicficant part of the core coala 
untounched by my implementation. No major changes have been done to the way 
coala works. This would help as this is still an experimental features and 
many changes are yet to come.

An asciinema of the working is [here](https://asciinema.org/a/263844)

--------------------------------------------------------------------------------

## How was this done O_O  ???

Whoo! So you do wanna jump along with Alice down the rabbit hole!! Noiceee...

Let's go on in then.

Before we go in lemme give you a very high level view of what happens behind the
scenes.

A source file containing multiple programming languages is loaded up by coala. The original nested file is broken/split into n temporary files, where n is the number of languages present in the original file. Each temporary file only contains the snippets belonging to one language.

These temporary files would then be passed to their respective language bears ( chosen by the user) where the static analysis routines would run. The temporary files after being linted would then be assembled.

The above process creates the illusion that the original file is being linted, but in reality we divide the files into different parts and lint them one by one.

The figure below, would help give a clear picture

![higher_level_view](/assets/images/4-gsoc-overview-nested-languages/high_level_view_handle_nested.jpg)


Now's lets have a look at the different parts of the architecture shall we??

### 1. NlInfoExtractor

NlInfoExtractor is responsible to parse in the cli arguments passed into the coala
during the Nested Language Mode. It extracts all the information from the 
arguments that would help coala in future to properly lint the file.

For eg: If the user passes the following arguments to coala

```bash
coala --handle-nested --languages=python,jinja2 --files=test.py,test2.py
--bears=PEP8Bear,SpaceConsistencyBear,Jinja2Bear 
--settings use_space=True
```

We can get the following information from the above arguments.
```python
{
   'bears': ['PEP8Bear', 'SpaceConsistencyBear', 'Jinja2Bear'],
   'files': ['test.py', 'test2.py'],
   'lang_bear_dict': {
                       'jinja2': ['Jinja2Bear'],
                       'python': ['PEP8Bear', 'SpaceConsistencyBear']
                     },
   'languages': ['python', 'jinja2'],
   'nl_file_info': { 'test.py' : {
                                   'python' : 'test.py_nl_python',
                                   'jinja2' : 'test.py_nl_jinja2'
                                 },
                     'test2.py': {
                                   'python' : 'test2.py_nl_python',
                                   'jinja2' : 'test2.py_nl_jinja2'
                                 }
                   }
}
```

This information is then used to make the coala-sections. In more layman terms, 
coala-sections are basically the information passed to coala to inform about
the type of files and the linters it needs to initialize for the linting of
the file to take place.

The implemenation for this can be found [here](https://github.com/Naveenaidu/coala/blob/27fecf92474b1f5334469c29205fe501aeee04ba/coalib/nestedlib/NlInfoExtractor.py)

-------------------------------------------------------------------------------

### 2. NlCliParsing

NlCliParsing is responsible to create coala-sections from the information passed
from the NlInfoExtractor.

For eg: for the above argument list, it creates the following sections:

```
files = test.py_nl_python
bears = PEP8Bear,SpaceConsistencyBear
handle_nested = True
languages = python,jinja2
file_lang = python
orig_file_name = test.py
```

Also it is important to note that we create one section for each temporary file.
That means for the above arguments we will have 4 coala-sections one for each
temporary file.

The implemenation for this can be found [here](https://github.com/Naveenaidu/coala/blob/20652070886c393f8c4962c2917469c83b46415a/coalib/nestedlib/NlCliParsing.py)

-------------------------------------------------------------------------------

### 3. Parser

Parser is used to segragate the original file into the temporary files.

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

--------------------------------------------------------------------------------

### 4. NlSection

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

Implementation for NlSection is [here](https://github.com/Naveenaidu/coala/commit/c42afec17773349d38b319a0c8a331f1cadaa013)

Implementation for NlSectionPosition is [here](https://github.com/Naveenaidu/coala/commit/dd27757467bb3ef41b03dd076eecf60d792929a5)

-------------------------------------------------------------------------------

### 5. NlCore

NlCore is the interface which connect the normal coala with this nested language
mode. This helps us to keep both of them seperate. All the calls to the different
parts of Nested language arhcitecture are made via the API's provided by this
module.

The implementation for this can be found [here](https://github.com/Naveenaidu/coala/commit/04404d6785b2a56881ee5a6b56e69a3d9fae6082)

Anddd!! That's it folks. That covers up all the important parts that were used
to make this possible. It's really a very high level view of what's actually
been done. I didn't want to go into the details of each and every module because
doing so would have gotten you really confused :P, But if you are interested,
in knowing more about everything -- Feel free to contact me :)

--------------------------------------------------------------------------------

## Challenges

The most challenging part of the project was to come up with a proper 
architecuture that would work. I must confess that I put in more than 2 month of
time before GSoC to try out various possibilites that might make this project a 
reality. I am grateful to all the mentors of coala who kept reviewing my various
approaches even with their busy schedule, without their insights I would never 
have been able to finalise on my proposal.

Since this project deals with the core of the coala, I was pretty scared to get 
into the waters of the huge codebase. But with the constant support of mentors 
and as the time went on, I was about to understand how the different components 
of coala actually pieced together.

Another difficult situation that I faced was during my Third Phase of GSoC. 
The approach I planned out for the assembling of the files did not seem to work.
So I was supposed to come with a new approach in a span of 11 days. I was pretty
pissed and scared ,but apparently it took lesser time than i expected, this 
taught me not overestimate the time and take things one at a time.

And last not the least was about maintaining the coverage while implementing the
details. It took me time to soak in all the coverage, but it all turned out to 
be good.

The entire experience was really fun, though at times there were few hair 
plucking moment but this taught me a lot about how the architectures need to be 
made and how different components needs to be designed to keep track of 
scalability.

I'm also write in another post sharing about my experience in another post. 
Until then!! Naveen is signing offf. Bhubyeee