/* eslint-disable import/no-commonjs */

const test = require('tape');

let hadError = false;

function createRow(row) {
  const rowNode = document.createElement('div');
  rowNode.appendChild(document.createTextNode(row));

  if (/^# /.test(row)) {
    hadError = false;
    rowNode.style.backgroundColor = '#222';
    rowNode.style.color = '#DDD';
    return rowNode;
  }

  if (/^ok /.test(row)) {
    hadError = false;
    rowNode.style.backgroundColor = '#8F8';
    return rowNode;
  }

  if (hadError || /^not ok /.test(row)) {
    hadError = true;
    rowNode.style.backgroundColor = '#F88';
  }

  return rowNode;
}

const loggerNode = document.createElement('div');
document.body.appendChild(loggerNode);

test.createStream().on('data', function (row) {
  row = row.replace(/\n$/, '');

  console.log(row);
  loggerNode.appendChild(createRow(row));
});

window.addEventListener('error', function (event) {
  console.log(event.message);
  console.log('File name: ' + event.filename);
  console.log('Line number: ' + event.lineno);
});

require('./index-web');
