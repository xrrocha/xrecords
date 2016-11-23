#!/usr/bin/env bash
DIR=$(dirname $0)
TARGET=$DIR/../target
JAR_DIR=$TARGET/xrecords-1.0-SNAPSHOT
MAIN_JAR=$JAR_DIR/xrecords-1.0-SNAPSHOT.jar
MAIN_CLASS="net.xrrocha.xrecords.Main"

if [ ! -d $JAR_DIR ]; then
  (cd $TARGET; unzip xrecords-1.0-SNAPSHOT-release.zip)
fi

CLASSPATH="$CLASSPATH:."
for jar in $DIR/hsqldb/*.jar $JAR_DIR/*.jar $JAR_DIR/lib/*.jar
do
  CLASSPATH="$jar:$CLASSPATH"
done
export CLASSPATH

java $MAIN_CLASS $DIR/csv2db.yaml

