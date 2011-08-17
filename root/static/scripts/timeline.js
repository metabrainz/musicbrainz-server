$(document).ready(function () {
    var categoryIDPrefix = 'category-';
    var controlIDPrefix = 'graph-control-';

    datasets = {};
    var musicbrainzEventsOptions = {musicbrainzEvents: { currentEvent: {}, data: [], enabled: true}}
    var graphOptions = {};
    var overviewOptions = {};
    var graphZoomOptions = {};
    var newHash = '';
    var hashChangeTimeoutId = [];

    // MusicBrainz Events fetching
    $.get('/static/xml/mb_history.xml', function (data) {
        $(data).find('event').each(function() {
            $this = $(this);
            musicbrainzEventsOptions.musicbrainzEvents.data.push({jsDate: Date.parse($this.attr('start')), description: $this.text(), title: $this.attr('title'), link: $this.attr('link')});
        });
        $(window).hashchange();
    }, 'xml');

    function graphData () {
        var alldata =  [];
        var ratedata = [];
        $("#graph-lines div input").filter(":checked").each(function () { 
            if ($(this).parents('div.graph-category').prev('.toggler').children('input:checkbox').attr('checked')) {
                var datasetId = $(this).parent('div.graph-control').attr('id').substr(controlIDPrefix.length);
		if (!datasets[datasetId].data) {
		   $.ajax({url: '../statistics/dataset/' + datasetId,
		       dataType: 'json',
		       success: function(data) {
		           datasets[datasetId].data = data;
			   rateData(datasetId);
			   $(window).hashchange();
	           }});
		} else {
                    alldata.push(datasets[datasetId]);
                    ratedata.push(rateData(datasetId));
		}
            }
        });
        return [alldata, ratedata]
    }
    
    function rateData(datasetId) {
        var dataset = datasets[datasetId];
        var rateHash = $.extend({}, dataset);
        if (!dataset.rateOfChange) {
            datasets[datasetId].rateOfChange = weeklyRate(dataset.data);
            dataset = datasets[datasetId];
        }
        rateHash.data = dataset.rateOfChange.data;
        rateHash.rateBounds = dataset.rateOfChange.bounds;
        return rateHash
    }

    function weeklyRate(data) {
        var newData = [];
        var weekData = [];
        var oneWeek = 1000 * 60 * 60 * 24 * 7;
        var mean = 0;
        var count = 0;

        $.each(data, function(index, value) {
            var oneWeekAgoDate = value[0] - oneWeek;
            var oneWeekAgoValue = null;
            $.each(data, function(innerIndex, innerValue) {
                if (innerValue[0] == oneWeekAgoDate) {
                    oneWeekAgoValue = value[1] - innerValue[1];
                    count++;
                    mean = mean + oneWeekAgoValue;
                }           
            });
            if (oneWeekAgoValue) {
                weekData.push(oneWeekAgoValue);
            }
        });
        mean = mean / count;

        var deviationSum = 0;
        var deviationCount = 0;
        $.each(weekData, function(index, value) {
            toSquare = value - mean;
            deviationCount++;
            deviationSum = deviationSum + toSquare * toSquare;
        });
        var standardDeviation = Math.sqrt(deviationSum / deviationCount);
        var thresholds = {min: mean - 3 * standardDeviation, 
                          max: mean + 3 * standardDeviation};
        var rateBounds = {min: thresholds.max, max: thresholds.min};
        $.each(data, function(index, value) {
            var oneWeekAgoDate = value[0] - oneWeek;
            var oneWeekAgoValue = null;
            $.each(data, function(innerIndex, innerValue) {
                if (innerValue[0] == oneWeekAgoDate) {
                    oneWeekAgoValue = value[1] - innerValue[1];
                }           
            });
            if (oneWeekAgoValue) {
                newData.push([value[0], oneWeekAgoValue]);
                if (oneWeekAgoValue > thresholds.min && 
                      oneWeekAgoValue < thresholds.max) {
                    if (oneWeekAgoValue > rateBounds.max) {
                        rateBounds.max = oneWeekAgoValue;
                    } 
                    if (oneWeekAgoValue < rateBounds.min) {
                        rateBounds.min = oneWeekAgoValue;
                    }
                }
            }
        });
        if (rateBounds.min >= rateBounds.max) {
            rateBounds = {min: null, max: null};
        }

        return {data: newData, bounds: rateBounds};
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

    // do the zooming
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

    // Hover functionality
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

    function changeCurrentEvent(item) {
        musicbrainzEventsOptions.musicbrainzEvents.currentEvent = item;
        plot.changeCurrentEvent(item);
        if (rateplot) { rateplot.changeCurrentEvent(item); }
    }

    function setItemTooltip(item, extra) {
            if (!extra) { extra = '' };
            removeTooltip();
            setCursor();
            var x = item.datapoint[0],
                y = item.datapoint[1],
                date = new Date(parseInt(x));

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

    function clearAll() {
        setCursor();
        removeTooltip();
        previousPoint = null;
        ratePreviousPoint = null;
        changeCurrentEvent({});
    }

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
                setItemTooltip(item, MB.text.Timeline.RateTooltipCloser);
            }
        } 
        else if (rateplot.getEvent(pos)) { setEventTooltip(rateplot, pos); } 
        else { clearAll(); }
    });

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

    function changeHash(minus, newHashPart, hide) {
        if (hashChangeTimeoutId.length > 0 ) { $.each(hashChangeTimeoutId, function (i, Id) { window.clearTimeout(Id); hashChangeTimeoutId.splice(i, 1); }); }

        if (!new RegExp('\\+?-?' + newHashPart + '(?=($|\\+))').test(newHash)) {
            if (hide != minus) {
                newHash = newHash + (newHash != '' ? '+' : '') + (minus ? '-' : '') + newHashPart;
            }
        } else {
            if (hide != minus) {
                newHash = newHash.replace(new RegExp('-?' + newHashPart + '(?=($|\\+))'), (minus ? '-' : '') + newHashPart);
            } else { 
                removeFromHash('-?' + newHashPart);
            }
        }

        hashChangeTimeoutId.push(window.setTimeout(changeHashTimeout, 1000));
    }

    function removeFromHash(toRemove) {
        if (hashChangeTimeoutId.length > 0 ) { $.each(hashChangeTimeoutId, function (i, Id) { window.clearTimeout(Id); hashChangeTimeoutId.splice(i, 1); }); }
        var regex = new RegExp('\\+?' + toRemove + '(?=($|\\+))')
        newHash = newHash.replace(regex , '');
        hashChangeTimeoutId.push(window.setTimeout(changeHashTimeout, 1000));
    }

    function changeHashTimeout() {
            if (hashChangeTimeoutId.length > 0 ) { $.each(hashChangeTimeoutId, function (i, Id) { window.clearTimeout(Id);  }); }
            window.location.hash = newHash;
            hashChangeTimeoutId = [];
    }

    function check(name, toggle, categoryp) {
        if (categoryp) {
            var $checkboxParent = $(jq(categoryIDPrefix + name)).prev('.toggler');
        } else {
            var $checkboxParent = $(jq(controlIDPrefix + 'count.' + name));
        }
        $checkboxParent.children('input:checkbox').attr('checked', toggle).change();
    }

    $(window).hashchange(function () {

            var hash = location.hash.replace( /^#/, '' );
            var queries = hash.split('+');

            $.each(queries, function (index, value) {
                if (value.substr(0,2) == 'g-') {
                    graphZoomOptions = geometryFromHashPart(value);
                } else if (value.substr(0,3) == '-v-') {
                    $('#disable-events-checkbox').attr('checked', false).change();
                } else if (value.substr(0,2) == 'r-') {
                    $('#show-rate-graph').attr('checked', true).change();
                } else {
                    var remove = (value.substr(0,1) == '-');
                    if (remove) {
                        value = value.substr(1);
                    }
                    var category = (value.substr(0,2) == 'c-');
                    if (category) {
                        value = value.substr(2);
                    }
                    check(value, !remove, category);
                }
            });
        resetPlot();
    });


    function resetPlot () {
        var data = graphData();
        var plotOptions = $.extend(true, {}, graphOptions, graphZoomOptions, musicbrainzEventsOptions)
        plot = $.plot($("#graph-container"), data[0], plotOptions);
        plot.triggerRedrawOverlay();

        if ($('#show-rate-graph').attr('checked')) {
            var rateZoomOptions = {yaxis: {min: null, max: null}};
            $.each(data[1], function(index, value) {
               if (rateZoomOptions.yaxis.min == null || value.rateBounds.min < rateZoomOptions.yaxis.min) {
                   rateZoomOptions.yaxis.min = value.rateBounds.min;
               }
               if (rateZoomOptions.yaxis.max == null || value.rateBounds.max > rateZoomOptions.yaxis.max) {
                   rateZoomOptions.yaxis.max = value.rateBounds.max;
               }
            });
            if (rateZoomOptions.yaxis.min) {
                rateZoomOptions.yaxis.min = rateZoomOptions.yaxis.min - Math.abs(rateZoomOptions.yaxis.min * 0.10);
            }
            if (rateZoomOptions.yaxis.max) {
                rateZoomOptions.yaxis.max = rateZoomOptions.yaxis.max + Math.abs(rateZoomOptions.yaxis.max * 0.10);
            }
            var rateOptions = $.extend(true, {}, graphOptions, {xaxis: graphZoomOptions.xaxis, yaxis: rateZoomOptions.yaxis}, musicbrainzEventsOptions);
            rateplot = $.plot($("#rate-of-change-graph"), data[1], rateOptions);
            rateplot.triggerRedrawOverlay();
        } else { rateplot = null; }

        overview = $.plot($('#overview'), data[0], overviewOptions);
    }

    MB.setupGraphing = function (data, goptions, ooptions) {
        datasets = data;
        graphOptions = goptions;
        overviewOptions = ooptions;

        $.each(datasets, function(key, value) { 
            if ($(jq(controlIDPrefix + key)).length == 0) {
                if ($('#' + categoryIDPrefix + value.category).length == 0) {
                    $('#graph-lines').append('<h2 class="toggler"><input id="' + categoryIDPrefix + 'checker-' + value.category + '" type="checkbox" checked /><label for="' + categoryIDPrefix + 'checker-' + value.category + '">' + MB.text.Timeline.Category[value.category].Label + '</label></h2>');
                    $('#graph-lines').append('<div class="graph-category" id="' + categoryIDPrefix + value.category + '"></div>');
                }
                $("#graph-lines #" + categoryIDPrefix + value.category).append('<div class="graph-control" id="' + controlIDPrefix + key + '"><input id="' + controlIDPrefix + 'checker-' + key + '" name="' + controlIDPrefix + key + '" type="checkbox" checked /><label for="' + controlIDPrefix + 'checker-' + key + '"><div class="graph-color-swatch" style="background-color: ' + MB.text.Timeline[key].Color + ';"></div>' + value.label + '</label></div>'); 
            }
        });
        // // Toggle functionality
        $('#graph-lines div input:checkbox').change(function () {
            var $this = $(this);
            var minus = !$this.attr('checked');
            var identifier = $this.parent('div').attr('id').substr(controlIDPrefix.length);
            var newHashPart = identifier.substr('count.'.length);
            var hide = (MB.text.Timeline[identifier].Hide ? true : false);
            changeHash(minus, newHashPart, hide);
            
            if (minus) {
                    $this.siblings('label').children('div.graph-color-swatch').css('background-color', '#ccc');
            } else {
                    $this.siblings('label').children('div.graph-color-swatch').css('background-color',
                            MB.text.Timeline[identifier].Color);
            }

        });
        $('#graph-lines .toggler input:checkbox').change(function () {
            var $this = $(this);

            var categoryId = $this.parent('.toggler').next('div.graph-category').attr('id');
            var minus = !$this.attr('checked');
            var newHashPart = categoryId.replace(new RegExp(categoryIDPrefix), 'c-');
            var hide = (MB.text.Timeline.Category[categoryId.substr(categoryIDPrefix.length)].Hide ? true : false);
            changeHash(minus, newHashPart, hide);
    
            $this.parent('.toggler').next()[minus ? 'hide' : 'show']('slow');
        });

       $('#disable-events-checkbox').change(function () {
           var minus = !$(this).attr('checked');
           musicbrainzEventsOptions.musicbrainzEvents.enabled = !minus;
           changeHash(minus, 'v-', false);
       });

       $('#show-rate-graph').change(function () {
           var $graph = $('#rate-of-change-graph');
           var $show = $(this).attr('checked');
           $graph.css($show ? {position: 'relative', right: ''} : {position: 'absolute', right: 100000});
           $graph.prev('h2')[$show ? 'show' : 'hide']();
           changeHash(!$show, 'r-', true);
       }).attr('checked', false).change();

        $('div.graph-category').each(function () {
            var category = $(this).attr('id').substr(categoryIDPrefix.length);
            if (MB.text.Timeline.Category[category].Hide && !(new RegExp('\\+?-?c-' + category + '(?=($|\\+))').test(location.hash))) {
                $(this).prev('.toggler').children('input:checkbox').attr('checked', false).change();
            }
        });

        $('div.graph-control').each(function () {
            var identifier = $(this).attr('id').substr(controlIDPrefix.length);
            if (MB.text.Timeline[identifier].Hide && !(new RegExp('\\+?-?' + identifier.substr('count.'.length) + '(?=($|\\+))').test(location.hash))) {
                $(this).children('input:checkbox').attr('checked', false).change();
            }
        });

        newHash = location.hash;

        $(window).hashchange();
    }


});
