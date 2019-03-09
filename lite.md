---
title: SingleVMなConcourse 5.0をAWSにSpot Instanceで構築する
tags: ["Concourse CI", "Concourse Lite, "BOSH", "AWS", "Terraform"]
categories: ["Dev", "CI", "ConcourseCI"]
---

Concourse [5.0.0](https://concourse-ci.org/download.html#v500)がリリースされたので、
Single VMな[Concourse Lite](https://github.com/concourse/concourse-bosh-deployment#lite-lite-directorless-deployment)をAWSに構築してみます。

Concourse Liteだと1VMに全てのコンポーネント(ATC, TSA, Garden, PostgreSQL)を同梱するため、使用量に応じてworkerをスケールアウトすることは出来ません。安く運用できるので、とりあえず始めたい場合には良い選択肢ではないかと思います。

> 以下の作業はMacまたはLinuxのみ対応しています。

まずはTerraformでConcourseをデプロイするためのVPC、EIP、Security Group、IAMを作成します。

templateを要したので`git clone`で取得してください。

```
git clone --recursive https://github.com/making/concourse-lite-on-aws.git
cd concourse-lite-on-aws
```

`terraform.tfvars.sample`をコピーして`terraform.tfvars`を作成してください。

```
cp terraform.tfvars.sample terraform.tfvars
```

`env_id`は環境名を示す好きな文字列を、`access_key`と`secret_key`はAWSのリソースを作成するためのAWSの認証情報を設定してください。


```
env_id = "changeme"
access_key = "changeme"
secret_key = "changeme"
region = "ap-northeast-1"
availability_zones = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
```