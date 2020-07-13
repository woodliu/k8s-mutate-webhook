# k8s-mutate-webhook

????k8s mutating webhook,????????????????????????????forked?[alex-leonhardt/k8s-mutate-webhook](https://github.com/alex-leonhardt/k8s-mutate-webhook)?

This is a companion to the blog post [Writing a very basic kubernetes mutating admission webhook](https://medium.com/ovni/writing-a-very-basic-kubernetes-mutating-admission-webhook-398dbbcb63ec)  

## ssl/tls

`ssl/` ?????????????,???k8s csr,???kubectl??approve?csr

```
cd ssl/ 
make 
```

## ????

???`ssl`?????`docker`??,????????????:

```
docker build .
```

## ??MutatingWebhookConfiguration

?ssl?????????,??????`MutatingWebhookConfiguration`?`webhooks.clientConfig.caBundle`?

```
cat mutatepodimages.pem | base64 -w0
```

> ?:admission webhook????pem???????????????webook?caBundle??,????????ca??????????????[webhook-create-signed-cert.sh](https://github.com/woodliu/admission-webhook-example/blob/master/deployment/webhook-create-signed-cert.sh)

## ??

?`deploy`?????????,???`kubectl describe pod c7m`??pod??????????

```
kubectl create -f pod.yaml
```


## watcher

useful during devving ... 

```
watcher -watch github.com/alex-leonhardt/k8s-mutate-webhook -run github.com/alex-leonhardt/k8s-mutate-webhook/cmd/
```

## Running in docker-for-mac

```bash
cd ssl && make && cd -
make docker
sed -i '' 's/imagePullPolicy: Always/imagePullPolicy: Never/' deploy/webhook.yaml # use local image
sed -i '' "s/caBundle:.*/caBundle: $(cat ssl/mutatepodimages.pem | base64)/" deploy/webhook.yaml # use local CA 
kubectl label namespace default mutatepodimages=enabled
kubectl apply -f deploy/webhook.yaml

# make sure it's running ...
kubectl get pods
kubectl logs <PDO> --follow

# create example pod to see it working
kubectl apply -f pod.yaml
kubectl get pod c7m -o yaml | grep image: # should be debian
```
