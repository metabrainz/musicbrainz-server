var msg = document.getElementById('unsupported-browser');
try {
  eval('class C{async #f(){}}');
  document.querySelector('html:has(body)');
  msg.remove();
} catch (e) {
  msg.style.display = 'block';
}
