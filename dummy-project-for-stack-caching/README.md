# Dummy Project for Stack Caching

When students submit, we will run a `stack build` (as part of `stack test`) on their code. We want to ensure that as much basic stack setup is already done and cached prior to that point to avoid student code unnecessarily timing out.

This project is here entirely to provide a target to build on.

Therefore, **the two most important files here are `stack.yaml` and `package.yaml`.** In `stack.yaml`, set the resolver to the LTS version you will use for questions. (If they don't match, then the student submission will re-download rather than using the cache.) In `package.yaml`, list a generous set of packages you think you might use. (If you use new ones, rebuild the Docker image so students' submissions don't have to be the ones to do the downloads.)