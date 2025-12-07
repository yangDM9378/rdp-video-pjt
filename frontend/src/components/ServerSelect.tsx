interface Props {
  servers: any[];
  onSelect: (server: string) => void;
}

export default function ServerSelect({ servers, onSelect }: Props) {
  return (
    <div>
      <h3>서버 선택</h3>
      <select onChange={(e) => onSelect(e.target.value)}>
        <option value="">선택하세요</option>
        {servers.map((s) => (
          <option key={s.name} value={s.name}>
            {s.name}
          </option>
        ))}
      </select>
    </div>
  );
}