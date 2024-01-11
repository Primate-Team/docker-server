#!/bin/sh
set -e

exec java -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS /opt/minecraft/paper.jar $PAPERFLAGS
