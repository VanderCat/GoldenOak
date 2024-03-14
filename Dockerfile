FROM archlinux:base-devel

#Settings
EXPOSE 9090/tcp
EXPOSE 9090/udp

# Setup dependencies
RUN pacman -Sy --noconfirm lua luarocks git

RUN luarocks install lapis
RUN luarocks install http

RUN luarocks install tableshape

RUN pacman -Sy --noconfirm libsodium
RUN luarocks install luasodium

RUN pacman -Sy --noconfirm mongo-c-driver icu
RUN luarocks install lua-mongo

#RUN luarocks install lil

RUN luarocks install luafilesystem

# Copy projdir
WORKDIR /app
COPY . .
VOLUME [ "/data" ]

# Run
WORKDIR /app/src
CMD ["lapis", "server"]