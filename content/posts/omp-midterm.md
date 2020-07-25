---
title: "OMP: MidTerm Overview"
date: 2019-08-02T16:30:06+05:30
draft: false
categories: ["omp-2019"]
---

Heya Everyone,

This post is dedicated for my work done until now at Open Mainframe Project. For
the unititated, I got selected for the Open Mainframe Project as an intern
for the project `Implementation of Boost.Context Module on s390x".`

## What are all the weird terms on the above line?

I promise you that I'll explain all of the above term in details, when I do get
some free time. For now, I'll restrict myself to descrbing these terms in as 
simple manner as I can.

### Boost

The C++ programmers would be accustomed to what Boost is. Please do correct me
if I make any mistaked here :P

So Boost is a set of libraries for the C++ programming language that provide 
support for tasks and structures such as linear algebra, pseudorandom number 
generation, multithreading, image processing, regular expressions, and unit 
testing.

### Boost.Context

Context is one of the multitasking library of the Boost. `boost.context` is a
foundational library that provides a sort of cooperative multitasking on a 
single thread. It provides the means to suspend the current execution path and
to transfer the control, thereby permitting another function/fiber to run
on the current thread.

These aim to provide the same functionality that `yield` keyword provides in 
python. In more layman words, It provides the programmer the means to jump
from one function to another at his will.

That means, if you have two functions: 

```c
void f1(){
	print("f1 : Line 1\n");
	print("f1 : Line 2\n");
	print("f1 : Line 3\n");

	jump(f2)

	print("\n")
	print("f1 : Line 4\n");
	print("f1 : Line 5\n");
}
```

```c
void f2(){
	print("\n")
	print("f2 : Line 1\n");
	print("f2 : Line 2\n");

	jump(f1)

	print("f2 : Line 4\n");
	print("f2 : Line 5\n");
}
```

To maintain the sanity of the users, let's assume that `boost.context` has a
function called as  `jump` which allows user to shift from one function to 
another.

Assume that I called the function `f1()`, We will get the following output:

```
f1 : Line 1
f1 : Line 2
f1 : Line 3

f2 : Line 1
f2 : Line 2

f1 : Line 4
f1 : Line 5
```

If you observe carefully, after printing the `f1 : Line 3` of the function 
`f1()` we switched to function `f2()` and we start executing it.

Everything looks normal until now, where's the twist? You asked for it... :
After printing the `f2 : Line 2`, when we encountered the `jump(f1)` statement
we jumped back to function `f1()` and the function `f1()` continued from where
we jumpedddd..

Isn't it amazingggg. We were able to suspend a function and jump to a new 
function and then when we resumed the function, it resumed from the point it got
suspened. Unlike the normal execution, where if you call a function, it executes
again from the beginning.

Honestly, I was mind blown, when I knew this was possible in `C++`. I knew we
could do it in `python` (Well, we can do anything with it :P), But being able
to do something like this in C++, is pretty cool. This opens up a lot of 
avenues.

I won't drag on now :see_no_evil:,

TL;DR --> context is a library from Boost, that gives the programmer the ability
to suspend and resume a context/state of a program whenever he wants to.

### s390x Architecture

Linux on IBM Z (or Linux on Z for short, and previously Linux on z Systems) is 
the collective term for the Linux operating system compiled to run on IBM 
mainframes, especially IBM Z and IBM LinuxONE servers.

Beginning with Linux kernel version 4.1 released in early 2015, Linux on Z is
only available as a 64-bit operating system compatible with z/Architecture 
mainframes.

Previously Linux on Z was also available as a 31-bit operating system compatible 
with older model mainframes introduced prior to 2000's z900 model. However, the 
newer 64-bit Linux kernel and 64-bit Linux on Z distributions are still backward 
compatible with applications compiled for 31-bit Linux on Z. Historically the 
Linux kernel architecture designations were "s390" and "s390x" to distinguish 
between the 31-bit and 64-bit Linux on Z kernels respectively, but "s390" now 
also refers generally to the one Linux on Z kernel architecture.

*P.S: I copied the text from the Wikipedia, I wasn't able to come up with
better description about s390x*

## So what's your entire internship about?

Boost.context does not work on s390x architecture. The reason for this that 
boost.context is completely depended on the assembly language files for that
architecture.

It mainly has three assembly files for all archs:


1. jump_s390x_sysv_elf_gas.S    : context switch between two fibers/fiber_contexts
2. make_s390x_sysv_elf_gas.S   : prepares stack for the first invocation
3. ontop_s390x_sysv_elf_gas.S  : execute function on top of a fiber/fiber_context

I'll explain what each of the files do in further posts.

My tasks until Mid terms evals has been:

1. Implmenet s390x arch in Boost.Context build file
2. Implement make_context file
3. Implement jump_context  file

The PR has been created for the work [at](https://github.com/boostorg/context/pull/111)

