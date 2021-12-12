import $ from 'jquery';
import ko from 'knockout';

import stats, {buildTypeStats, getStat} from '../../statistics/stats';

import debounce, {debounceComputed} from './common/utility/debounce';
import parseDate from './common/utility/parseDate';

import '../lib/flot/jquery.flot';
import '../lib/flot/jquery.flot.selection';
import '../lib/flot/jquery.flot.time';
import './jquery.flot.musicbrainz_events';

const defaultLines = [
  'count.area',
  'count.artist',
  'count.coverart',
  'count.edit',
  'count.edit.open',
  'count.edit.perday',
  'count.edit.perweek',
  'count.editor',
  'count.editor.activelastweek',
  'count.editor.deleted',
  'count.editor.editlastweek',
  'count.editor.valid',
  'count.editor.valid.active',
  'count.editor.votelastweek',
  'count.event',
  'count.instrument',
  'count.label',
  'count.medium',
  'count.place',
  'count.recording',
  'count.release',
  'count.release.has_caa',
  'count.releasegroup',
  'count.series',
  'count.vote',
  'count.vote.perday',
  'count.vote.perweek',
  'count.work',
];

class TimelineViewModel {
  constructor() {
    const self = this;
    self.categories = ko.observableArray([]);
    self.enabledCategories = ko.computed(function () {
      return self.categories().filter(function (category) {
        return category.enabled();
      });
    });
    self.events = debounceComputed(ko.observableArray([]), 50);
    self.loadingEvents = ko.observable(false);
    self.loadedEvents = ko.observable(false);
    self.options = {
      rate: ko.observable(false),
      events: ko.observable(true),
    };
    /*
     * rateLimit so they'll all be updated before zoomHashPart is
     * recalculated, and to ensure graph doesn't need repeated redrawing
     */
    self.zoom = {
      xaxis: {
        max: debounceComputed(ko.observable(null), 50),
        min: debounceComputed(ko.observable(null), 50),
      },
      yaxis: {
        max: debounceComputed(ko.observable(null), 50),
        min: debounceComputed(ko.observable(null), 50),
      },
    };
    self.zoomArray = ko.computed({
      read: function () {
        const parts = [self.zoom.xaxis.min(), self.zoom.xaxis.max()];
        if (self.zoom.yaxis.min() || self.zoom.yaxis.max()) {
          parts.push(self.zoom.yaxis.min());
          parts.push(self.zoom.yaxis.max());
        }
        return parts;
      },
      write: function (array) {
        self.zoom.xaxis.min(array[0]);
        self.zoom.xaxis.max(array[1]);
        if (array.length > 2) {
          self.zoom.yaxis.min(array[2]);
          self.zoom.yaxis.max(array[3]);
        }
      },
    });
    self.zoomHashPart = ko.computed({
      read: function () {
        const parts = self.zoomArray();
        if (parts.filter(Boolean).length > 0) {
          return ['g'].concat(parts).join('/');
        }
        return null;
      },
      write: function (part) {
        if (part) {
          const itemFix = function (item) {
            return (item === 'null' ? null : parseFloat(item));
          };
          self.zoomArray(part.split('/').slice(1).map(itemFix));
        } else {
          self.zoomArray([null, null, null, null]);
        }
      },
    });
    // rateLimit to ensure graph doesn't need frequent redrawing
    self.lines = debounceComputed(function () {
      return [].concat(
        ...self.enabledCategories().map(category => category.enabledLines()),
      );
    }, 1000);

    self.waitToGraph = ko.computed(function () {
      if (self.enabledCategories().some(function (c) {
        return c.hasLoadingLines();
      })) {
        return true;
      }

      if (self.options.events() && !self.loadedEvents()) {
        return true;
      }

      return false;
    });

    self.rateZoomY = ko.computed(function () {
      const bounds = self.lines().reduce(function (accum, line) {
        if (line.loaded()) {
          const rateBounds = line.calculateRateBounds(
            line.rateData().data,
            line.rateData().thresholds,
            {
              min: self.zoom.xaxis.min(),
              max: self.zoom.xaxis.max(),
            },
          );
          if (accum.min == null || rateBounds.min < accum.min) {
            accum.min = rateBounds.min;
          }
          if (accum.max == null || rateBounds.max > accum.max) {
            accum.max = rateBounds.max;
          }
        }
        return accum;
      }, {min: null, max: null});
      if (bounds.min) {
        bounds.min -= Math.abs(bounds.min * 0.10);
      }
      if (bounds.max) {
        bounds.max += Math.abs(bounds.max * 0.10);
      }
      return bounds;
    });

    let lines = document.location.pathname.match(
      /^\/statistics\/timeline\/(.+)$/,
    )[1].split('+');

    let usingDefaultLines = false;

    if (lines.length === 1 && lines[0] === 'main') {
      lines = defaultLines;
      usingDefaultLines = true;
    }

    self.addLines(lines, usingDefaultLines);
    self._getLocationHashSettings();

    function getHashPart(accum, object) {
      if (object.enabledByDefault !== object.enabled()) {
        accum.push((object.enabled() ? '' : '-') + object.hashIdentifier);
      }
      return accum;
    }

    self.hash = debounceComputed(function () {
      const optionParts = [];
      if (self.options.rate()) {
        optionParts.push('r');
      }
      if (!self.options.events()) {
        optionParts.push('-v');
      }
      if (self.zoomHashPart()) {
        optionParts.push(self.zoomHashPart());
      }
      const categoryParts = self.categories().reduce(getHashPart, []).sort();
      const lineParts = self.categories().reduce((accum, category) => {
        if (category.enabled()) {
          accum.push(...category.lines().reduce(getHashPart, []));
        }
        return accum;
      }, []).sort();
      return optionParts.concat(categoryParts, lineParts).join('+');
    }, 1000);

    /*
     * Ignore hashchange events that are the result of the user fiddling
     * with options. We only need to call _getLocationHashSettings again
     * if it's directly changed in the address bar.
     */
    let ignoreHashChange = false;

    self.hash.subscribe(function (newHash) {
      ignoreHashChange = true;
      window.location.hash = newHash;
      ignoreHashChange = false;
    });

    $(window).on('hashchange', function () {
      if (!ignoreHashChange) {
        self._getLocationHashSettings();
      }
    });

    ko.computed({
      read: function () {
        if (self.options.events() &&
            !self.loadedEvents() &&
            !self.loadingEvents()) {
          self.loadEvents();
        }
      },
      disposeWhen: self.loadedEvents,
    });
  }

