

```bash
docker build . -t 483026362307.dkr.ecr.us-west-2.amazonaws.com/awsome-fmops:vllm-neuron
```


```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 483026362307.dkr.ecr.us-west-2.amazonaws.com
docker push 483026362307.dkr.ecr.us-west-2.amazonaws.com/awsome-fmops:vllm-neuron
```


kubectl apply -f hf-token-secret.yaml