# Cloudfront & Lambda@Edge

### Requerimientos para la demo:


| command | version | link |
| ------ | ------ | ------ |
| aws-cli | >= 2.0.0 | https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html |
| terraform | >= 0.12.0 | https://www.terraform.io/downloads.html |



### Clonamos el repositorio

```sh

$ git clone https://github.com/stazdx/demo-cloudfront-lambda-edge.git && cd demo-cloudfront-lambda-edge

```

### Ejecutamos los comandos de terraform

```sh
# Instalamos plugins, providers, ...
$ terraform init

# Validamos la sintaxis
$ terraform validate

# Generamos un plan  previo a la ejecución
$ terraform plan

# Verificamos nuestro plan generado y lo ejecutamos
$ terraform apply -auto-approve
```

Happy coding :smile: !!


