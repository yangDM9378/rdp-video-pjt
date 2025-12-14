import sqlite3

DB_PATH = "rdp.db"

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS rdp_server (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    ip TEXT
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS rdp_video (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    server_name TEXT,
    user TEXT,
    session TEXT,
    date TEXT,
    filename TEXT,
    filepath TEXT,
    uploaded INTEGER,
    time TEXT,
    end_time TEXT,
    upload_time TEXT
)
""")

conn.commit()
conn.close()

print("[INFO] Database initialized successfully.")
