import os
from flask import Flask, render_template, request, jsonify
import sqlalchemy
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import sessionmaker, declarative_base
from google.cloud import storage
import datetime
import uuid
import logging

# Cloud Run 環境であれば、認証ファイルのパスを設定
if os.environ.get("APP_ENV") == "cloud_run":
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/secrets/sa-key.json"

# ロギングの基本設定
logging.basicConfig(level=logging.INFO)

# 1. Flaskアプリのインスタンス化
app = Flask(__name__, template_folder='app/templates')
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

# 2. 共通の環境変数を読み込む
db_user = os.environ.get("DB_USER")
db_pass = os.environ.get("DB_PASS")
db_name = os.environ.get("DB_NAME")
BUCKET_NAME = os.environ.get("BUCKET_NAME")
INSTANCE_CONNECTION_NAME = os.environ.get("INSTANCE_CONNECTION_NAME")

# 3. モデル定義の準備
Base = declarative_base()

# 4. モデルクラスを定義
class Human(Base):
    __tablename__ = 'human'
    Id = Column(String(50), primary_key=True)
    Name = Column(String(100))
    Age = Column(Integer)

# 5. 環境変数に応じて接続方法を切り替え
if INSTANCE_CONNECTION_NAME:
    db_url = sqlalchemy.engine.url.URL.create(
        drivername="mysql+pymysql",
        username=db_user,
        password=db_pass,
        database=db_name,
        query={"unix_socket": f"/cloudsql/{INSTANCE_CONNECTION_NAME}"},
    )
else:
    db_host = os.environ.get("DB_HOST")
    db_url = sqlalchemy.engine.url.URL.create(
        drivername="mysql+pymysql",
        username=db_user,
        password=db_pass,
        database=db_name,
        host=db_host
    )

# 6. データベースエンジンを作成
engine = create_engine(db_url)

# 7. テーブルを作成（もし存在しなければ）
Base.metadata.create_all(engine)

# 8. セッションを準備
Session = sessionmaker(bind=engine)

# 9. ルートを定義
@app.route("/")
def index():
    session = Session()
    humans = session.query(Human).all()
    session.close()
    return render_template('index.html', humans=humans)

@app.route("/add", methods=["POST"])
def add_human():
    session = Session()
    try:
        new_human = Human(
            Id=request.form["id"],
            Name=request.form["name"],
            Age=int(request.form["age"])
        )
        session.add(new_human)
        session.commit()
        message = "登録しました！"
    except sqlalchemy.exc.IntegrityError:
        session.rollback()
        message = "すでに登録されています。"
    finally:
        session.close()
    return message

@app.route("/upload", methods=["POST"])
def upload_file():
    if 'pdf_file' not in request.files:
        return jsonify({"error": "ファイルがありません"}), 400

    file = request.files['pdf_file']

    if file.filename == '':
        return jsonify({"error": "ファイルが選択されていません"}), 400

    if file and file.mimetype == 'application/pdf':
        try:
            storage_client = storage.Client()
            bucket = storage_client.bucket(BUCKET_NAME)
            
            unique_filename = f"{uuid.uuid4()}.pdf"
            blob = bucket.blob(unique_filename)

            blob.upload_from_file(file)

            signed_url = blob.generate_signed_url(
                version="v4",
                expiration=datetime.timedelta(minutes=15),
                method="GET",
            )
            
            return jsonify({"message": "アップロード成功！", "url": signed_url})

        except Exception as e:
            # ★★★ エラーログをより確実に出力するように変更 ★★★
            logging.error("An error occurred during upload:", exc_info=True)
            return jsonify({"error": "アップロード中にエラーが発生しました"}), 500
    else:
        return jsonify({"error": "PDFファイルのみアップロード可能です"}), 400

# 10. アプリを実行
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))