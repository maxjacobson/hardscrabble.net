---
title: "The actions/checkout action has this one weird gotcha"
date: 2026-04-13 17:05
category: programming
---

If you use GitHub Actions, you probably use the [actions/checkout](https://github.com/actions/checkout) action to check out your repository.

Let's say you use it to run tests on pull requests before merging them. The action will check oout the code from your branch, and then run the tests.

What exactly is it checking out?

You might assume that it basically just checks out your branch. Or maybe it checks out the head commit on your branch?

Nope.

It checks out our pull request's "merge ref".

The pull request merge ref is sort of like a branch which GitHub creates automatically for all of your pull requests. It represents what you'd get if you were to merge your PR into the target branch.

For example if we consider this diagram[^1]:

[^1]: Somehow I've made it this far in my blogging life without ever manually creating this classic ASCII diagram showing git branches...

```
  main    my-great-feature-branch
          *
          *
      *   *
      *   *
      * *
      *
      *
      *
      *
      * oldest commit
```

This shows a feature branch with a handful of new commits that are not represented on main. It also shows that, since branching off of main, a few other commits have been made to the main branch which are not represented in the feature branch.

When I open a pull request to merge my great feature branch into main, GitHub automatically creates a _third_ branch which has _all_ of the commits from both branches. And _that's_ what the actions/checkout action checks out.

This is kind of helpful: if your tests pass, you can feel pretty confident that you aren't going to break the main branch if you merge it in.[^2]

[^2]: That is, unless main has changed _again_ since your tests passed.

This is also kind of confusing: if your tests fail, and you try to run the tests locally to see exactly why they're failing, you might find that they pass locally, and now you need to figure out why exactly things are behaving differently locally and in CI. If you find yourself in this scenario, the answer is simple: just rebase your branch on top of main (or merge main into your branch) and then the test should start failing locally too, and you can debug it.

It is possible to configure actions/checkout to just check out the head commit on your pull request's branch. This is a scenario they document in their README: <https://github.com/actions/checkout/tree/v6.0.2?tab=readme-ov-file#checkout-pull-request-head-commit-instead-of-merge-commit>. Doing that would be less surprising, perhaps.
