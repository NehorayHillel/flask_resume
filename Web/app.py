from flask import Flask, render_template, request, jsonify
from db import db
from models import Like, Comment  # These are now pointing to "likes_table" and "comment_table"
from datetime import datetime
import os

app = Flask(__name__)

# Get database connection details from environment variables
db_host = os.environ.get('DB_HOST')
db_port = os.environ.get('DB_PORT')
db_user = os.environ.get('DB_USER')
db_password = os.environ.get('DB_PASSWORD')
db_name = os.environ.get('DB_NAME')
db_ssl_mode = os.environ.get('DB_SSL_MODE')

# Construct the database URI
db_uri = f'postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}'
app.config['SQLALCHEMY_DATABASE_URI'] = db_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)

# Ensure database tables exist
with app.app_context():
    try:
        db.create_all()
        print("✅ Database tables created successfully.")
        print(f"Connected to database at {db_host}:{db_port}")
    except Exception as e:
        print(f"⚠️ Error creating tables: {e}")

@app.route("/")
def index():
    like_count = Like.query.count()
    comments = Comment.query.order_by(Comment.timestamp.desc()).all()
    return render_template("index.html", like_count=like_count, comments=comments)

@app.route("/like", methods=["POST"])
def like():
    try:
        new_like = Like()
        db.session.add(new_like)
        db.session.commit()
        like_count = Like.query.count()
        return jsonify({"like_count": like_count})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/comment", methods=["POST"])
def comment():
    text = request.form["comment"]
    if text.strip():
        try:
            new_comment = Comment(text=text)
            db.session.add(new_comment)
            db.session.commit()
            return jsonify({"comment": {"text": new_comment.text, "timestamp": new_comment.timestamp.isoformat()}})
        except Exception as e:
            return jsonify({"error": str(e)}), 500
    return jsonify({"error": "Comment cannot be empty"}), 400

@app.route("/debug")
def debug():
    likes_count = Like.query.count()
    comments = Comment.query.order_by(Comment.timestamp.desc()).all()
    comments_data = [{"id": c.id, "text": c.text, "timestamp": c.timestamp.strftime("%Y-%m-%d %H:%M:%S")} for c in comments]

    # Add connection info for debugging
    connection_info = {
        "db_host": db_host,
        "db_port": db_port,
        "db_name": db_name,
        "db_user": db_user
    }

    return jsonify({
        "like_count": likes_count,
        "comments": comments_data,
        "connection_info": connection_info
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)