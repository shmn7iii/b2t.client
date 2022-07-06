FROM ruby:2.7.5

RUN apt-get update \
  && apt-get install -y libleveldb-dev \
  && mkdir /b2t

WORKDIR /b2t

COPY Gemfile /b2t/Gemfile
RUN bundle install

EXPOSE 4567

CMD ["ruby", "main.rb"]
