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

var UI = RE.UI;


RE.Relationship = function(obj, source, compare) {

    var $c = this.$container = $(this.template),
        $remove = new UI.Buttons.Remove(this);

    this.num = Relationship.relcount += 1;
    this.source = source;
    source.relationships.push(this);
    this.fields = {};
    this.update(obj, compare);

    if (this.type == "recording-work") {
        var work = this.target, $ars = $('<div class="ars"></div>');

        work.$ars === undefined
         ? (work.$ars = $ars)
         : (work.$ars = work.$ars.add($ars));

        $c.prepend($(UI.checkbox).data("source", work)).append($remove, $ars);
    } else {
        $c.prepend($remove);
    }
};

var Relationship = RE.Relationship;

Relationship.relcount = 0;


Relationship.prototype.update = function(obj, compare) {
    var self = this, old_target = this.target, create_fields = false, fields,
        $phrase, $entity;

    if (obj) {
        var keys = MB.utility.keys(this.fields);
        for (var i = 0; i < keys.length; i++) {
            if (obj.fields[keys[i]] === undefined) delete this.fields[keys[i]];
        }
        $.extend(this, obj);
    }
    fields = this.fields;
    fields.num = this.num;

    $phrase = this.$container.children("span.link-phrase").empty()
                  .data("relationship", this);
    this.errors ? $phrase.addClass("error-field") : $phrase.removeClass("error-field");

    $entity = this.$container.children("span.entity").empty()
                  .append(UI.renderEntity(this.target));

    this.type = RE.Util.typestr(fields.link_type);

    if (this.type == "recording-work") {
        $phrase.append("(" + this.linkPhrase() + ")");
        $.each($phrase, function() {
            $(this).siblings("span.entity").after(this);
        });
        $entity.append("&#160;");
    } else {
        $phrase.prepend(this.linkPhrase() + ":");
        $entity.prepend("&#160;");
    }

    if (fields.action == "add") {
        fields.direction = this.direction || "forward";
        create_fields = true;
        $phrase.addClass("rel-add");

    } else if (fields.action != "add" && compare) {
        delete fields.action;
        var orig = RE.server_fields[this.type][fields.id];

        if (this.isIdentical(orig)) {
            $phrase.removeClass("rel-edit");
        } else {
            fields.action = "edit";
            create_fields = true;
            $phrase.addClass("rel-edit");
        }
    } else if (fields.action == "remove") {
        create_fields = true;
    }
    this.$container.children("input[type=hidden]").remove();
    if (create_fields) this.createFields();

    // if the user changed a work, we need to request its relationships

    var work = this.target, gid = work.gid;
    if ((old_target === undefined || (old_target && old_target.id != work.id)) &&
        this.type == "recording-work" && RE.works_loading[gid] === undefined) {

        var $c = this.$container;
        work.$ars = $c.children("div.ars").empty();

        if (old_target) {
            old_target.$ars = old_target.$ars.not(work.$ars);
            old_target.removeOrphans();
        }

        if (RE.Util.isMBID(gid)) {
            var $loading = $(UI.loading_indicator).appendTo(work.$ars);
            RE.works_loading[gid] = 1;

            $.get("/ws/js/entity/" + gid + "?inc=rels")
                .success(function(data) {
                    $loading.remove();
                    RE.parseRelationships(data, !old_target);
                    UI.renderWorkRelationships(RE.Entity(data), true);
                    $c.children("input[type=checkbox]").data("source", work);
                })
                .error(function() {
                    $loading.remove();
                    $('<span class="error"></span>')
                        .text(MB.text.ErrorLoadingRelationships)
                        .appendTo(work.$ars);
                })
                .complete(function() {
                    delete RE.works_loading[gid];
                });
        } else {
            work.$ars.append(new UI.Buttons.AddRelationship(work));
            $c.children("input[type=checkbox]").data("source", work);
        }
    }
};


Relationship.prototype.remove = function() {
    // have to empty the children too so that they lose their parent
    this.$container.children().empty().end().empty().remove();
    this.target.removeOrphans();
    this.source.removeOrphans();
    delete RE.relationships[this.type][this.fields.id];
};

// Constructs the link phrase to display for this relationship

Relationship.prototype.linkPhrase = function() {

    var attrs = {}, type_info = RE.type_info[this.fields.link_type],
        phrase = this.source === this.fields.entity[0]
            ? type_info.link_phrase : type_info.reverse_link_phrase;

    if (this.fields.attrs) {
        var names = MB.utility.keys(this.fields.attrs);

        for (var i = 0; i < names.length; i++) {
            var name = names[i], vals = this.fields.attrs[name], str;

            if (typeof vals == "object") {
                vals = vals.slice(0);
                for (var j = vals.length; j > 0;) {
                    vals[--j] = RE.attr_map[vals[j]].name;
                }
                var list = vals.slice(0, -1).join(", ");
                str = (list && list + " & ") + (vals.pop() || "");
            } else {
                str = name;
            }
            attrs[name] = str;
        }
    }
    // FIXME this leaves gaps of whitespace between the attribute names, which
    // you at least can't see in the browser.
    var m;
    while (m = phrase.match(/\{(.*?)(?::(.*?))?\}/)) {
        var replace = attrs[m[1]] !== undefined
            ? (m[2] && m[2].split("|")[0]) || attrs[m[1]]
            : (m[2] && m[2].split("|")[1]) || "";
        phrase = phrase.replace(m[0], replace);
    }
    return $.trim(phrase);
};


