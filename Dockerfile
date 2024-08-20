FROM registry.access.redhat.com/ubi9/ubi:latest


# UPDATE LTS HERE
# Review https://www.stackage.org/ to compare ghc versions to what's available.
ENV LTS=lts-22.31

# Needed for AWS to properly handle UTF-8
ENV PYTHONIOENCODING=UTF-8

ENV PATH=$PATH:/root/.local/bin:/home/ag/.local/bin

RUN yum -y update

# When using CentOS, also needed:
# RUN yum -y install https://repo.ius.io/ius-release-el7.rpm \
#                    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Install yum libraries, sudo command, Python, curses (for terminal display?)
# AWS utilities, make, and mustache (for variant processing).
# The alternate repos for yum packages may not be necessary any longer.
RUN yum install -y sudo && \
    yum install -y python3 python3-pip && \
    yum install -y ncurses-libs && \
    python3 -m pip install awscli requests && \
    yum install -y make && \
    yum install -y rubygems && \
    gem install mustache

# RUN curl -sSL https://s3.amazonaws.com/download.fpcomplete.com/centos/7/fpco.repo | sudo tee /etc/yum.repos.d/fpco.repo
# RUN yum -y install stack

# ag = autograder, just a username for the account to run grading.
RUN useradd ag

# Install stack
RUN curl -sSL https://get.haskellstack.org/ | sh

# This is the required folder in which PrairieGrade places files.
RUN mkdir /grade

################################################################
# Create a dummy project to force a stack build.

ADD dummy-project-for-stack-caching /tmp/project

RUN ls -l /tmp
RUN chown -R ag /tmp/project

RUN cd /tmp/project \
    && sudo -u ag /usr/local/bin/stack setup --resolver $LTS --install-ghc

# Testing will run a build. A stack build would probably work just as well.
RUN cd /tmp/project \
    && sudo -u ag /usr/local/bin/stack --resolver $LTS test 

# Indicates where stack has installed various items.
RUN cd /tmp/project \
    && sudo -u ag /usr/local/bin/stack --resolver $LTS path

# TODO: not sure why we're removing just the cabal files.
# TODO: can we rm -rf the entire folder?
RUN rm /tmp/project/*.cabal

ADD main.py /
    

