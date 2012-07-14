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

var UI = RE.UI = {};


UI.init = function() {
    this.$tbody = $("#tracklist tbody");
    this.Dialog.init();
    this.Buttons.initEvents();

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

    function count($inputs) {
        var src = {}, count = 0;
        for (var i = 0; i < $inputs.length; i++) {
            var id = $inputs.eq(i).data("source").id;
            if (src[id] === undefined) {
                count += 1;
                src[id] = 1;
            }
        }
        return count;
    }

    function count_msg($tools, count, counter_str) {
        var msg = (count == 1 ? counter_str[0] : counter_str[1]).replace("{num}", count);
        $tools.next("span.count").text("(" + msg + ")");
        count == 0 ? $tools.addClass("disabled") : $tools.removeClass("disabled");
    }

    function medium($inputs, selector, $tools, counter, counter_str) {
        $inputs.change(function(event) {
            var checked = this.checked,
                $changed = $(this).parents("tr.subh").nextUntil("tr.subh")
                    .find(selector).filter(checked ? ":not(:checked)" : ":checked")
                    .prop("checked", checked);
            counter.count += count($changed) * (checked ? 1 : -1);
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
            var checked = this.checked, $inputs = $(selector, UI.$tbody);
            if (event.shiftKey && last_clicked && last_clicked != this) {
                var first = $inputs.index(last_clicked), last = $inputs.index(this);

                (first > last
                    ? $inputs.slice(last, first + 1)
                    : $inputs.slice(first, last + 1))
                    .prop("checked", checked);
            }
            counter.count = count($inputs.filter(":checked"));
            count_msg($tools, counter.count, counter_str);
            last_clicked = this;
        });
    }

    var recording_selector = "td.recording > input[type=checkbox]",
        work_selector = "td.works > div.ar > input[type=checkbox]";

    medium($medium_recordings, recording_selector, $recording_tools, recording_count, MB.text.RecordingSelection);
    medium($medium_works, work_selector, $work_tools, work_count, MB.text.WorkSelection);

    release($medium_recordings, "recordings");
    release($medium_works, "works");

    range(recording_selector, $recording_tools, recording_count, MB.text.RecordingSelection);
    range(work_selector, $work_tools, work_count, MB.text.WorkSelection);
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
    var Buttons = UI.Buttons, release = RE.Entity(data),
        frag = document.createDocumentFragment();
    release.$ars = $("#release-rels");

    // minimal jquery zone!
    // rendering large releases is slow enough; native createElement calls make
    // a noticeable difference

    for (var i = 0; i < data.mediums.length; i++) {
        var medium = data.mediums[i], tracks = medium.tracks, tr, td;

        tr = document.createElement("tr");
        tr.className = "subh";
        tr.appendChild(document.createElement("td"));
        td = document.createElement("td");
        td.colSpan = 2;
        td.appendChild($(UI.checkbox).addClass("medium-recordings")[0]);
        td.appendChild(document.createTextNode(
            (medium.format || MB.text.Medium) + " " + medium.position));
        tr.appendChild(td);
        td = document.createElement("td");
        td.appendChild($(UI.checkbox).addClass("medium-works")[0]);
        tr.appendChild(td);
        frag.appendChild(tr);

        for (var j = 0; j < tracks.length; j++) {

            var track = tracks[j], rec = track.recording, source, ars, work_ars;

            rec.type = "recording";
            source = RE.Entity(rec);
            ars = document.createElement("div");
            ars.className = "ars";
            ars.appendChild(new Buttons.AddRelationship(source)[0]);

            var rcol = document.createElement("td");
            rcol.className = "recording";
            rcol.appendChild($(UI.checkbox).data("source", source)[0]);
            rcol.appendChild(UI.renderEntity(track, "track"));
            rcol.appendChild(document.createTextNode(" (" + rec.length + ")"));

            if (!RE.Util.compareArtistCredits(data.artist_credit, track.artist_credit)) {
                rcol.appendChild(document.createTextNode(" by "));
                rcol.appendChild(UI.renderArtistCredit(track.artist_credit));
            }

            rcol.appendChild(ars);
            work_ars = document.createElement("td");
            work_ars.className = "works";

            if (source.$ars === undefined) {
                source.$ars = $(ars);
                source.$work_ars = $(work_ars);
            } else {
                source.$ars = source.$ars.add(ars);
                source.$work_ars = source.$work_ars.add(work_ars);
            }

            tr = document.createElement("tr");
            tr.className = "track" + (j % 2 == 0 ? " ev" : "");
            td = document.createElement("td");
            td.className = "pos t";
            td.appendChild(document.createTextNode(track.number));
            tr.appendChild(td);
            tr.appendChild(rcol);
            td = document.createElement("td");
            td.className = "midcol";
            td.appendChild(new Buttons.RelateToWork(source)[0])
            tr.appendChild(td);
            tr.appendChild(work_ars);
            frag.appendChild(tr);

            if (source.relationships.length) {
                var rels = source.relationships, rel;

                for (var i = 0; i < rels.length; i++) {
                    rel = rels[i];
                    rel.cloneInto(rel.type == "recording-work" ? $(work_ars) : $(ars));
                }
            } else {
                RE.parseRelationships(rec, true);
            }
        }
    };
    RE.parseRelationships(data, true);
    release.$ars.append(new RE.UI.Buttons.AddRelationship(release));

    UI.$tbody[0].appendChild(frag);
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
    var span = document.createElement("span");
    for (var i = 0; i < obj.length; i++) {
        var name = obj[i];
        span.appendChild(this.renderEntity(name.artist));
        span.appendChild(document.createTextNode(name.joinphrase));
    }
    return span;
};


UI.renderEntity = function(obj, type) {
    type = type || obj.type;
    var gid = type == "track" ? obj.recording.gid : obj.gid, name, link;

    name = type == "url" ? obj.url : obj.name;
    if (type == "url" && name.length > 50) {
        name = name.slice(0, 50) + "...";
    }
    name = document.createTextNode(name);
    if (!(gid && RE.Util.isMBID(gid))) return name;
    if (type == "track") type = "recording";

    link = document.createElement("a");
    link.appendChild(name);
    link.href = "/" + type + "/" + gid;
    link.target = "_blank";
    link.title = obj.sortname;
    return link;
};


UI.loading_indicator =
    '<span class="loading">' +
        '<img src="/static/images/icons/loading.gif" class="bottom"/> ' +
         MB.text.LoadingRelationships +
    '</span>';


UI.checkbox = '<input type="checkbox"/>&#160;';

})();
