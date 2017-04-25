FROM java:8-jdk
MAINTAINER Diego Pacheco - diego.pacheco.it@gmail.com

RUN apt-get update && apt-get install -y \
	autoconf \
	build-essential \
	dh-autoreconf \
	git \
	libssl-dev \
	libtool \
	python-software-properties \
	redis-server \
	tcl8.5 \
	dos2unix \ 
	unzip

RUN git clone https://github.com/Netflix/dynomite.git

RUN cd /dynomite/ && git checkout tags/v0.5.7-14_whiteSpaceStats 

ADD redis.conf /etc/redis/
ADD start.sh /usr/local/dynomite/
COPY redis_cluster_1.yml /dynomite/conf/redis_cluster_1.yml
COPY redis_cluster_2.yml /dynomite/conf/redis_cluster_2.yml
COPY redis_cluster_3.yml /dynomite/conf/redis_cluster_3.yml
COPY redis_cluster_21.yml /dynomite/conf/redis_cluster_21.yml
COPY redis_cluster_22.yml /dynomite/conf/redis_cluster_22.yml
COPY redis_cluster_23.yml /dynomite/conf/redis_cluster_23.yml

RUN chmod 777 /usr/local/dynomite/start.sh

WORKDIR /dynomite/

RUN autoreconf -fvi \
	&& ./configure --enable-debug=log \
	&& CFLAGS="-ggdb3 -O0" ./configure --enable-debug=log \
	&& make \
	&& make install

EXPOSE 8101
EXPOSE 6379
EXPOSE 22222
EXPOSE 8102

CMD ["/usr/local/dynomite/start.sh"]
