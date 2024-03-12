MODEL_NAME=flowers-sample
INPUT_PATH=sample-data/input.json
export INGRESS_HOST=localhost
export INGRESS_PORT=8082
HOST=$(kubectl get -n kserve-test inferenceservice $MODEL_NAME -o jsonpath='{.status.url}' | cut -d "/" -f 3)
~/go/bin/hey -z 30s -c 50 -m POST -host ${HOST} -D $INPUT_PATH http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/$MODEL_NAME:predict
# ~/go/bin/hey -z 30s -q 50 -m POST -host ${SERVICE_HOSTNAME} -D $INPUT_PATH http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/$MODEL_NAME:predict
