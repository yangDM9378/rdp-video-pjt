import sqlite3
import random
from datetime import datetime, timedelta

DB_PATH = "rdp.db"

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

print("[INFO] Inserting TEST dummy data...")

# ===== 서버 3개 =====
servers = [
    ("TEST1", "127.0.0.1"),
    ("TEST2", "10.0.0.12"),
    ("TEST3", "10.0.0.13"),
]

cur.executemany("""
INSERT OR IGNORE INTO rdp_server (name, ip)
VALUES (?, ?)
""", servers)

conn.commit()

users = ["admin", "tester", "operator", "guest"]

today = datetime.now()
test_rows = []

for server_name, _ in servers:
    for d in range(7):  # 최근 7일
        date_obj = today - timedelta(days=d)
        date_dir = date_obj.strftime("%Y%m%d")
        date_db  = date_obj.strftime("%Y-%m-%d")

        file_count = random.randint(3, 5)

        for i in range(file_count):
            user = random.choice(users)
            session = str(random.randint(1, 50))

            start_dt = date_obj.replace(
                hour=random.randint(0, 23),
                minute=random.randint(0, 59),
                second=random.randint(0, 59)
            )

            end_dt = start_dt + timedelta(minutes=random.randint(1, 15))

            filename = start_dt.strftime("%Y%m%d%H%M%S") + f"_session{session}.webm"

            filepath = f"{server_name}/{date_dir}/{user}/{filename}"

            uploaded = random.choice([0, 1])

            upload_time = None
            if uploaded == 1:
                upload_time = (end_dt + timedelta(minutes=1)).strftime("%Y-%m-%d %H:%M:%S")

            test_rows.append((
                server_name,
                user,
                session,
                date_db,
                filename,
                filepath,
                uploaded,
                start_dt.strftime("%Y-%m-%d %H:%M:%S"),
                end_dt.strftime("%Y-%m-%d %H:%M:%S"),
                upload_time
            ))

cur.executemany("""
INSERT INTO rdp_video
(server_name, user, session, date,
 filename, filepath, uploaded,
 time, end_time, upload_time)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
""", test_rows)

conn.commit()
conn.close()

print("[INFO] TEST dummy data inserted:", len(test_rows))
