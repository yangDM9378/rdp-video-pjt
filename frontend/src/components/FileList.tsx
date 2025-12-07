interface Props {
  files: any[];
  onSelect: (file: any) => void;
}

export default function FileList({ files, onSelect }: Props) {
  return (
    <div>
      <h3>영상 파일 목록</h3>
      <ul>
        {files.map((f) => (
          <li
            key={f.id}
            onClick={() => onSelect(f)}
            style={{ cursor: "pointer" }}
          >
            {f.filename}
            {f.uploaded === 0 && (
              <span style={{ color: "red" }}> (전송 전)</span>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
}