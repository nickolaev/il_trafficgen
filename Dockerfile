FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

ARG trafficgen_root=/opt/il_trafficgen

RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install wget curl build-essential \
		git unzip libpcap0.8-dev gcc libjson-c-dev make libc6 libc6-dev \
		g++-multilib libcurl4-openssl-dev libssl-dev msr-tools libnuma-dev \
		libconfig-dev

COPY ./ ${trafficgen_root}
RUN cd ${trafficgen_root} && git submodule update --init
RUN source ${trafficgen_root}/setenv.sh && \
    make -C ${trafficgen_root}/dpdk/ \
            config T=x86_64-native-linuxapp-gcc O=x86_64-native-linuxapp-gcc && \
    sed -ri 's,(CONFIG_RTE_EAL_IGB_UIO=).*,\1n,' ${trafficgen_root}/dpdk/x86_64-native-linuxapp-gcc/.config && \
    sed -ri 's,(CONFIG_RTE_KNI_KMOD=).*,\1n,' ${trafficgen_root}/dpdk/x86_64-native-linuxapp-gcc/.config && \
    sed -ri 's,(CONFIG_RTE_LIBRTE_KNI=).*,\1n,' ${trafficgen_root}/dpdk/x86_64-native-linuxapp-gcc/.config && \
    sed -ri 's,(CONFIG_RTE_LIBRTE_PMD_KNI=).*,\1n,' ${trafficgen_root}/dpdk/x86_64-native-linuxapp-gcc/.config && \
    make -C ${trafficgen_root}/dpdk/x86_64-native-linuxapp-gcc -j 4

RUN source ${trafficgen_root}/setenv.sh && \
    make -C ${trafficgen_root}/pktgen -j2