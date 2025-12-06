from flask import Blueprint, request, jsonify, send_file
import os
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

    rdpDB_query("""
    INSERT INTO rdp_video
    (server_name, user, session, date, filename, filepath, uploaded, time)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        data["server"],
        data["user"],
        data["session"],
        data["date"],
        data["filename"],
        data["filepath"],
        data.get("uploaded", 0),
        data["time"]
    ))

    return jsonify({"result":"ok"})


@rdp_monitor_api.route("/dates", methods=["GET"])
def get_dates():
    server = request.args.get("server")

    rows = rdpDB_query("""
        SELECT DISTINCT date
        FROM rdp_video
        WHERE server_name=?
        ORDER BY date DESC
    """, (server,))

    dates = [r[0] for r in rows]
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
    full_path = f"../data/rdp-video/{filepath}"
    if not os.path.exists(full_path):
        return jsonify({"error": "file not found"}), 404

    return send_file(full_path)


