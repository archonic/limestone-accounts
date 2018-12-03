FROM ruby:2.5.3-alpine

RUN apk update && apk add build-base git nodejs python2 postgresql-dev postgresql-client graphicsmagick --no-cache yarn

# Make busybox and pry work nicely for large output
ENV PAGER='more'

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN set -ex; \
  yarn install --frozen-lockfile --production; \
  yarn cache clean;

COPY . .

# Make compiled assets a part of image. Aides in production deploy and testing.
ENV SECRET_KEY_BASE juststarttheserver
ENV DATABASE_URL postgresql://just@start:5432/theserver
ENV REDIS_BASE_URL redis://please:6379/0
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Replace this with yourself
LABEL maintainer="Joshua Flark <joshuajmark@gmail.com>"

CMD puma -C config/puma.rb
