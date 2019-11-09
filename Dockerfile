FROM openjdk:8 AS build
RUN groupadd appgroup -g 1000280000
RUN useradd -u 1000280000 -g 1000280000 --no-log-init  -ms /bin/bash janusgraph

ARG server_zip
ADD ${server_zip} /home/janusgraph

ADD healthcheck.py /tmp
RUN chmod -R 777 /tmp/healthcheck.py

RUN export http_proxy=http://28.100.214.167:3128 && \
    export https_proxy=http://28.100.214.167:3128 && \ 
    apt-get update -y && apt-get install -y zip && apt-get install -y python2.7  && \
    apt-get install -y net-tools && \
    apt-get install -y curl 

USER janusgraph
RUN server_base=`basename ${server_zip} .zip` && \
    unzip -q /home/janusgraph/${server_base}.zip -d /home/janusgraph && \
    chmod -R 777 /home/janusgraph/${server_base}/log && \
    chmod -R 777 /home/janusgraph/${server_base}/bin

WORKDIR /home/janusgraph
RUN mkdir log

ENTRYPOINT ["./janusgraph-0.3.2-hadoop2/bin/gremlin-server.sh"]
CMD ["/home/janusgraph/janusgraph-config/gremlin-server.yaml"]