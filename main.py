import os
from flask import Flask, render_template, request
import sqlalchemy
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import sessionmaker, declarative_base

# 1. Flaskアプリのインスタンス化
# 'templates'フォルダがmain.pyと同じ階層にある場合、この指定でOK
app = Flask(__name__, template_folder='app/templates') 

# 2. 共通の環境変数を読み込む
db_user = os.environ.get("DB_USER")
db_pass = os.environ.get("DB_PASS")
db_name = os.environ.get("DB_NAME")

# 3. モデル定義の準備
Base = declarative_base()

# 4. モデルクラスを定義
class Human(Base):
    __tablename__ = 'human'
    Id = Column(String(50), primary_key=True)
    Name = Column(String(100))
    Age = Column(Integer)

# 5. 環境変数に応じて接続方法を切り替え
if "INSTANCE_CONNECTION_NAME" in os.environ:
    # GCP (本番) 環境の場合
    instance_connection_name = os.environ.get("INSTANCE_CONNECTION_NAME")
    db_url = sqlalchemy.engine.url.URL.create(
        drivername="mysql+pymysql",
        username=db_user,
        password=db_pass,
        database=db_name,
        query={"unix_socket": f"/cloudsql/{instance_connection_name}"},
    )
else:
    # ローカル環境の場合
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

# 10. アプリを実行
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))