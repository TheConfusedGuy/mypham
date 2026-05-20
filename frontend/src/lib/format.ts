const vndNumberFormatter = new Intl.NumberFormat("vi-VN");

const dateFormatter = new Intl.DateTimeFormat("vi-VN", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
});

const dateTimeFormatter = new Intl.DateTimeFormat("vi-VN", {
  year: "numeric",
  month: "2-digit",
  day: "2-digit",
  hour: "2-digit",
  minute: "2-digit",
});

export function formatCurrency(value: number): string {
  return `${vndNumberFormatter.format(value)}đ`;
}

export function formatDate(input: unknown): string {
  if (input == null) return "—";
  try {
    let d: Date;
    if (Array.isArray(input)) {
      const [year, month, day, hour = 0, minute = 0, second = 0] = input;
      d = new Date(year, month - 1, day, hour, minute, second);
    } else {
      d = new Date(input as string | number | Date);
    }
    if (isNaN(d.getTime())) {
      return String(input);
    }
    return dateFormatter.format(d);
  } catch {
    return String(input);
  }
}

export function formatDateTime(input: unknown): string {
  if (input == null) return "—";
  try {
    let d: Date;
    if (Array.isArray(input)) {
      const [year, month, day, hour = 0, minute = 0, second = 0] = input;
      d = new Date(year, month - 1, day, hour, minute, second);
    } else {
      d = new Date(input as string | number | Date);
    }
    if (isNaN(d.getTime())) {
      return String(input);
    }
    return dateTimeFormatter.format(d);
  } catch {
    return String(input);
  }
}
