FROM ruby:3.2.2

ENV RAILS_ENV production
RUN mkdir /mangosteen
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
WORKDIR /mangosteen
ADD Gemfile /mangosteen
ADD Gemfile.lock /mangosteen
ADD vendor/cache /mangosteen/vendor/cache
RUN bundle config set  without 'development test'
RUN bundle install

ADD mangosteen-*.tar.gz ./
ENTRYPOINT bundle exec puma
