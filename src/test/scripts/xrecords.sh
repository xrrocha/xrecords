#!/bin/bash
DIR="$(dirname $0)"

CLASSPATH="$CLASSPATH:."
for jar in $DIR/lib/*.jar
do
    CLASSPATH="$CLASSPATH:$jar"
done
export CLASSPATH

java net.xrrocha.xrecords.Main $*
