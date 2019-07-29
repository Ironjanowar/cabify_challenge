FROM bitwalker/alpine-elixir:1.9.0

# This Dockerfile is optimized for go binaries, change it as much as necessary
# for your language of choice.

# RUN apk --no-cache add ca-certificates=20190108-r0 libc6-compat=1.1.19-r10

EXPOSE 9091

ENV MIX_ENV=prod
ENV DATABASE_URL=ecto://postgres:postgres@localhost/car_pooling_challenge

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force

# Install the Phoenix framework itself
RUN mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force

RUN mkdir /app
COPY . /app
WORKDIR /app

ENV SECRET_KEY_BASE="$(mix phx.gen.secret)"
RUN mix deps.get
RUN mix release

ENTRYPOINT [ "/app/entrypoint.sh" ]
