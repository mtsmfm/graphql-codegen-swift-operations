FROM swift:5.2.3-bionic

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update \
  && apt-get install -y zsh less curl \
  && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs

RUN useradd --create-home --user-group --uid 1000 app
RUN mkdir -p /app /original $BUNDLE_PATH
RUN chown -R app /app /original $BUNDLE_PATH
RUN npm install -g yarn

WORKDIR /app

USER app

ENV SHELL=/bin/zsh HOME=/home/app
