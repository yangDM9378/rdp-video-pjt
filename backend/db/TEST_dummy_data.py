import sqlite3
import random
from datetime import datetime, timedelta

DB_PATH = "rdp.db"

conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()

print("[INFO] Inserting TEST dummy data...")

servers = [
    ("test_server1", "127.0.0.1"),
    ("test_server2", "10.0.0.12"),
    ("test_server3", "127.0.0.1"),
    ("test_server4", "10.0.0.14"),
    ("test_server5", "10.0.0.15")
]

cur.executemany("""
INSERT OR IGNORE INTO rdp_server (name, ip)
VALUES (?, ?)
""", servers)

conn.commit()

base_users = ["admin", "tester", "operator", "guest"]

today = datetime.now()
test_rows = []

for server_name, _ in servers:

    for d in range(7):
        date_obj = today - timedelta(days=d)
        date_str = date_obj.strftime("%Y%m%d")

        file_count = random.randint(3, 4)

        for i in range(file_count):
            user = random.choice(base_users)
            session = f"0x{random.randint(10000,99999)}"
            time_str = f"{random.randint(0,23):02d}{random.randint(0,59):02d}{random.randint(0,59):02d}"

            filename = f"{user}_{date_str}{time_str}{i}.webm"
            filepath = f"{date_str}/{user}/{filename}"

            uploaded = random.randint(0, 1)

            upload_time = None
            if uploaded == 1:
                upload_time = (date_obj + timedelta(minutes=random.randint(1,10))).strftime("%Y%m%d%H%M%S")

            test_rows.append((
                server_name,
                user,
                session,
                date_str,
                filename,
                filepath,
                uploaded,
                time_str,
                upload_time
            ))

cur.executemany("""
INSERT INTO rdp_video
(server_name, user, session, date, filename, filepath, uploaded, time, upload_time)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
""", test_rows)

conn.commit()
conn.close()

print("[INFO] TEST dummy data inserted:", len(test_rows))
