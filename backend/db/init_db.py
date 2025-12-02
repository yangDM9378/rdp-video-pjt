import sqlite3

conn = sqlite3.connect("rdp.db")
cur = conn.cursor()

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
    upload_time TEXT
)
""")

conn.commit()
conn.close()