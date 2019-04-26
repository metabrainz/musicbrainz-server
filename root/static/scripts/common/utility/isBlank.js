export default function isBlank(str) {
  return /^\s*$/.test(str || '');
}