  _getLocationHashSettings() {
    // XXX: reset to defaults when preference is not expressed
    const parts = location.hash.replace(/^#/, '').split('+').filter(Boolean);
    const self = this;

    for (const part of parts) {
      let match;

      if ((match = part.match(/^(-)?([rv])-?$/))) { // trailing - for backwards-compatibility
        const method = match[2] === 'r' ? 'rate' : 'events';
        self.options[method](!(match[1] === '-'));
      } else if ((match = part.match(/^(-)?(c-.*)$/))) {
        const hashIdentifier = match[2];
        const category = self.categories().find(
          x => x.hashIdentifier === hashIdentifier,
        );
        if (category) {
          category.enabled(!(match[1] === '-'));
        }
      } else if ((match = part.match(/^g\/.*$/))) {
        self.zoomHashPart(part);
      } else {
        match = part.match(/^(-)?(.*)$/);
        outer:
        for (const category of self.categories()) {
          for (const line of category.lines()) {
            if (line.hashIdentifier === match[2]) {
              line.enabled(!(match[1] === '-'));
              break outer;
            }
          }
        }
      }
    }
  }

  addCategory(category) {
    this.categories.push(category);
    return category;
  }

  addLine(name, usingDefaultLines) {
    const newLine = getStat(name);
    let category = this.categories().find(x => x.name === newLine.category);

    if (!category) {
      const newCategory = stats.category[newLine.category];
      category = this.addCategory(new TimelineCategory(
        newLine.category,
        newCategory.label,
        usingDefaultLines ? !newCategory.hide : true,
      ));
    }

    category.addLine(new TimelineLine(
      name,
      newLine.label,
      newLine.color,
      usingDefaultLines ? !newLine.hide : true,
    ));
  }

  addLines(names, usingDefaultLines) {
    const self = this;
    for (const name of names) {
      self.addLine(name, usingDefaultLines);
    }
  }

  loadEvents() {
    const self = this;
    self.loadingEvents(true);
    $.ajax({
      url: '../../ws/js/events',
      dataType: 'json',
    }).done(function (data) {
      self.events(data.map(function (e) {
        e.jsDate = Date.parse(e.date);
        return e;
      }));
      self.loadedEvents(true);
    })
      .fail(function () {
        self.events([]);
      })
      .always(function () {
        self.loadingEvents(false);
      });
  }
}

class TimelineCategory {
  constructor(name, label, enabledByDefault) {
    const self = this;
    if (enabledByDefault === undefined) {
      enabledByDefault = false;
    }
    self.name = name;
    self.hashIdentifier = 'c-' + name;
    self.label = label;
    self.enabledByDefault = !!enabledByDefault;
    self.enabled = ko.observable(!!enabledByDefault);
    // rateLimit to improve reponsiveness of checkboxes
    self.lines = debounceComputed(ko.observableArray([]), 50);

    self.enabledLines = ko.computed(function () {
      return self.lines().filter(function (line) {
        return line.enabled() && line.loaded();
      });
    });
    self.needLoadingLines = ko.computed(function () {
      if (self.enabled()) {
        return self.lines().filter(function (line) {
          return line.enabled() && !line.loaded() && !line.loading();
        });
      }
      return [];
    });
    self.hasLoadingLines = ko.computed(function () {
      return self.lines().filter(function (line) {
        return line.enabled() && line.loading();
      }).length;
    });

    // rateLimit to load asynchronously
    debounceComputed(function () {
      for (const line of self.needLoadingLines()) {
        line.loadData();
      }
    }, 1);
  }

