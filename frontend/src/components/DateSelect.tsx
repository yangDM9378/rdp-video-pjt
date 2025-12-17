interface Props {
  dates: string[];
  onSelect: (date: string) => void;
}

export default function DateSelect({ dates, onSelect }: Props) {
  return (
    <div>
      <h3>날짜 선택</h3>
      <select onChange={(e) => onSelect(e.target.value)}>
        <option value="">선택하세요</option>
        {dates.map((d) => (
          <option key={d} value={d}>
            {d}
          </option>
        ))}
      </select>
    </div>
  );
}
