/* eslint-disable import/no-commonjs */

const test = require('tape');

var hadError = false;

function createRow(row) {
    var rowNode = document.createElement('div');
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

var loggerNode = document.createElement('div');
document.body.appendChild(loggerNode);

test.createStream().on('data', function (row) {
    row = row.replace(/\n$/, '');
    // eslint-disable-next-line no-console
    console.log(row);
    loggerNode.appendChild(createRow(row));
});

window.addEventListener('error', function (event) {
    console.error(event.message);
    console.error('File name: ' + event.filename);
    console.error('Line number: ' + event.lineno);
});

require('./index-web');