  addLine(line) {
    this.lines.push(line);
  }
}

class TimelineLine {
  constructor(name, label, color, enabledByDefault) {
    const self = this;
    if (enabledByDefault === undefined) {
      enabledByDefault = false;
    }
    self.color = color;
    self.name = name;
    self.hashIdentifier = name.replace(/^count\./, '');
    self.label = label;
    self.enabledByDefault = !!enabledByDefault;
    self.enabled = ko.observable(!!enabledByDefault);
    self.loading = ko.observable(false);
    self.data = ko.observable(null);
    self.loaded = ko.observable(null);
    self.rateData = ko.computed(function () {
      return self.calculateRateData(self.data());
    });
  }

  loadData() {
    const self = this;
    self.loading(true);
    $.ajax({
      url: '../../statistics/dataset/' + self.name,
      dataType: 'json',
    }).done(function (data) {
      data = data.data;

      const serial = [];
      for (const key in data) {
        const {year, month, day} = parseDate(key);
        serial.push([Date.UTC(year, month - 1, day), data[key]]);
      }
      serial.sort((a, b) => a[0] - b[0]);

      self.data(serial);
      self.loaded(true);
    })
      .fail(function () {
        self.data(null);
      })
      .always(function () {
        self.loading(false);
      });
  }

  calculateRateData(data) {
    if (!data || !data.length) {
      return {data: [], thresholds: {min: null, max: null}};
    }
    const weekData = [];
    const oneDay = 1000 * 60 * 60 * 24;
    let dataPrev = data[0][1];
    let datePrev = data[0][0];
    let sPrev = 0;
    const a = 0.25;

    let mean = 0;
    let count = 0;

    $.each(data, function (index, value) {
      let changeValue = value[1] - dataPrev;
      let sCurrent;
      let days = 1;

      if (datePrev != null && value[0] > datePrev + oneDay) {
        days = (value[0] - datePrev) / oneDay;
        changeValue /= days;
      }

      for (let i = 0; i < days; i++) {
        count++;
        mean += changeValue;
        sCurrent = a * changeValue + (1 - a) * sPrev;
        weekData.push([datePrev + (i + 1) * oneDay, sCurrent]);
        sPrev = sCurrent;
      }
      dataPrev = value[1];
      datePrev = value[0];
    });
    mean /= count;

    const deviationSum = weekData.reduce(function (sum, next) {
      const toSquare = next[1] - mean;
      return sum + toSquare * toSquare;
    }, 0);
    const standardDeviation = Math.sqrt(deviationSum / count);
    const thresholds = {
      max: mean + 3 * standardDeviation,
      min: mean - 3 * standardDeviation,
    };

    return {data: weekData, thresholds: thresholds};
  }

