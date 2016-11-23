#!/bin/bash
DIR=$(dirname $0)

java -cp $DIR/hsqldb-2.3.4.jar org.hsqldb.util.DatabaseManagerSwing
