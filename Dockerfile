FROM kong:3.4

USER root
RUN luarocks install xml2lua