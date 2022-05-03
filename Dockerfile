FROM shwestrick/mpl:latest

# install smlpkg
RUN git clone https://github.com/diku-dk/smlpkg.git /root/smlpkg \
    && cd /root/smlpkg \
    && git fetch --all \
    && git checkout v0.1.5 \
    && MLCOMP=mlton make clean all
ENV PATH /root/smlpkg/src/:$PATH

RUN mkdir /root/mpl-tutorial
WORKDIR /root/mpl-tutorial
