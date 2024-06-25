FROM elixir:1.13-alpine as dep

WORKDIR /src
ENV MIX_ENV=prod

# To build assets, Rustler
RUN apk add git python3 cargo build-base

COPY mix.exs mix.lock ./
COPY config .
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile


COPY . .

FROM node:16-alpine as web

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets

COPY --from=dep /src .

RUN cd assets && npm run deploy

FROM dep as build

COPY --from=web /priv .

RUN mix deps.clean mime --build
RUN mix assets.deploy
RUN mix release

FROM elixir:1.13-alpine

# To run Rustler build
RUN apk add --no-cache libgcc

ENV HOME=/opt/app
WORKDIR ${HOME}
COPY --from=build /src/_build/prod/rel/memoet ${HOME}
RUN mkdir -p ${HOME} && \
    adduser -s /bin/sh -u 1001 -G root -h ${HOME} -S -D default && \
    chown -R 1001:0 ${HOME}
ENTRYPOINT ["/opt/app/bin/memoet"]
CMD ["start"]
