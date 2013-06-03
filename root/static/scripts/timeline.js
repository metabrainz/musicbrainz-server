MB.Timeline = {};

$(document).ready(function () {
    var categoryIDPrefix = 'category-';
    var controlIDPrefix = 'graph-control-';

    var musicbrainzEventsOptions = {musicbrainzEvents: { currentEvent: {}, data: [], enabled: true}}
    var graphOptions = {};
    var overviewOptions = {};
    var graphZoomOptions = {};

    // Get MusicBrainz Events data
    $.get('../../ws/js/events', function (data) {
        musicbrainzEventsOptions.musicbrainzEvents.data = $.map(data, function(e) {
            e.jsDate = Date.parse(e.date);
            return e;
        });
        $(window).hashchange();
    }, 'json');

    // Called whenever plot is reset
    function graphData () {
        var alldata =  [];
        var ratedata = [];
        $("#graph-lines div input").filter(":checked").each(function () {
            if ($(this).parents('div.graph-category').prev('.toggler').children('input:checkbox').prop('checked')) {
                var datasetId = $(this).parent('div.graph-control').attr('id').substr(controlIDPrefix.length);
                var $this_control = $(this).parents('div.graph-control');
                if (!MB.Timeline.datasets[datasetId].data && !$this_control.hasClass('loading')) {
                   $this_control.addClass('loading').find('input').prop('disabled', true);
                   $.ajax({url: '../../statistics/dataset/' + datasetId,
                       dataType: 'json',
                       success: function(data) {
                           MB.Timeline.datasets[datasetId].data = data;
                           rateData(datasetId);
                           $this_control.removeClass('loading').find('input').prop('disabled', false);
                           $(window).hashchange();
                   }});
                } else if (MB.Timeline.datasets[datasetId].data) {
                    alldata.push(MB.Timeline.datasets[datasetId]);
                    ratedata.push(rateData(datasetId));
                }
            }
        });
        return [alldata, ratedata]
    }

    // Creates the proper data object for the rate-of-change graph
    function rateData(datasetId) {
        var dataset = MB.Timeline.datasets[datasetId];
        var rateHash = $.extend({}, dataset);
        if (!dataset.rateOfChange) {
            MB.Timeline.datasets[datasetId].rateOfChange = weeklyRate(dataset.data);
            dataset = MB.Timeline.datasets[datasetId];
        }
        rateHash.data = dataset.rateOfChange.data;
        rateHash.thresholds = dataset.rateOfChange.thresholds;
        return rateHash
    }

    // Called once per dataset to calculate rates of change
    function weeklyRate(data) {
        var weekData = [];
        var oneDay = 1000 * 60 * 60 * 24;
        var dataPrev = data[0][1];
        var datePrev = data[0][0];
        var sPrev = 0;
        var a = 0.25;

        var mean = 0;
        var count = 0;

        $.each(data, function(index, value) {
            var changeValue = value[1] - dataPrev;
            var sCurrent;
            var days = 1;

            if (datePrev != null && value[0] > datePrev + oneDay) {
                days = (value[0] - datePrev) / oneDay;
                changeValue = changeValue / days
            }

            for (var i = 0; i < days; i++) {
                count++;
                mean = mean + changeValue;
                sCurrent = a * changeValue + (1-a) * sPrev;
                weekData.push([datePrev + (i+1) * oneDay, sCurrent]);
                sPrev = sCurrent;
            }
            dataPrev = value[1];
            datePrev = value[0]
        });
        mean = mean / count;

        var deviationSum = 0;
        $.each(weekData, function(index, value) {
            var toSquare = value[1] - mean;
            deviationSum = deviationSum + toSquare * toSquare;
        });
        var standardDeviation = Math.sqrt(deviationSum / count);
        var thresholds = {min: mean - 3 * standardDeviation,
                          max: mean + 3 * standardDeviation};

        return {data: weekData, thresholds: thresholds};
    }

    function calculateRateBounds(data, thresholds, dateThresholds) {
        var rateBounds = {min: thresholds.max, max: thresholds.min};
        $.each(data, function(index, value) {
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

    function jq(myid) {
        return '#' + myid.replace(/(:|\.)/g,'\\$1');
    }

    // Make selections zoom
    $('#graph-container').bind('plotselected', function (event, ranges) {
        // clamp the zooming to prevent eternal zoom
        if (ranges.xaxis.to - ranges.xaxis.from < 86400000)
            ranges.xaxis.to = ranges.xaxis.from + 86400000;
        if (ranges.yaxis.to - ranges.yaxis.from < 1)
            ranges.yaxis.to = ranges.yaxis.from + 1;

        graphZoomOptions = {
            xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to },
            yaxis: { min: ranges.yaxis.from, max: ranges.yaxis.to }}

        removeFromHash('g-([0-9.e]+/){3}[0-9.e]+');
        changeHash(false, hashPartFromGeometry(graphZoomOptions), true);
    });

    $('#overview').bind('plotselected', function(event, ranges) {
        plot.setSelection(ranges);
    });

    $('#rate-of-change-graph').bind('plotselected', function(event, ranges) {
        var axis = plot.getAxes().yaxis;
        plot.setSelection({xaxis: ranges.xaxis, yaxis: {from: axis.min, to: axis.max}});
    });

    // "Reset Graph" functionality
    $('#graph-container, #overview, #rate-of-change-graph').bind('plotunselected', function () {
        if (!plot.getOptions().musicbrainzEvents.currentEvent.link)
        {
            graphZoomOptions = {};
            removeFromHash('g-([0-9.e]+/){3}[0-9.e]+');
        } else {
            // we're clicking on an event, should open the link instead
            window.open(plot.getOptions().musicbrainzEvents.currentEvent.link);
        }
    });

    // Hover-tooltip Utility Functions
    function showTooltip(x, y, contents) {
        $('<div id="tooltip">' + contents + '</div>').css( {
            position: 'absolute',
            display: 'none',
            top: y + 5,
            left: x + 5,
            border: '1px solid #fdd',
            padding: '2px',
            'background-color': '#fee',
            opacity: 0.80
        }).appendTo("body").fadeIn(200);
    }
    function removeTooltip() { $('#tooltip').remove(); }
    function setCursor(type) {
        if (!type) { type = ''; }
        $('body').css('cursor', type);
    }
    function clearAll() {
        setCursor();
        removeTooltip();
        previousPoint = null;
        ratePreviousPoint = null;
        changeCurrentEvent({});
    }

    // MusicBrainz Events Tooltip management functions
    function changeCurrentEvent(item) {
        musicbrainzEventsOptions.musicbrainzEvents.currentEvent = item;
        plot.changeCurrentEvent(item);
        if (rateplot) { rateplot.changeCurrentEvent(item); }
    }
    function setItemTooltip(item, extra, fixed) {
            if (!extra) { extra = '' };
            removeTooltip();
            setCursor();
            var x = item.datapoint[0],
                y = item.datapoint[1],
                date = new Date(parseInt(x));

            if (fixed) {
                y = y.toFixed(fixed);
            }

            if (date.getDate() < 10) { day = '0' + date.getDate(); } else { day = date.getDate(); }
            if (date.getMonth()+1 < 10) { month = '0' + (date.getMonth()+1); } else { month = date.getMonth()+1; }

            showTooltip(item.pageX, item.pageY,
                date.getFullYear() + '-' + month + '-' + day + ": " + y + " " + item.series.label + extra);
            changeCurrentEvent({});
    }
    function setEventTooltip(plot, pos) {
        var thisEvent = plot.getEvent(pos);
        if (musicbrainzEventsOptions.musicbrainzEvents.currentEvent.jsDate != thisEvent.jsDate) {
            removeTooltip();
            setCursor('pointer');
            showTooltip(pos.pageX, pos.pageY,
                '<h2 style="margin-top: 0px; padding-top: 0px">' + thisEvent.title + '</h2>' + thisEvent.description);

            changeCurrentEvent(thisEvent);
        }
    }

    // Hover functionality on main and rate-of-change graphs
    var previousPoint = null;
    $('#graph-container').bind('plothover', function (event, pos, item) {
        if(item) {
            if (previousPoint != item.dataIndex) {
                previousPoint = item.dataIndex;
                setItemTooltip(item);
            }
        }
        else if (plot.getEvent(pos)) { setEventTooltip(plot, pos); }
        else { clearAll(); }
    });
    var ratePreviousPoint = null;
    $('#rate-of-change-graph').bind('plothover', function (event, pos, item) {
        if(item) {
            if (ratePreviousPoint != item.dataIndex) {
                ratePreviousPoint = item.dataIndex;
                setItemTooltip(item, MB.text.Timeline.RateTooltipCloser, 2);
            }
        }
        else if (rateplot.getEvent(pos)) { setEventTooltip(rateplot, pos); }
        else { clearAll(); }
    });

    // Zoom Level in location.hash, utility functions
    function hashPartFromGeometry(g) {
        return 'g-' + g.xaxis.min + '/' + g.xaxis.max +
                '/' + g.yaxis.min + '/' + g.yaxis.max;
    }
    function geometryFromHashPart(hashPart){
        var hashParts = hashPart.substr(2).split('/');
        return { xaxis: { min: parseFloat(hashParts[0]),
                          max: parseFloat(hashParts[1]) },
                 yaxis: { min: parseFloat(hashParts[2]),
                          max: parseFloat(hashParts[3]) }};
    }

    // Utility functions/variables for changing location.hash
    var newHash = '';
    var hashChangeTimeoutId = [];

    // minus: should there be a '-' before it;
    // newHashPart: identifier, sans '-' if applicable;
    // hide: is this thing hidden by default
    function changeHash(minus, newHashPart, hide) {
        if (hashChangeTimeoutId.length > 0 ) { $.each(hashChangeTimeoutId, function (i, Id) { window.clearTimeout(Id); hashChangeTimeoutId.splice(i, 1); }); }

        if (!new RegExp('(\\+|#|^)-?' + newHashPart + '(?=($|\\+))').test(newHash)) {
            if (hide != minus) {
                newHash = newHash + (newHash != '' ? '+' : '') + (minus ? '-' : '') + newHashPart;
            }
        } else {
            if (hide != minus) {
                newHash = newHash.replace(new RegExp('(\\+|#|^)-?' + newHashPart + '(?=($|\\+))'), '+' + (minus ? '-' : '') + newHashPart);
            } else {
                removeFromHash('-?' + newHashPart);
            }
        }

        hashChangeTimeoutId.push(window.setTimeout(changeHashTimeout, 1000));
    }
    function removeFromHash(toRemove) {
        if (hashChangeTimeoutId.length > 0 ) { $.each(hashChangeTimeoutId, function (i, Id) { window.clearTimeout(Id); hashChangeTimeoutId.splice(i, 1); }); }
        var regex = new RegExp('(\\+|#|^)' + toRemove + '(?=($|\\+))')
        newHash = newHash.replace(regex , '');
        hashChangeTimeoutId.push(window.setTimeout(changeHashTimeout, 1000));
    }
    function changeHashTimeout() {
            if (hashChangeTimeoutId.length > 0 ) { $.each(hashChangeTimeoutId, function (i, Id) { window.clearTimeout(Id);  }); }
            window.location.hash = newHash;
            hashChangeTimeoutId = [];
    }

    // Hashchange related functions
    function check(elem, checked) {
        elem.children('input:checkbox').prop('checked', checked).change();
    }
    $(window).hashchange(function () {
            var hash = location.hash.replace( /^#/, '' );
            var queries = hash.split('+');

            $.each(queries, function (index, value) {
                if (value.substr(0,2) == 'g-') {
                    graphZoomOptions = geometryFromHashPart(value);
                } else if (value.substr(0,3) == '-v-') {
                    $('#disable-events-checkbox').prop('checked', false).change();
                } else if (value.substr(0,2) == 'r-') {
                    $('#show-rate-graph').prop('checked', true).change();
                } else {
                    var checked = (value.substr(0,1) != '-');
                    if (!checked) {
                        value = value.substr(1);
                    }
                    if (value.substr(0,2) == 'c-') {
                        value = value.substr(2);
                        check($(jq(categoryIDPrefix + value)).prev('.toggler'), checked);
                    } else {
                        check($(jq(controlIDPrefix + 'count.' + value)), checked);
                    }
                }
            });
            resetPlot();
    });
    function resetPlot () {
        if ($('div.loading').length == 0) {
            var data = graphData();
            if ($('div.loading').length == 0) {
                var plotOptions = $.extend(true, {}, graphOptions, graphZoomOptions, musicbrainzEventsOptions)
                plot = $.plot($("#graph-container"), data[0], plotOptions);
                plot.triggerRedrawOverlay();

                if ($('#show-rate-graph').prop('checked')) {
                    var rateZoomOptions = {yaxis: {min: null, max: null}};
                    $.each(data[1], function(index, value) {
                       var thresholds = value.thresholds;
                       var rateBounds = calculateRateBounds(value.data, thresholds, graphZoomOptions.xaxis);
                       if (rateZoomOptions.yaxis.min == null || rateBounds.min < rateZoomOptions.yaxis.min) {
                           rateZoomOptions.yaxis.min = rateBounds.min;
                       }
                       if (rateZoomOptions.yaxis.max == null || rateBounds.max > rateZoomOptions.yaxis.max) {
                           rateZoomOptions.yaxis.max = rateBounds.max;
                       }
                    });
                    if (rateZoomOptions.yaxis.min) {
                        rateZoomOptions.yaxis.min = rateZoomOptions.yaxis.min - Math.abs(rateZoomOptions.yaxis.min * 0.10);
                    }
                    if (rateZoomOptions.yaxis.max) {
                        rateZoomOptions.yaxis.max = rateZoomOptions.yaxis.max + Math.abs(rateZoomOptions.yaxis.max * 0.10);
                    }
                    var rateOptions = $.extend(true, {}, graphOptions, {xaxis: graphZoomOptions.xaxis, yaxis: rateZoomOptions.yaxis, selection: {mode: "x"}}, musicbrainzEventsOptions);
                    rateplot = $.plot($("#rate-of-change-graph"), data[1], rateOptions);
                    rateplot.triggerRedrawOverlay();
                } else { rateplot = null; }

                overview = $.plot($('#overview'), data[0], overviewOptions);
            }
        }
    }

    // Utility functions for MB.setupGraphing
    function controlHtml(datasetId, label) {
        var id = controlIDPrefix + 'checker' + datasetId;
        var name = controlIDPrefix + datasetId;
        var color = (MB.text.Timeline.Stat(datasetId) || { 'Color': '#ff0000' })['Color'];
        return MB.html.div( { "class": 'graph-control', "id": name },
                     MB.html.input( { 'id': id, 'name': name, 'type': 'checkbox', 'checked': 'checked' }, '') +
                     MB.html.label( { 'for': id },
                                    MB.html.div({ 'class' : 'graph-color-swatch', 'style': 'background-color: ' +  color + ';' }, '') + label));
    }
    function categoryHtml(category) {
        var id = categoryIDPrefix + 'checker-' + category;
        var divId = categoryIDPrefix + category;
        var label = (MB.text.Timeline.Category[category] || { Label : 'Unknown' })['Label'];
        return '<h2 class="toggler">' +
               MB.html.input( { 'id': id, 'type': 'checkbox', 'checked': 'checked'}, '') +
               MB.html.label( { 'for': id }, label ) +
               '</h2>' +
               MB.html.div( { 'class': 'graph-category', 'id': divId }, '' );
    }
    function controlChange() {
        var $this = $(this);
        var minus = !$this.prop('checked');
        var identifier = $this.parent('div').attr('id').substr(controlIDPrefix.length);
        var newHashPart = identifier.substr('count.'.length);
        var hide = (MB.text.Timeline.Stat(identifier).Hide ? true : false);
        changeHash(minus, newHashPart, hide);

        if (minus) {
            $this.siblings('label').children('div.graph-color-swatch').css('background-color', '#ccc');
        } else {
            $this.siblings('label').children('div.graph-color-swatch').css('background-color',
                MB.text.Timeline.Stat(identifier).Color);
        }
    }
    function categoryChange() {
        var $this = $(this);

        var categoryId = $this.parent('.toggler').next('div.graph-category').attr('id');
        var minus = !$this.prop('checked');
        var newHashPart = categoryId.replace(new RegExp(categoryIDPrefix), 'c-');
        var hide = (MB.text.Timeline.Category[categoryId.substr(categoryIDPrefix.length)].Hide ? true : false);
        changeHash(minus, newHashPart, hide);

        $this.parent('.toggler').next()[minus ? 'hide' : 'show']('slow');
    }

    MB.Timeline.addControls = function (id, dataset) {
        if (!dataset) {
            stat = MB.text.Timeline.Stat(id);
            dataset = {
                'label': stat.Label,
                'color': stat.Color,
                'category': stat.Category
            }
        }
        if (!MB.Timeline.datasets[id]) {
            MB.Timeline.datasets[id] = dataset;
        }
        if ($(jq(controlIDPrefix + id)).length == 0) {
            if ($('#' + categoryIDPrefix + dataset.category).length == 0) {
                $('#graph-lines').append(categoryHtml(dataset.category));
                $('#graph-lines .toggler input:checkbox#' + categoryIDPrefix + 'checker-' + dataset.category).change(categoryChange);
            }
            $("#graph-lines #" + categoryIDPrefix + dataset.category).append(controlHtml(id, dataset.label));
            $("#graph-lines div" + jq(controlIDPrefix + id) + " input:checkbox").change(controlChange);
        }
    }

    MB.Timeline.setupGraphing = function (data, goptions, ooptions) {
        MB.Timeline.datasets = data;
        graphOptions = goptions;
        overviewOptions = ooptions;

        // Set up checkboxes/legend
        $.each(MB.Timeline.datasets, MB.Timeline.addControls);

        // toggler for MusicBrainz Events
        $('#disable-events-checkbox').change(function () {
            var minus = !$(this).prop('checked');
            musicbrainzEventsOptions.musicbrainzEvents.enabled = !minus;
            changeHash(minus, 'v-', false);
        });

        // toggler for Rate of Change graph, plus auto-hiding it
        $('#show-rate-graph').change(function () {
            var $graph = $('#rate-of-change-graph');
            var $show = $(this).prop('checked');
            $graph.css($show ? {position: 'relative', right: ''} : {position: 'absolute', right: 100000});
            $graph.prev('h2')[$show ? 'show' : 'hide']();
            changeHash(!$show, 'r-', true);
        }).prop('checked', false).change();

        // Turn off categories and lines that should be hidden by default
        $('div.graph-category').each(function () {
            var category = $(this).attr('id').substr(categoryIDPrefix.length);
            if (MB.text.Timeline.Category[category].Hide && !(new RegExp('\\+?-?c-' + category + '(?=($|\\+))').test(location.hash))) {
                $(this).prev('.toggler').children('input:checkbox').prop('checked', false).change();
            }
        });
        $('div.graph-control').each(function () {
            var identifier = $(this).attr('id').substr(controlIDPrefix.length);
            if (MB.text.Timeline.Stat(identifier).Hide && !(new RegExp('\\+?-?' + identifier.substr('count.'.length) + '(?=($|\\+))').test(location.hash))) {
                $(this).children('input:checkbox').prop('checked', false).change();
            }
        });

        // Initialize our hash-management variable
        newHash = location.hash;

        // Trigger actually graphing things
        $(window).hashchange();
    }


});
