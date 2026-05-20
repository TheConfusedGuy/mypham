function required(name: string, value: string | undefined, defaultValue: string = "http://localhost:8080"): string {
  if (!value) {
    console.warn(`[Warning] Missing env var: ${name}. Falling back to default: ${defaultValue}`);
    return defaultValue;
  }
  return value;
}

export const env = {
  apiBaseUrl: required(
    "NEXT_PUBLIC_API_BASE_URL",
    process.env.NEXT_PUBLIC_API_BASE_URL || process.env.NEXT_PUBLIC_API_URL
  ),
} as const;
