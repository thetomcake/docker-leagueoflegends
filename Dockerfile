FROM ubuntu:18.04 as amd64

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install tar git unzip dh-autoreconf flex bison curl && \
    mkdir /wine && \
    cd /wine && \
    git clone -b v3.13.1 https://github.com/wine-staging/wine-staging.git && \
    git clone https://github.com/wine-mirror/wine && \
    cd wine && \
    git checkout 25cc380b8ed41652b135657ef7651beef2f20ae4 && \
    curl https://bugs.winehq.org/attachment.cgi?id=61944 > wesiepatches1.zip && \
    unzip wesiepatches1.zip && \
    curl 'https://bugs.winehq.org/attachment.cgi?id=61968&action=diff&context=patch&collapsed=&headers=1&format=raw' > wesiepatch.patch && \
    cd .. && \
    ./wine-staging/patches/patchinstall.sh DESTDIR=./wine --all -W ntdll-futex-condition-var && \
    cd wine && \
    patch -p1 < 0003-Pretend-to-have-a-wow64-dll.patch && \
    patch -p1 < 0006-Refactor-LdrInitializeThunk.patch && \
    patch -p1 < 0007-Refactor-RtlCreateUserThread-into-NtCreateThreadEx.patch && \
    patch -p1 < 0009-Refactor-__wine_syscall_dispatcher-for-i386.patch && \
    patch -p1 < wesiepatch.patch && \
    cd .. && \
    apt-get -y build-dep wine && \
    mkdir lol-esync-3.13.1-64 && \
    mkdir lol-esync-3.13.1-32 && \
    cd lol-esync-3.13.1-64 && \
    ../wine/configure --enable-win64 && \
    make -j8

FROM i386/ubntu:18.04 as i386
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y install tar git unzip dh-autoreconf flex bison && \
    apt-get -y build-dep wine && \
    cd /wine/lol-esync-3.13.1-32 && \
    ../wine/configure --with-win64=../lol-esync-3.13.1-64 && \
    make -j8 && \
    make DESTDIR=/wine/build -j8 install && \
    cd ../lol-esync-3.13.1-64 && \
    make DESTDIR=/wine/build -j8 install
