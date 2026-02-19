さくらのクラウドでDockerイメージ生成用サーバーを立ち上げる際に使えるTerraformコードです。
1. Terraformをインストールします。
1. さくらのクラウドホームで、アクセスキーを発行し、terraform.tfvars.exampleに反映します。作成するサーバーの管理者パスワードも入力します。
1. terraform.tfvars.exampleのファイル名称をterraform.tfvarsに変更します。
1. 以下のコマンドを実行します。exeの実行を蹴られる場合は許可してください。
```
Terraform init
Terraform plan
Terraform apply
```
サーバーが構築されます。サーバーログインに使用する秘密鍵は、.sshフォルダに作成されます。
Terraform destroyできるよう、コンテナレジストリは作成していません。
