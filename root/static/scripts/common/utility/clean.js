export default function clean(str) {
  return String(str || '').trim().replace(/\s+/g, ' ');
}
