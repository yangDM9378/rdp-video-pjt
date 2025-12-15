from flask import Blueprint, request, jsonify, send_file
import os, re
from datetime import datetime
from modules import rdpDB_query

rdp_monitor_api = Blueprint('rdp_monitor_api', __name__)

@rdp_monitor_api.route("/servers", methods=["GET"])
def get_servers():
    rows = rdpDB_query("""
        SELECT name
        FROM rdp_server
    """)
    return jsonify(rows)

@rdp_monitor_api.route("/metadata", methods=["POST"])
def metadata():
    data = request.json
    filepath   = data.get("filepath")
    server     = data.get("server")
    user       = data.get("user")
    session    = data.get("session")
    filename   = data.get("filename")
    start_time = data.get("start_time")
    end_time   = data.get("end_time")
    uploaded   = data.get("uploaded")

    # 운영 서버 경로로 저장
    op_path = None

    if filepath:
        norm = filepath.replace("\\", "/")
        if "/record/" in norm:
            sub = norm.split("/record/")[1]
            op_path = f"{server}/{sub}/{filename}"

    if start_time:
        time_val = start_time
        date_val = start_time.split(" ")[0]
    else:
        time_val = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        date_val = time_val.split(" ")[0]

    uploaded    = 0
    upload_time = None

    rdpDB_query("""
    INSERT INTO rdp_video
    (server_name, user, session, date, filename, filepath,
     uploaded, time, end_time, upload_time)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        server,
        user,
        session,
        date_val,
        filename,
        op_path,
        uploaded,
        time_val,
        end_time,
        upload_time
    ))

    return jsonify({"result": "ok"})


@rdp_monitor_api.route("/dates", methods=["GET"])
def get_dates():
    server = request.args.get("server")

    rows = rdpDB_query("""
        SELECT DISTINCT date FROM rdp_video WHERE server_name=? ORDER BY date DESC
    """, (server,))

    dates = [r['date'] for r in rows]
    return jsonify(dates)

@rdp_monitor_api.route("/list", methods=["GET"])
def get_list():
    server = request.args.get("server")
    date = request.args.get("date")

    rows = rdpDB_query("""
        SELECT id, filename, filepath, uploaded, user
        FROM rdp_video
        WHERE server_name=? AND date=?
        ORDER BY time ASC
    """, (server, date))

    return jsonify(rows)

@rdp_monitor_api.route("/video/<path:filepath>")
def serve_video(filepath):
    full_path = f"C:/Users/user/Desktop/rdp-video-pjt/rdp_monitor/record/{filepath}"
    if not os.path.exists(full_path):
        return jsonify({"error": "file not found"}), 404

    return send_file(full_path)


