MODEL_NAME=sklearn-iris
INPUT_PATH=sample-data/input.json
export INGRESS_HOST=localhost
export INGRESS_PORT=8082
HOST=$(kubectl get -n kserve-test inferenceservice $MODEL_NAME -o jsonpath='{.status.url}' | cut -d "/" -f 3)
curl -v -H "Host: ${HOST}" "http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict" -d @./sample-data/iris-input.json
