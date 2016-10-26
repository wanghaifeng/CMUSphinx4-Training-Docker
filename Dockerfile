FROM alpine
MAINTAINER haifeng <haifeng@cooleval.com>

RUN apk update && apk upgrade
RUN apk add --no-cache bash git openssh autoconf libtool automake g++ make bison python python-dev swig linux-headers ffmpeg
RUN mkdir /cmusphinx
WORKDIR /cmusphinx
# sphinxbase
RUN git clone https://github.com/cmusphinx/sphinxbase.git
WORKDIR /cmusphinx/sphinxbase
RUN ./autogen.sh
RUN make && make install
WORKDIR /cmusphinx
# sphinxtrain
RUN git clone https://github.com/cmusphinx/sphinxtrain.git
WORKDIR /cmusphinx/sphinxtrain
RUN ./autogen.sh
RUN make && make install
WORKDIR /cmusphinx
# pocketsphinx
RUN git clone https://github.com/cmusphinx/pocketsphinx.git
WORKDIR /cmusphinx/pocketsphinx
RUN ./autogen.sh
RUN make && make install
