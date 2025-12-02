import sqlite3

def connect_to_rdpDB():
    conn = sqlite3.connect('..\db\rdp.db')
    conn.row_factory = sqlite3.Row
    return conn

def rdpDB_query(sql, args=()):
    conn = connect_to_rdpDB()
    cur = conn.cursor()
    cur.execute(sql, args)

    sql_upper = sql.strip().upper()
    if sql_upper.startswith("SELECT"):
        rows = cur.fetchall()
        rows = [dict(row) for row in rows]
    else:
        conn.commit()
        rows = []

    conn.close()
    return rows