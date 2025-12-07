import axios from "axios";

export const API_BASE = "http://localhost:5001/rdp";

export const fetchServers = async () => {
  const res = await axios.get(`${API_BASE}/servers`);
  return res.data;
};

export const fetchDates = async (server: string) => {
  const res = await axios.get(`${API_BASE}/dates`, {
    params: { server },
  });
  return res.data;
};

export const fetchFileList = async (server: string, date: string) => {
  const res = await axios.get(`${API_BASE}/list`, {
    params: { server, date },
  });
  return res.data;
};