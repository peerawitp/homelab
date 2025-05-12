helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm upgrade --install \
  external-dns external-dns/external-dns \
  --namespace external-dns \
  --create-namespace \
  --version 1.14.5 \
  --values values.yaml