  calculateRateBounds(data, thresholds, dateThresholds) {
    let rateBounds = {min: thresholds.max, max: thresholds.min};
    $.each(data, function (index, value) {
      if (value[1] > thresholds.min &&
          value[1] < thresholds.max &&
          (!dateThresholds ||
          (value[0] > dateThresholds.min &&
          value[0] < dateThresholds.max))) {
        if (value[1] > rateBounds.max) {
          rateBounds.max = value[1];
        }
        if (value[1] < rateBounds.min) {
          rateBounds.min = value[1];
        }
      }
    });
    if (rateBounds.min >= rateBounds.max) {
      rateBounds = {min: null, max: null};
    }
    return rateBounds;
  }
}

(function () {
  // Closure over utility functions.
  const showTooltip = function (x, y, contents) {
    $('<div id="tooltip">' + contents + '</div>')
      .css({
        'position': 'absolute',
        'display': 'none',
        'top': y + 5,
        'left': x + 5,
        'border': '1px solid #fdd',
        'padding': '2px',
        'background-color': '#fee',
        'opacity': 0.80,
      })
      .appendTo('body')
      .fadeIn(200);
  };

  const removeTooltip = function () {
    $('#tooltip').remove();
  };

  const setCursor = function (type) {
    if (!type) {
      type = '';
    }
    $('body').css('cursor', type);
  };

  const setItemTooltip = function (item, extra, fixed) {
    if (!extra) {
      extra = '';
    }
    removeTooltip();
    setCursor();
    const x = item.datapoint[0];
    let y = item.datapoint[1];
    const date = new Date(parseInt(x, 10));

    if (fixed) {
      y = y.toFixed(fixed);
    }

    let day;
    if (date.getDate() < 10) {
      day = '0' + date.getDate();
    } else {
      day = date.getDate();
    }

    let month;
    if (date.getMonth() + 1 < 10) {
      month = '0' + (date.getMonth() + 1);
    } else {
      month = date.getMonth() + 1;
    }

    showTooltip(
      item.pageX,
      item.pageY,
      date.getFullYear() + '-' + month + '-' + day + ': ' + y +
        ' ' + item.series.label + extra,
    );
  };

  const setEventTooltip = function (thisEvent, pos) {
    removeTooltip();
    setCursor('pointer');
    showTooltip(
      pos.pageX,
      pos.pageY,
      '<h2 style="margin-top: 0px; padding-top: 0px">' +
        thisEvent.title + '</h2>' + thisEvent.description,
    );
  };

  ko.bindingHandlers.flot = {
    init: function (
      element,
      valueAccessor,
      allBindings,
      viewModel,
      bindingContext,
    ) {
      const graph = ko.unwrap(valueAccessor());
      let previousPoint = null;
      let currentEvent = null;
      const reset = function () {
        removeTooltip();
        previousPoint = null;
        currentEvent = null;
        $(element).data('plot').changeCurrentEvent({});
        setCursor();
      };
      $(element)
        .bind('plothover', function (event, pos, item) {
          if (item) {
            if (previousPoint != item.dataIndex) {
              reset();
              previousPoint = item.dataIndex;
              setItemTooltip(
                item,
                graph === 'rate' ? stats.rateTooltipCloser : undefined,
                graph === 'rate' ? 2 : undefined,
              );
            }
          } else if ($(element).data('plot').getEvent(pos)) {
            const thisEvent = $(element).data('plot').getEvent(pos);
            if (!currentEvent || thisEvent.jsDate !== currentEvent.jsDate) {
              reset();
              currentEvent = thisEvent;
              $(element).data('plot').changeCurrentEvent(currentEvent);
              setEventTooltip(thisEvent, pos);
            }
          } else {
            reset();
          }
        })
        .bind('plotselected', function (event, ranges) {
          // Prevent eternal zoom
          if (ranges.xaxis.to - ranges.xaxis.from < 86400000) {
            ranges.xaxis.to = ranges.xaxis.from + 86400000;
          }
          if (ranges.yaxis.to - ranges.yaxis.from < 1) {
            ranges.yaxis.to = ranges.yaxis.from + 1;
          }

          const zoomArr = [ranges.xaxis.from, ranges.xaxis.to];
          if (graph === 'main' || graph === 'overview') {
            zoomArr.push(ranges.yaxis.from);
            zoomArr.push(ranges.yaxis.to);
          }

          bindingContext.$data.zoomArray(zoomArr);
        })
        .bind('plotunselected', function () {
          if (currentEvent && currentEvent.link) {
            window.open(currentEvent.link);
          } else {
            bindingContext.$data.zoomArray([null, null, null, null]);
          }
        });

      // Resize the graph when the window size changes
      $(window).on('resize', debounce(function () {
        const plot = $(element).data('plot');
        plot.resize();
        plot.setupGrid();
        plot.draw();
      }, 100));
    },
    update: function (
      element,
      valueAccessor,
      allBindings,
      viewModel,
      bindingContext,
    ) {
      const graph = ko.unwrap(valueAccessor());
      if (!bindingContext.$data.waitToGraph()) {
        const lines = bindingContext.$data.lines();
        // Shared options
        const options = {
          legend: {show: false},
        };

        /*
         * Main options (hoverability, axes, tick formatting,
         * events, line size)
         */
        if (graph === 'main' || graph === 'rate') {
          options.grid = {hoverable: true};
          options.xaxis = {
            minTickSize: [7, 'day'],
            mode: 'time',
            timeformat: '%Y/%m/%d',
          };
          options.yaxis = {
            tickFormatter: function (x) {
              // XXX: localized number formatting
              return x.toString().replace(/\B(?=(?:\d{3})+(?!\d))/g, ',');
            },
          };
          if (bindingContext.$data.options.events()) {
            options.musicbrainzEvents = {
              enabled: bindingContext.$data.options.events(),
              data: bindingContext.$data.events(),
              currentEvent: {},
            };
          }
        } else if (graph === 'overview') {
          options.series = {lines: {lineWidth: 1}, shadowSize: 0};
          options.xaxis = {mode: 'time', minTickSize: [1, 'year']};
          options.yaxis = {tickFormatter: () => ''};
        }

        // Selection mode
        if (graph === 'main' || graph === 'overview') {
          options.selection = {mode: 'xy'};
        } else if (graph === 'rate') {
          options.selection = {mode: 'x'};
        }

        // zoom
        if (graph === 'main') {
          options.xaxis.min = bindingContext.$data.zoom.xaxis.min();
          options.xaxis.max = bindingContext.$data.zoom.xaxis.max();
          options.yaxis.min = bindingContext.$data.zoom.yaxis.min();
          options.yaxis.max = bindingContext.$data.zoom.yaxis.max();
        } else if (graph === 'rate') {
          options.xaxis.min = bindingContext.$data.zoom.xaxis.min();
          options.xaxis.max = bindingContext.$data.zoom.xaxis.max();
          options.yaxis.min = bindingContext.$data.rateZoomY().min;
          options.yaxis.max = bindingContext.$data.rateZoomY().max;
        }

        /*
         * This has to be done here, or the rate graph
         * will end up huge and unwieldy.
         */
        if (graph === 'rate') {
          $(element).toggle(bindingContext.$data.options.rate());
        }

        const plot = $.plot($(element), lines.map(function (line) {
          let data;
          if (graph === 'main' || graph === 'overview') {
            data = line.data();
          } else if (graph === 'rate') {
            data = line.rateData().data;
          }
          return {
            data: data,
            label: line.label,
            color: line.color,
          };
        }), options);
        plot.triggerRedrawOverlay();
      }
    },
  };
}());

$.ajax({
  dataType: 'json',
  url: './type-data',
}).done(function (data) {
  buildTypeStats(data);

  $(function () {
    ko.applyBindings(new TimelineViewModel());
  });
});
