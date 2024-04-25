---
title: UserSort
date: 2024-04-25T10:14:20-0400
draft: false
description: Walking through making a reproducible user sort.
tags:
---

For a project I am working on I need a user sortable field, with some restriction, its value must be a string, and it must be cheap to insert in between two values, and finally it must be reconstructible. The reconstructible part is important, as on saving to disk, the order is not considered, and to add to it, there may be more than one way the user wants to store the order. This seemed fun to try and reinvent the wheel with so here's my attempt.

First we decide on some values to use, my gut reaction was to use A-Z, and assign them values 1-26. This is great, we can start in the middle of the alphabet for the first item, and then it can have items go on either side, choosing the middle value each time.

Enter our first problem, of course 26 values is not enough to represent an arbitrarily large list, and I know that, so lets say we have a case where I would like to insert between two items, but they have a sorting value of J and K. We can add a second char the value, and assume once we've reached the end of one value's string, that it must go before an item with a longer value, but matching to that point, so we simply start the idea over again in the second char, so to insert between J and K, the items sorting value would be JM. This works well for most cases, but quickly falls apart at the very beginning of the list.

Let's say we have items with A and B in the list, but I would like something to go before A. With the current set of rules that is not possible, A is always the first item in the list. We could handle this a few ways, we could change the first items sorting value, but I'm not particularly a fan of this, so an alternative is we make A a special case, A is always the first item, and in the case of and end of string, more As still puts it before, so let's adjust our mapping a bit, currently we have A-Z equal to 1-26, and we implied that the end of a string is equal to 0. So let's shift it we will keep the end of string at 0, A will be -1, and B-Z will now become 1-25.

Let's try it out, now we have our top most item, it somehow has landed at A, and we'd like to insert before, we still quickly run into a problem, if there is no item before A its sorting value is an empty string, which we just defined as having a sorting value of 0, so an item with A is less than 0, oops, that doesn't make much sense, so we have another case to handle.

Let's make the beginning a special case, if there is no item defined, its sorting value is an Infinite series of As, and while we're at it let's do the inverse to the end, we'll set it equal to an infinite series of Zs.

Hokay, let's try again shall we. I have an item A, let's insert before it, we compare our cases, A is -1 and A is -1, so we move to the next char, A is -1 and end of string is 0, fantastic we have a difference, we take our before's sorting value, and append a value to it, we are only considering values we've seen, so we have AA we will append the middle value of our range, in this case M, and end up with AAM. This seems to work, does it ever break down now?

Let's try another case, I have J and JM, fantastic, take it from the top, J and J are equal, next, end of string is zero, and M is greater than zero, perfect, we will pick the middle value, between the two current chars, so end of string is 0, and M is 12, so we get 6, which is G, so our new value is JG, and our current list would be J JG JM. We can use this algorithm to reproduce our order now.

Okay, one more case, J and JB, J and J are equal, end of string and B are not, but we introduce a problem, before we would take the value of the before, 0, and find the middle most point between that an B which is 1, oops, we don't have a letter for that, and end of string necessarily is at the end. We can insert an A then, does this break anything?

If we have JA and JB, and insert in between, funny we actually get J, okay, so we now have JA J and JB, let's try between JA and J. Nth verse same as the first, J and J are equal, nice, A is less than end of string, but they are one apart, so we append an M and get JAM, this seems to fix this case.

I haven't defined to this point what the actual data structure looks like, the nice thing is this idea isn't tied to any structure, it is simply a way to allow arbitrary sorting of values, so whether it's a linked list, a binary search tree, or even a plain array, the way the data is stored doesn't super matter, what matters is that we can reproduce the order each time, and we only have to update the single item's sorting value that we are inserting.

Codified
========

Rules
-----
A = -1

End of String = 0

B-Z = 1-25

The empty item at the beginning of the list is a special case an infinite series of As

The empty item at the end of the list is a special case an infinite series of Zs

Steps for insertion
-------------------
1) Take the before and after case and compare them until they differ

2) Once they differ note the disparity
    - Case more than 1 apart: Take the middle most value between them
    - Case 1 apart, not end of string and B: take the first value to this point and append an M
    - Case 1 apart, end of string and B: Append A to the before value

Steps for Sorting
-----------------
1) Compare until the values differ
2) once they differ whichever LAST value is lower goes first, whether end of string A or B-Z
