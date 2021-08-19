var rowCount = 0;
var timeout;

require('tape').createStream().on('data', function (row) {
  console.log(row.replace(/\n$/, ''));

  var lastKnownRow = ++rowCount;

  clearTimeout(timeout);

  timeout = setTimeout(function () {
    if (rowCount === lastKnownRow) {
      process.exit(0);
    }
  }, 3000);
});

require('./index');
