let defaultExport;

if (typeof global === 'undefined') {
  defaultExport = window;
} else {
  defaultExport = global;
}

export default defaultExport;