Relationship.prototype.fieldName = function(name) {
    return "rel-editor.rels." + this.num + "." + name;
};


Relationship.prototype.removeField = function(name) {
    var name = this.fieldName(name).replace(/\./g, "\\.");
    this.$container.children("input[name=" + name + "]").remove();
};


var createFields = function(prefix, values, doc) {
    var self = this;
    if (RE.Entity.isInstance(values)) {
        values = values.getFields();
    }
    $.each(values, function(index, value) {
        if (value) {
            var newprefix = prefix ? [prefix, index].join(".") : index;

            if (typeof value == "object") {
                createFields.call(self, newprefix, value, doc);
            } else {
                var name = self.fieldName(newprefix),
                    input = document.createElement('input');

                input.type = "hidden";
                input.name = name;
                input.value = value;
                doc.appendChild(input);
            }
        }
    });
    return doc;
};

// creates the hidden input fields for this relationship, and appends them to
// the DOM. we only need to do this when a field changed, obviously.

Relationship.prototype.createFields = function() {
    // documentFragment is noticeably faster here
    var doc = document.createDocumentFragment();
    this.$container.append(createFields.call(this, "", this.fields, doc));
};

// this single function makes the entire relationship editor code considerably
// less complex. it says "copy this relationship into $container, unless it's
// already there." other modules can be indiscriminate and not worry about
// duplicate entities, relationships, and other corner cases

Relationship.prototype.cloneInto = function($container) {
    var $self = this.$container, $parents = $self.parent();

    $container = $container.not($parents);
    if ($container.length == 0) // check if this is a no-op
        return;
    var $target = $container.children("span.add-rel");

    // if we're not even in the DOM yet our life is easy
    if ($self.length == 1 && $parents.length == 0) {
        this.$container = ($target.length
            ? $self.insertBefore($target) : $self.appendTo($container));
    } else {
        // okay, we're duplicating a relationship into a new container
        var $clone = $self.eq(0).clone(true).children("div.ars").empty().end();
        $target.length ? $target.before($clone) : $container.append($clone);
        this.$container = $self.add($clone);
    }
    this.resetARContainers();
    // let's not forget to copy the work's ARs
    if (this.type == "recording-work") {
        UI.renderWorkRelationships(this.target);
    }
};

// $ars always references one or more div.ars - i.e. a container that groups
// relationships for an entity on the page. as we delete or move things around,
// we have to update these.

Relationship.prototype.resetARContainers = function() {
    this.type == "recording-work"
        ? (this.target.$ars = this.$container.children("div.ars"))
        : (this.source.$ars = this.$container.parent());
};

// returns true if this relationship is a "duplicate" of the other.
// doesn't compare attributes

Relationship.prototype.isDuplicate = function(other) {
    var self = this.fields;
    return (self.link_type == other.link_type &&
            self.entity[0] === other.entity[0] &&
            self.entity[1] === other.entity[1]);
};

// returns true if this relationship is identical to the other.
// compares attributes
// at first this function was generic (i.e. didn't have hardcoded attributes,
// and could compare any two objects), but that was problematic because there's
// some cruft in the relationships we don't want to compare

Relationship.prototype.isIdentical = function(other) {
    if (!this.isDuplicate(other)) return false;
    var self = this.fields;

    if (self.id != other.id || self.action != other.action ||
        self.ended != other.ended || self.direction != other.direction ||
        self.date != other.date || (self.date &&
            !isDateIdentical(self.date, other.date))) return false;

    var attrs1 = self.attrs ? MB.utility.keys(self.attrs) : [],
        attrs2 = other.attrs ? MB.utility.keys(other.attrs) : [];

    if ($(attrs1).not(attrs2).length > 0 ||
        $(attrs2).not(attrs1).length > 0) return false;

    for (var i = 0; i < attrs1.length; i++) {
        var val1 = self.attrs[attrs1[i]], val2 = other.attrs[attrs1[i]],
            t1 = typeof val1, t2 = typeof val2;

        if (t1 != t2) return false;
        if (t1 != "number" && !($.isArray(val1) && $.isArray(val2))) return false;
        if (t1 == "number" && val1 != val2) return false;
        if ($(val1).not(val2).length > 0 || $(val2).not(val1).length > 0) return false;
    }
    return true;
};

function isDateIdentical(a, b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
}

Relationship.prototype.template =
    '<div class="ar">' +
        '<span class="link-phrase"></span>' +
        '<span class="entity"></span>'
    '</div>';

})();
