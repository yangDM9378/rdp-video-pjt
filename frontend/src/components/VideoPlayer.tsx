interface Props {
  filepath: string;
  server: string;
}

export default function VideoPlayer({ filepath, server }: Props) {
  if (!filepath) return null;

  return (
    <div>
      <h3>영상 재생</h3>
      <video
        src={`http://localhost:5001/rdp/video/${server}/${filepath}`}
        controls
        style={{ width: "100%", maxWidth: "800px" }}
      />
    </div>
  );
}