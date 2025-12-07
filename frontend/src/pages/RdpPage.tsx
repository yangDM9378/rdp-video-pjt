import React, { useEffect, useState } from "react";
import { fetchServers, fetchDates, fetchFileList } from "../api/rdp";

import ServerSelect from "../components/ServerSelect";
import DateSelect from "../components/DateSelect";
import FileList from "../components/FileList";
import VideoPlayer from "../components/VideoPlayer";

export default function RdpPage() {
  const [servers, setServers] = useState<any[]>([]);
  const [selectedServer, setSelectedServer] = useState("");
  const [dates, setDates] = useState<string[]>([]);
  const [files, setFiles] = useState<any[]>([]);
  const [selectedFile, setSelectedFile] = useState<any>(null);

  useEffect(() => {
    fetchServers().then(setServers);
  }, []);

  const handleServer = (serverName: string) => {
    setSelectedServer(serverName);
    setSelectedFile(null);
    fetchDates(serverName).then(setDates);
  };

  const handleDate = (date: string) => {
    fetchFileList(selectedServer, date).then(setFiles);
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>RDP 영상 재생</h2>

      <ServerSelect servers={servers} onSelect={handleServer} />
      <DateSelect dates={dates} onSelect={handleDate} />
      <FileList files={files} onSelect={setSelectedFile} />

      <VideoPlayer filepath={selectedFile?.filepath} server={selectedServer}/>
    </div>
  );
}