FROM ruby:2.7
RUN gem install bundler -v 1.16.5
WORKDIR /app/casteml
#COPY . /app/casteml
COPY Gemfile Gemfile.lock casteml.gemspec /app/casteml/
RUN mkdir -p lib/casteml
COPY ./lib/casteml/version.rb /app/casteml/lib/casteml/
RUN bash -l -c 'bundle install'
#COPY . /app/casteml/




