FROM bitwalker/alpine-elixir:1.9.0

# This Dockerfile is optimized for go binaries, change it as much as necessary
# for your language of choice.

EXPOSE 9091

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

RUN mkdir /app
COPY . /app
WORKDIR /app

ENV MIX_ENV=prod
RUN mix deps.get
RUN mix deps.compile
RUN mix compile

RUN mix release

ENTRYPOINT [ "_build/prod/rel/car_pooling_challenge/bin/car_pooling_challenge", "start"]
