import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("POSTGRES_DB", "traineedb")
DB_USER = os.getenv("POSTGRES_USER", "trainee")
DB_PASS = os.getenv("POSTGRES_PASSWORD", "traineepassword")

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )

@app.route("/")
def home():
    return jsonify({
        "status": "success",
        "message": "IT Infrastructure & DevOps Trainee Stack is operational",
        "service": "Flask Application Backend"
    }), 200

@app.route("/db-check")
def db_check():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        db_version = cur.fetchone()[0]
        cur.close()
        conn.close()
        return jsonify({
            "database": "connected",
            "version": db_version
        }), 200
    except Exception as e:
        return jsonify({
            "database": "error",
            "details": str(e)
        }), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
