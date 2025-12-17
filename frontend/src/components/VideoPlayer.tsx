interface Props {
  videoId: number;
  uploaded: number;
}

export default function VideoPlayer({ videoId, uploaded }: Props) {
  if (!videoId) return null;

  const src =
    uploaded === 0
      ? `http://localhost:5001/rdp/video/stream/${videoId}`
      : `http://localhost:5001/rdp/video/play/${videoId}`;

  return (
    <div>
      <h3>영상 재생</h3>
      <video src={src} controls style={{ width: "100%", maxWidth: "800px" }} />
    </div>
  );
}
