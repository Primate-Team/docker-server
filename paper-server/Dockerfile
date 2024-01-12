# --- [ Use Java base image ] ---

FROM eclipse-temurin:17-jre AS build
RUN apt-get update -y && apt-get install -y curl jq

LABEL Samsonium <tdesu@vk.com>

ARG version=1.20.1

# --- [ Download PaperMC server jar ] ---

WORKDIR /opt/minecraft
COPY ./get-paper.sh /
RUN chmod +x /get-paper.sh
RUN /get-paper.sh ${version}

# --- [ Run environment ] ---

FROM eclipse-temurin:17-jre AS runtime
ARG TARGETARCH

# Install gosu
RUN set -eux; \
    apt-get update; \
    apt-get install -y gosu; \
    rm -rf /var/lib/apt/lists/*; \
    gosu nobody true

# Set working directory
WORKDIR /data

# Obtain jar from build
COPY --from=build /opt/minecraft/paper.jar /opt/minecraft/paper.jar

# Install and start RCON
ARG RCON_VER=1.6.0
ADD https://github.com/itzg/rcon-cli/releases/download/${RCON_VER}/rcon-cli_${RCON_VER}_linux_${TARGETARCH}.tar.gz /tmp/rcon-cli.tgz
RUN tar -x -C /usr/local/bin -f /tmp/rcon-cli.tgz rcon-cli && \
    rm /tmp/rcon-cli.tgz

# Volume for external data
VOLUME /data

# Expose mc ports
EXPOSE 25565/tcp
EXPOSE 25565/udp
EXPOSE 25575/tcp
EXPOSE 25575/udp

# Set memory size limit
ARG memory_size=1G
ENV MEMORYSIZE=${memory_size}

# Set Java flags
ARG java_flags="-Dlog4j2.formatMsgNoLookups=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=mcflags.emc.gs -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=${java_flags}

# Set PaperMC flags
ARG papermc_flags="--nojline nogui"
ENV PAPERFLAGS=${papermc_flags}

WORKDIR /data

COPY ./docker-entry.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entry.sh

# Entrypoint
ENTRYPOINT [ "/opt/minecraft/docker-entry.sh" ]
