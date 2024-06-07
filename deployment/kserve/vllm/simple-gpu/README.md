# Simple text generation inference with vLLM on KServe

This short tutorial demonstrates how to deploy vLLM container on KServe.  Refere [kserve](../../README.md) directory for pre-requisits.
Here we deploy `TinyLlama/TinyLlama-1.1B-Chat-v1.0` model on g5 instances.


## Deploy vllm server

```bash
kubectl apply -f vllm.yaml
```

Once you apply, KServe's `InferenceService` will be created as follows:

```
NAME          URL   READY   PREV   LATEST   PREVROLLEDOUTREVISION   LATESTREADYREVISION   AGE
vllm-kserve         False                                                                 1m39s
```

```bash
kubectl get pods -n kserve-test                                                       
```

```
NAME                                                      READY   STATUS    RESTARTS   AGE
vllm-kserve-predictor-00001-deployment-58fc974b7f-jh76w   2/2     Running   0          33m
```



## Deploy make a inferencee
On one terminal 
```bash
INGRESS_GATEWAY_SERVICE=$(kubectl get svc --namespace istio-system --selector="app=istio-ingressgateway" --output jsonpath='{.items[0].metadata.name}')
kubectl port-forward --namespace istio-system svc/${INGRESS_GATEWAY_SERVICE} 8080:80
```

```bash
SERVICE_HOSTNAME=$(kubectl get inferenceservice vllm-kserve -n kserve-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
# start another terminal
export INGRESS_HOST=localhost
export INGRESS_PORT=8080
```

Check if the service is running:

```bash
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models
```

```bash
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/completions -d '{
        "model": "TinyLlama/TinyLlama-1.1B-Chat-v1.0"",
        "prompt": "Say this is a test!",
        "max_tokens": 512,
        "temperature": 0
    }'
```

## Loadtest

