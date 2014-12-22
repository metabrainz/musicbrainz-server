var test = require('tape');

var hadError = false;
var errorCount = 0;
var rowCount = 0;
var timeout = null;

function createRow(row) {
    ++rowCount;

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
        if (!hadError) {
            hadError = true;
            ++errorCount;
        }
        rowNode.style.backgroundColor = '#F88';
    }

    return rowNode;
}

var loggerNode = document.createElement('div');
document.body.appendChild(loggerNode);

test.createStream().on('data', function (row) {
    row = row.replace(/\n$/, '');

    console.log(row);
    loggerNode.appendChild(createRow(row));

    if (typeof phantom !== 'undefined') {
        var lastKnownRow = rowCount;

        clearTimeout(timeout);

        timeout = setTimeout(function () {
            if (rowCount === lastKnownRow) {
                phantom.exit(1);
            }
        }, 3000);
    }
});

if (typeof phantom !== 'undefined') {
    test.createStream().on('end', function () {
        clearTimeout(timeout);
        phantom.exit(errorCount > 0 ? 1 : 0);
    });
}

require('./common.js');
require('./edit.js');
require('./guess-case.js');
require('./release-editor.js');

MB.edit.preview = function (data, context) {
  return $.Deferred().resolveWith(context, [{ previews: [] }, data]);
};

MB.edit.create = function (data, context) {
  return $.Deferred().resolveWith(context, [{ edits: [] }, data]);
};

require('./tests/typeInfo.js');

require('./tests/autocomplete.js');
require('./tests/Control/ArtistCredit.js');
require('./tests/Control/URLCleanup.js');
require('./tests/CoverArt.js');
require('./tests/edit.js');
require('./tests/entity.js');
require('./tests/externalLinks.js');
require('./tests/GuessCase.js');
require('./tests/i18n.js');
require('./tests/relationship-editor.js');
require('./tests/release-editor/actions.js');
require('./tests/release-editor/bubbles.js');
require('./tests/release-editor/common.js');
require('./tests/release-editor/dialogs.js');
require('./tests/release-editor/edits.js');
require('./tests/release-editor/fields.js');
require('./tests/release-editor/trackParser.js');
require('./tests/release-editor/validation.js');
require('./tests/utility.js');
