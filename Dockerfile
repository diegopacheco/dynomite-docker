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

RUN mkdir /dynomite-0.5.7/ &&  cd /dynomite-0.5.7/ && git clone https://github.com/Netflix/dynomite.git
RUN cd /dynomite-0.5.7/dynomite/ && git checkout tags/v0.5.7-14_whiteSpaceStats

RUN mkdir /dynomite-0.5.8/ &&  cd /dynomite-0.5.8/ && git clone https://github.com/Netflix/dynomite.git
RUN cd /dynomite-0.5.8/dynomite/ && git checkout tags/v0.5.8-5_HgetallLocalRack

RUN mkdir /dynomite-0.5.9/ &&  cd /dynomite-0.5.9/ && git clone https://github.com/Netflix/dynomite.git
RUN cd /dynomite-0.5.9/dynomite/ && git checkout tags/v0.5.9-2_ProxyCloseFix

RUN mkdir /dynomite-0.6.0/ &&  cd /dynomite-0.6.0/ && git clone https://github.com/Netflix/dynomite.git
RUN cd /dynomite-0.6.0/dynomite/ && git checkout tags/v0.6.0

ADD redis.conf /etc/redis/
ADD redis-mac.conf /etc/redis/
ADD start.sh /usr/local/dynomite/
RUN mkdir /dynomite/ && mkdir /dynomite/conf/
COPY redis_cluster_1.yml /dynomite/conf/redis_cluster_1.yml
COPY redis_cluster_2.yml /dynomite/conf/redis_cluster_2.yml
COPY redis_cluster_3.yml /dynomite/conf/redis_cluster_3.yml
COPY redis_cluster_21.yml /dynomite/conf/redis_cluster_21.yml
COPY redis_cluster_22.yml /dynomite/conf/redis_cluster_22.yml
COPY redis_cluster_23.yml /dynomite/conf/redis_cluster_23.yml
COPY redis_cluster_6S1.yml /dynomite/conf/redis_cluster_6S1.yml
COPY redis_cluster_6S2.yml /dynomite/conf/redis_cluster_6S2.yml
COPY redis_cluster_6S3.yml /dynomite/conf/redis_cluster_6S3.yml
COPY redis_cluster_6S4.yml /dynomite/conf/redis_cluster_6S4.yml
COPY redis_cluster_6S5.yml /dynomite/conf/redis_cluster_6S5.yml
COPY redis_cluster_6S6.yml /dynomite/conf/redis_cluster_6S6.yml

RUN chmod 777 /usr/local/dynomite/start.sh

WORKDIR /dynomite-0.5.7/dynomite/
RUN autoreconf -fvi \
	&& ./configure --enable-debug=log \
	&& CFLAGS="-ggdb3 -O0" ./configure --enable-debug=log \
	&& make \
	&& make install

WORKDIR /dynomite-0.5.8/dynomite/
RUN autoreconf -fvi \
		&& ./configure --enable-debug=log \
		&& CFLAGS="-ggdb3 -O0" ./configure --enable-debug=log \
		&& make \
		&& make install

WORKDIR /dynomite-0.5.9/dynomite/
RUN autoreconf -fvi \
		&& ./configure --enable-debug=log \
		&& CFLAGS="-ggdb3 -O0" ./configure --enable-debug=log \
		&& make \
		&& make install

WORKDIR /dynomite-0.6.0/dynomite/
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
