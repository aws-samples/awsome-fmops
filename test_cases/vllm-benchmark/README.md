
```
export INGRESS_HOST=localhost
export INGRESS_PORT=8080
SERVICE_HOSTNAME=$(kubectl get inferenceservice vllm-kserve -n kserve-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models

curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/completions -d '{
        "model": "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
        "prompt": "Hi!",
        "max_tokens": 40,
        "temperature": 0.1
    }'
~/go/bin/hey -z 30s -c 5 -m POST -host ${SERVICE_HOSTNAME}  http://${INGRESS_HOST}:${INGRESS_PORT}/v1/completions -d '{
        "model": "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
        "prompt": "Hi!",
        "max_tokens": 40,
        "temperature": 0.1
    }'
```