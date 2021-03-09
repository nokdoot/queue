FROM nokdoot/alpine-perl:latest

RUN mkdir app

COPY cpanfile cpanfile.snapshot queue.pl /app/

WORKDIR app

RUN echo $PATH

RUN carton install && \
    ls -al


CMD perl queue.pl
