#!/usr/bin/env bash

K8S_MASTER=10.12.120.1
NAMESPACE=ds-tensorflow
USER=ds-tensorflow-sa

spark-submit \
--master k8s://https://${K8S_MASTER} \
--deploy-mode cluster \
--name spark-pi \
--class org.apache.spark.examples.SparkPi \
--conf spark.kubernetes.container.image=brainlounge/spark:2.4.0-hadoop-2.6 \
--conf spark.kubernetes.namespace=${NAMESPACE} \
--conf spark.executor.instances=6 \
--conf spark.driver.memory=3g \
--conf spark.kubernetes.authenticate.driver.serviceAccountName=${USER} \
local:///opt/spark/examples/jars/spark-examples_2.11-2.4.0.jar 1000