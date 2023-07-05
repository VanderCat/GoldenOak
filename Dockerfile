FROM archlinux:base-devel

#Settings
EXPOSE 9090/tcp
EXPOSE 9090/udp

# Setup dependencies
RUN pacman -Sy --noconfirm lua luarocks git
RUN luarocks install lapis
RUN luarocks install http

# Copy projdir
WORKDIR /app
COPY . .
VOLUME [ "/data" ]

# Run
WORKDIR /app/src
CMD ["lapis", "server"]