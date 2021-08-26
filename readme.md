# PrairieLearn Haskell Docker Image

This is a (minor) modification of Mattox Beckman's Docker Image for Haskell auto-grading in [PrairieLearn](https://prairielearn.readthedocs.io/).

Most of what is here is specifically for constructing the Docker image. However, the subfolder `haskell-grader` is intended to be placed under your PrairieLearn course's `serverFilesCourse` folder to be used as the external grader system for a course. Documentation on how to use it is in [`haskell-grader/README.md`](./haskell-grader/README.md).

# Quick Guide to Setting Up the Docker Image

Ensure that `Dockerfile` lists the LTS version you want to use
in your questions. These need to match to avoid timeouts during
student submissions.

To be safe, also update `dummy-project-for-stack-caching/stack.yaml` with the same LTS version.

Next, update `dummy-project-for-stack-caching/package.yaml`
to add any modules you want Haskell / Stack to have access to
to the dependencies list.

Finally, set up the Docker repository you want to push to on [Docker Hub](https://hub.docker.com/). We assume below that it is named `haskell-prairielearn` under your Docker ID.

If this is set up correctly, you can then run:

```
docker build . -t <your-docker-id>/haskell-prairielearn:latest
docker push <your-docker-id>/haskell-prairielearn:latest
```

You can run this with `./redeploy.sh <your-docker-id>` (or set your ID as the default in that file and just run `./redeploy.sh`).

# Configuring the Haskell Autograder

To set up the Haskell Autograder, you'll want to start by understanding
[autograders in
PrairieLearn](https://prairielearn.readthedocs.io/en/latest/externalGrading/).
Crucially, you\'ll need two pieces to get started:

1.  A Docker image in which to run the autograder.
2.  The autograder program itself (and associated questions!).

## The Docker Image

You will want to set up your docker image and [share
it](https://docs.docker.com/get-started/04_sharing_app/) somewhere easy
to access it (or use Mattox\'s at
<https://hub.docker.com/r/mattox/haskell-prairielearn> or Steve\'s at
<https://hub.docker.com/r/cswolf/haskell-prairielearn>.

Among other things you may want to customize is the LTS version. That\'s
the line like `ENV LTS=lts-17.9` in the Dockerfile. **Ensure this is the
same as the LTS version used in your questions.** To decide which
version you\'ll use, you may want to check the [Stackage
server](https://www.stackage.org/) for correspondence with GHC version.
To be safe, ensure that `dummy-project-for-stack-caching/stack.yaml`
refers to the same LTS version.

Additionally, configure the
`dummy-project-for-stack-caching/package.yaml` file to ensure that the
docker image, when built, will download and cache everything needed for
builds for your questions over the term or students\' submissions will
timeout. (This isn\'t too hard to update between major assessments.)

### Building and pushing the Docker image

If you\'re using someone else\'s docker image, you can skip this step
entirely... but you also couldn\'t have done various of the basic docker
configuration above.

If you are making your own docker image:

-   Make yourself an account on [Docker Hub](https://hub.docker.com).
    Create a *public* repository there. We\'ll assume it is named
    `haskell-prairielearn`. (For its full name, it will be prefaced by
    your docker ID.)

-   Once you have everything configured for your Docker image (above),
    go into its directory and run the following (replacing
    `<your-docker-id>` with your actual docker ID, like cswolf or
    mattox):

    ``` bash
    docker build . -t <your-docker-id>/haskell-prairielearn:latest
    ```

    That will likely take a **long** time, particularly the `stack test`
    stage (which installs all the desired Haskell packages).

-   Push your docker image to the hub:

    ``` bash
    docker push <your-docker-id>/haskell-prairielearn:latest
    ```

Congrats! You now have a Docker image you can reference in PrairieLearn
to set up your external autograder! (Caution: PrairieLearn\'s sync page
has a button you need to press manually to actually pull the Docker
image for use the first time you use it!)

## The Autograder

PrairieLearn makes it easy for your autograder to live in your course
under the `serverFilesCourse`, which gives you some customizability
within the constraints of the Docker image.

Details on the autograder are in [`haskell-grader/README.md`](haskell-grader/README.md).
