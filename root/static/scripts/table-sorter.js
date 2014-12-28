// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var $ = require('jquery');
var _ = require('lodash');

var integer = /^[0-9]+$/;

function sortValue(tr, index) {
    var td = tr.cells[index];
    return td.getAttribute('data-sort-value') || $.trim(td.textContent);
}

function sortColumns($table, $thead, $tbody, columns) {
    var trs = $tbody.children('tr').toArray();

    _.each(columns, function (column) {
        trs.sort(function (a, b) {
            a = sortValue(a, column.index);
            b = sortValue(b, column.index);

            // Opera 12's localeCompare doesn't sort numbers as strings correctly
            if (integer.test(a) && integer.test(b)) {
                return a - b;
            }

            return MB.i18n.compare(a, b);
        });

        if (column.ascending === false) {
            trs.reverse();
        }
    });

    var lastColumn = _.last(columns);

    $('.arrow', $thead).text('');
    $('.arrow', lastColumn.th).text(lastColumn.ascending ? '\u25B2' : '\u25BC');

    $tbody.hide();
    var callback = $table.data('sort-callback');

    for (var i = 0, len = trs.length; i < len; i++) {
        $tbody[0].appendChild(trs[i]);

        if (callback) {
            callback(trs[i], i);
        }
    }

    $tbody.show();
}

$.fn.tableSorter = function (callback) {
    this.data('sort-callback', callback);

    var $table = this;
    var $thead = this.children('thead');
    var $tbody = this.children('tbody');
    var selector = 'th:not(.no-sort)';

    var $ths = $thead.find(selector)
        .css('cursor', 'pointer')
        .append('<span class="arrow"></span>');

    return this.on('click', selector, function () {
        var ascending = !(this.getAttribute('data-ascending') !== 'false');
        this.setAttribute('data-ascending', ascending);

        sortColumns($table, $thead, $tbody, [{
            th: this,
            index: $('th', $thead).index(this),
            ascending: ascending
        }]);
    });
};

$.fn.sortByColumns = function (columns) {
    var $thead = this.children('thead');
    var $tbody = this.children('tbody');
    var $ths = $thead.find('> tr > th');

    sortColumns(this, $thead, $tbody, _.map(columns, function (c) {
        return { th: $ths[c[0]], index: c[0], ascending: c[1] };
    }));

    return this;
};

function updateStatisticsRow(row, index) {
    // Update rank column, even/odd classes
    var position = index + 1;
    var even = position % 2 === 0;

    row.cells[0].textContent = position;
    row.className = row.className.replace(even ? 'odd' : 'even', even ? 'even' : 'odd');
}

$.fn.statisticsTable = function () {
    return $.fn.tableSorter.call(this, updateStatisticsRow);
};
