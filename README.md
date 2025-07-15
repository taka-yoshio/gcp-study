# gcp-study

## 概要
- GCP学習

## 現状の目標
- ALBやらVPCやらネットワーク関連  
- 整理

## ローカル開発環境の構築
-  ①rootで`docker-compose up -d --build`を実行
-  ②**http://localhost:8080**

## デプロイ手順

- ①Dockerイメージを作成  
   ※プラットフォームは `linux/amd64` を指定（重要）  
   ※タグ付けも必須（ARにプッシュする際に必要）  

   ```
   docker build --platform=linux/amd64 -t asia-northeast1-docker.pkg.dev/terraform-study-465601/docker-repo/gcp-study-app:latest .
   ```

- ②Artifact Registry（AR）にイメージをプッシュする  

   ```
   docker push asia-northeast1-docker.pkg.dev/terraform-study-465601/docker-repo/gcp-study-app:latest
   ```

- ③取得した `sha256` を変数に更新する（terraform/terraform.tfvars）

- ④**https://yoshio-study.com**

