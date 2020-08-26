# k8s-mutate-webhook

This is a companion to the blog post [Writing a very basic kubernetes mutating admission webhook](https://medium.com/ovni/writing-a-very-basic-kubernetes-mutating-admission-webhook-398dbbcb63ec)  

## ssl/tls

`ssl/` will generate certificates for webhook，use the command below to create certificates and csr. Then use `kubectl get csr` to get the created csr, and use `kubectl approve csr xxx` to approve the csr.

```shell
cd ssl/ 
make 
```

## build

Copy the `ssl` foler above and the generated ELF `mutatepodimages` to a folder, then build a docker image:

```shell
docker build .
```

Dockerfile is:

```shell
# cat Dockerfile
FROM alpine

WORKDIR /app
COPY mutatepodimages .
COPY ssl ssl
CMD ["/app/mutatepodimages"]
```

> You can create a secret to hold the certificates rather than copy it to the image. See [webhook-create-signed-cert.sh](https://github.com/woodliu/admission-webhook-example/blob/master/deployment/webhook-create-signed-cert.sh)

## MutatingWebhookConfiguration

Set the ca generated above to`MutatingWebhookConfiguration.webhooks.clientConfig.caBundle`

```
cat mutatepodimages.pem | base64 -w0
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
