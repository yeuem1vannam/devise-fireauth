################################################################################
### Build Time #################################################################
################################################################################
FROM ruby:3.1.2 as builder

ENV LANG C.UTF-8

RUN \
  echo "PS1='🐳  \[\033[1;36m\][\$(hostname)] \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]\[\033[0m\]'" >> ~/.bashrc; \
  echo "alias ls='ls --color=auto'" >> ~/.bashrc; \
  echo "alias grep='grep --color=auto'" >> ~/.bashrc

RUN apt-get update -qq && apt-get install -y \
  apt-transport-https ca-certificates gnupg2 software-properties-common \
  build-essential graphviz curl wget vim \
  default-mysql-client \
  && \
  rm -rf /var/lib/apt/lists/*

RUN echo "gem: --no-document --no-rdoc --no-ri" >> ~/.gemrc

ENV EDITOR=vim

################################################################################
### Run Time ###################################################################
################################################################################
FROM builder AS runner

LABEL maintainer="phuonglh0420@gmail.com"
LABEL description="Image for Ruby 3"
LABEL manual="Install tools required for project"

ENV BUNDLE_PATH /usr/local/bundle
ENV RAILS_LOG_TO_STDOUT 1

RUN gem install bundler:2.3.18 solargraph:0.45.0

WORKDIR /workspace

CMD ["/bin/sh"]
