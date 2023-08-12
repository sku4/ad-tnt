FROM tarantool/tarantool:2.11.0-ubuntu20.04 as tarantool-builder

RUN mkdir -p /usr/share/tarantool/ad

WORKDIR /usr/share/tarantool/ad

COPY .rocks ./.rocks
COPY app ./app
COPY migrations ./migrations
COPY app.lua ./app.lua
COPY init.lua ./init.lua
RUN chown -R tarantool:tarantool /usr/share/tarantool/ad

CMD ["tarantool", "/usr/share/tarantool/ad/init.lua"]
