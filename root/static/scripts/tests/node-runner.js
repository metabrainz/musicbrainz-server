/* eslint-disable import/no-commonjs */

let rowCount = 0;
let timeout;

require('tape').createStream().on('data', function (row) {
  console.log(row.replace(/\n$/, ''));

  const lastKnownRow = ++rowCount;

  clearTimeout(timeout);

  timeout = setTimeout(function () {
    if (rowCount === lastKnownRow) {
      process.exit(0);
    }
  }, 3000);
});

require('./index');
