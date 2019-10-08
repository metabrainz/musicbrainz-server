// @flow

export default function clean(str: ?string) {
  return String(str || '').trim().replace(/\s+/g, ' ');
}
