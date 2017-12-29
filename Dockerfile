FROM debian:jessie

# java
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu/ precise main" > /etc/apt/sources.list.d/java.list && \
    echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# java, python, ruby, php
RUN apt-get update && \
    apt-get -y install curl python python-setuptools ruby php5-cli php5-curl oracle-java8-installer git ca-certificates make && \
    apt-get clean
RUN curl -LO https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py

# maven
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz && \
    tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.2.2 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/local/bin && \
    rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven

# go
RUN mkdir /goroot /gopath && curl -Ls https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz | tar xzf - -C /goroot --strip-components=1
ENV GOROOT /goroot
ENV GOPATH /gopath

# node
RUN mkdir /nodejs && curl http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x64.tar.gz | tar xzf - -C /nodejs --strip-components=1 && \
    /nodejs/bin/npm install -g uglify-js docco jshint mocha request

ENV PATH $PATH:/nodejs/bin:/goroot/bin:/gopath/bin

ADD . /app

ENV BARRISTER_NODE /app/binds/barrister-js
ENV BARRISTER_RUBY /app/binds/barrister-ruby
ENV BARRISTER_PHP  /app/binds/barrister-php
ENV BARRISTER_JAVA /app/binds/barrister-java

# build barrister
env PYTHONPATH=/app/binds/barrister
env PATH $PATH:/app/binds/barrister/bin
RUN pip install -r /app/binds/barrister/requirements.txt

# build js/node bits
RUN cd /app/binds/barrister-js && \
    make node && \
    npm install && \
    mkdir -p $BARRISTER_NODE/node_modules && \
    ln -f -s $BARRISTER_NODE $BARRISTER_NODE/node_modules/barrister

# build java bits
RUN cd /app/binds/barrister-java && \
    mvn -Dmaven.javadoc.skip=true -Dmaven.test.skip=true install && \
    cd conform && mvn -Dmaven.javadoc.skip=true -Dmaven.test.skip=true package

# ruby deps
RUN apt-get install -y ruby-sinatra

# go deps
RUN mkdir -p /gopath/src/github.com/coopernurse/ && \
    ln -s /app/binds/barrister-go /gopath/src/github.com/coopernurse/barrister-go

WORKDIR /app/binds/barrister
CMD ./run_tests.sh
