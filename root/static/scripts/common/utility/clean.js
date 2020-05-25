// @flow strict

export default function clean(str: ?string): string {
  return String(str || '').trim().replace(/\s+/g, ' ');
}
