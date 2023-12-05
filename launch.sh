#!/bin/bash

set -x

FORGE_VERSION=1.19.2-43.3.5
cd /data

if ! [[ "$EULA" = "false" ]] || grep -i true eula.txt; then
	echo "eula=true" > eula.txt
else
	echo "You must accept the EULA by in the container settings."
	exit 9
fi

if ! [[ -f 'CRF-Server-Files-6.43.zip' ]]; then
	rm -fr config kubejs libraries mods *SERVER.zip forge*.jar
	curl -Lo 'CRF-Server-Files-6.43.zip' 'https://edge.forgecdn.net/files/4928/280/CRF-Server-Files-6.43.zip' && unzip -u -o 'CRF-Server-Files-6.43.zip' -d /data
  curl -Lo forge-installer.jar 'https://maven.minecraftforge.net/net/minecraftforge/forge/'${FORGE_VERSION}'/forge-'${FORGE_VERSION}'-installer.jar'
	java -jar forge-installer.jar --installServer && rm -f forge-installer.jar
fi

if [[ -n "$JVM_OPTS" ]]; then
	sed -i '/-Xm[s,x]/d' user_jvm_args.txt
	for j in ${JVM_OPTS}; do sed -i '$a\'$j'' user_jvm_args.txt; done
fi
if [[ -n "$MOTD" ]]; then
    sed -i "/motd\s*=/ c motd=$MOTD" /data/server.properties
fi
if [[ -n "$LEVEL" ]]; then
    sed -i "/level-name\s*=/ c level-name=$LEVEL" /data/server.properties
fi
if [[ -n "$OPS" ]]; then
    echo $OPS | awk -v RS=, '{print}' > ops.txt
fi
if [[ -n "$ALLOWLIST" ]]; then
    echo $ALLOWLIST | awk -v RS=, '{print}' > white-list.txt
fi

sed -i 's/server-port.*/server-port=25565/g' server.properties

chmod 755 run.sh

./run.sh