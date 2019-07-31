#!/bin/bash

# Change workdir
cd /app

# Set up database
mix ecto.setup

# Create release
# mix release

# Start app
# _build/prod/rel/car_pooling_challenge/bin/car_pooling_challenge start

mix phx.server
