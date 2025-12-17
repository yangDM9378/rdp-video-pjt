import requests
from flask import Blueprint, request, jsonify, send_file, Response, stream_with_context
import os
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

@rdp_monitor_api.route("/video/stream/<int:video_id>")
def stream_today_video(video_id):
    rows = rdpDB_query("""
        SELECT
            v.server_name,
            s.ip AS server_ip,
            v.date,
            v.filename,
            v.uploaded
        FROM rdp_video v
        JOIN rdp_server s
          ON v.server_name = s.name
        WHERE v.id = ?
    """, (video_id,))

    if not rows:
        return jsonify({"error": "not found"}), 404

    video = rows[0]

    if video["uploaded"] != 0:
        return jsonify({"error": "invalid request"}), 400

    server_ip = video["server_ip"]
    filename  = video["filename"]

    raw_date = video["date"]
    date = raw_date.replace("-", "")

    windows_stream_url = (
        f"http://{server_ip}:9180/stream"
        f"?file={filename}&date={date}"
    )

    try:
        r = requests.get(windows_stream_url, stream=True, timeout=5)
    except Exception:
        return jsonify({"error": "windows server unreachable"}), 502

    if r.status_code != 200:
        return jsonify({"error": "stream failed"}), 502

    def generate():
        for chunk in r.iter_content(chunk_size=8192):
            if chunk:
                yield chunk

    return Response(
        stream_with_context(generate()),
        content_type="video/webm"
    )

@rdp_monitor_api.route("/video/play/<int:video_id>")
def play_uploaded_video(video_id):
    rows = rdpDB_query("""
        SELECT filepath, uploaded
        FROM rdp_video
        WHERE id=?
    """, (video_id,))

    if not rows:
        return jsonify({"error": "not found"}), 404

    video = rows[0]

    if video["uploaded"] != 1:
        return jsonify({"error": "invalid request"}), 400

    base_dir = "C:/var/lib/data_platform/rdp_monitor/record"
    full_path = os.path.normpath(os.path.join(base_dir, video["filepath"]))

    if not full_path.startswith(os.path.abspath(base_dir)):
        return jsonify({"error": "invalid path"}), 403

    if not os.path.exists(full_path):
        return jsonify({"error": "file not found"}), 404

    return send_file(full_path, mimetype="video/webm")

@rdp_monitor_api.route("/video/uploaded", methods=["POST"])
def mark_video_uploaded():
    data = request.json

    server   = data.get("server")
    date_raw = data.get("date")
    filename = data.get("filename")

    if not server or not date_raw or not filename:
        return jsonify({"error": "invalid params"}), 400

    date = f"{date_raw[0:4]}-{date_raw[4:6]}-{date_raw[6:8]}"

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    rdpDB_query("""
        UPDATE rdp_video
        SET uploaded = 1,
            upload_time = ?
        WHERE server_name = ?
          AND date = ?
          AND filename = ?
    """, (now, server, date, filename))

    return jsonify({"result": "ok"})