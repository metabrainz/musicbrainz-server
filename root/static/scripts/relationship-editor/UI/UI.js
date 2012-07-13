/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

(function() {

var UI = RE.UI = {$tbody: $("<tbody></tbody>")};


UI.init = function() {
    this.Dialog.init();
    UI.Buttons.initEvents();

    var url = "/ws/js/release/" + RE.release_gid + "?inc=recordings+rels";
    $("#tracklist").after(this.loading_indicator);

    $.getJSON(url, function(data) {
        UI.renderTracklist(data);
        UI.initCheckboxes();
    });
};


UI.initCheckboxes = function() {

    var $medium_recordings = UI.$tbody.find("input.medium-recordings"),
        $medium_works = UI.$tbody.find("input.medium-works"),
        $recording_tools = $("#batch-recording, #batch-create-works"),
        $work_tools = $("#batch-work"),
        recording_count = {count: 0}, work_count = {count: 0};

    function count_msg($tools, count, counter_str) {
        var msg = (count == 1 ? counter_str[0] : counter_str[1]).replace("{num}", count);
        $tools.next("span.count").text("(" + msg + ")");
        count == 0 ? $tools.addClass("disabled") : $tools.removeClass("disabled");
    }

    function medium($inputs, cls, $tools, counter, counter_str) {
        $inputs.change(function(event) {
            var checked = this.checked,
                count = $(this).parents("tr.subh").nextUntil("tr.subh")
                    .find("td." + cls + " > input[type=checkbox]")
                    .filter(checked ? ":not(:checked)" : ":checked")
                    .prop("checked", checked).length * (checked ? 1 : -1);
            counter.count += count;
            count_msg($tools, counter.count, counter_str);
        });
    }

    function release($inputs, cls) {
        $(UI.checkbox)
            .change(function(event) {
                $inputs.prop("checked", this.checked).change();
            })
            .prependTo("#tracklist th." + cls);
    }

    function range(selector, $tools, counter, counter_str) {
        var last_clicked = null;

        UI.$tbody.on("click", selector, function(event) {
            var count, checked = this.checked;
            if (event.shiftKey && last_clicked && last_clicked != this) {

                var $inputs = $(selector), first = $inputs.index(last_clicked),
                    last = $inputs.index(this);

                count = (first > last
                    ? $inputs.slice(last, first + 1)
                    : $inputs.slice(first, last + 1))
                    .filter(checked ? ":not(:checked)" : ":checked")
                    .prop("checked", checked).length * (checked ? 1 : -1);
            } else {
                count = checked ? 1 : -1;
            }
            counter.count += count;
            count_msg($tools, counter.count, counter_str);
            last_clicked = this;
        });
    }

    medium($medium_recordings, "recording", $recording_tools, recording_count,
           MB.text.RecordingSelection);
    medium($medium_works, "works > div.ar", $work_tools, work_count,
           MB.text.WorkSelection);

    release($medium_recordings, "recordings");
    release($medium_works, "works");

    range("td.recording > input[type=checkbox]", $recording_tools, recording_count,
          MB.text.RecordingSelection);
    range("td.works > div.ar > input[type=checkbox]", $work_tools, work_count,
          MB.text.WorkSelection);
};


UI.checkedRecordings = function() {
    return $.map(UI.$tbody.find("td.recording > input[type=checkbox]:checked"),
        function(input) {return $(input).data("source");});
};


UI.checkedWorks = function() {
    return $.map(UI.$tbody.find("td.works > div.ar > input[type=checkbox]:checked"),
        function(input) {return $(input).data("source");});
};


UI.renderTracklist = function(data) {
    data.type = "release";
    var Buttons = UI.Buttons, release = RE.Entity(data);
    release.$ars = $("#release-rels");

    for (var i = 0; i < data.mediums.length; i++) {
        var medium = data.mediums[i], tracks = medium.tracks;

        UI.$tbody.append(
            $('<tr class="subh"></tr>').append(
                '<td></td>',
                $('<td colspan="2"></td>')
                    .text((medium.format || MB.text.Medium) + " " + medium.position)
                    .prepend($(UI.checkbox).addClass("medium-recordings")),
                $('<td></td>').append($(UI.checkbox).addClass("medium-works"))));

        for (var j = 0; j < tracks.length; j++) {

            var track = tracks[j], rec = track.recording, source, $ars,
                $reccol = $('<td class="recording"></td>'),
                $work_ars = $('<td class="works"></td>');

            rec.type = "recording";
            source = RE.Entity(rec);
            $ars = $('<div class="ars"></div>')
                .append(new Buttons.AddRelationship(source));

            $reccol.append(
                $(UI.checkbox).data("source", source),
                UI.renderEntity(track, "track"),
                " (" + rec.length + ")");

            if (!RE.Util.compareArtistCredits(data.artist_credit, track.artist_credit))
                $reccol.append(" by ", UI.renderArtistCredit(track.artist_credit));

            if (source.$ars === undefined) {
                source.$ars = $ars;
                source.$work_ars = $work_ars;
            } else {
                source.$ars = source.$ars.add($ars);
                source.$work_ars = source.$work_ars.add($work_ars);
            }

            UI.$tbody.append($('<tr class="track"></tr>')
                .addClass(j % 2 == 0 ? "ev" : "")
                .append(
                    $('<td class="pos t"></td>').text(track.number),
                    $reccol.append($ars),
                    $('<td class="midcol"></td>')
                        .append(new Buttons.RelateToWork(source)),
                    $work_ars));

            if (source.relationships.length) {
                var rels = source.relationships, rel;

                for (var i = 0; i < rels.length; i++) {
                    rel = rels[i];
                    rel.cloneInto(rel.type == "recording-work" ? $work_ars : $ars);
                }
            } else {
                RE.parseRelationships(rec, true);
            }
        }
    };
    RE.parseRelationships(data, true);
    release.$ars.append(new RE.UI.Buttons.AddRelationship(release));

    $("#tracklist tbody").replaceWith(UI.$tbody);
    $("#tracklist").next("span.loading").remove();
};


UI.renderWorkRelationships = function(work, added_only) {
    var $container = work.$ars;

    for (var i = 0; i < work.relationships.length; i++) {
        var rel = work.relationships[i];

        if (!added_only || rel.fields.action == "add") {
            rel.cloneInto($container);
        }
    }
    for (var i = 0; i < $container.length; i++) {
        if ($container.eq(i).children("span.add-rel").length == 0) {
            $container.eq(i).append(new UI.Buttons.AddRelationship(work));
        }
    }
};


UI.renderArtistCredit = function(obj) {
    var $span = $("<span></span>");
    for (var i = 0; i < obj.length; i++) {
        var name = obj[i];
        $span.append(this.renderEntity(name.artist), name.joinphrase);
    }
    return $span;
};


UI.renderEntity = function(obj, type) {
    type = type || obj.type;
    var gid = type == "track" ? obj.recording.gid : obj.gid, name;

    var name = type == "url" ? obj.url : obj.name;
    if (type == "url" && name.length > 50) {
        name = name.slice(0, 50) + "...";
    }
    if (!(gid && RE.Util.isMBID(gid))) return name;
    if (type == "track") type = "recording";

    return $("<a></a>").text(name).attr({
        href: "/" + type + "/" + gid, target: "_blank", title: obj.sortname
    });
};


UI.loading_indicator =
    '<span class="loading">' +
        '<img src="/static/images/icons/loading.gif" class="bottom"/> ' +
         MB.text.LoadingRelationships +
    '</span>';


UI.checkbox = '<input type="checkbox"/>&#160;';

})();
