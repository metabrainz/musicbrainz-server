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

var Dialog = RE.UI.Dialog, Fields = Dialog.Fields = {};


Fields.Attribute = function(relationship, attr, info) {
    this.relationship = relationship;
    this.info = info;
    this.attr = attr;
    this.$parent = $("#attrs");
    this.$container = $("<div></div>").addClass("ar-attr-" + attr.id);
    this.$error = $('<div class="error"></div>');
    this.$descr = $('<div class="ar-descr"></div>');
    this.render();
};


Fields.Attribute.prototype.render = function() {
    var attr = this.attr;

    this.$container
        .append(
            attr.children ? this.renderSelects() : this.renderCheckbox(),
            this.$error,
            this.$descr.html(attr.descr).hide()
        )
        .appendTo(this.$parent);
};


Fields.Attribute.prototype.renderSelects = function() {

    var field = new Fields.Attribute.Select(this.attr, this.info),
        selects = field.selects, r = this.relationship;

    if (r && r.fields.attrs !== undefined) {
        var values = r.fields.attrs[this.attr.name];

        if (values && values.length) {
            if (selects.length == 0)
                field.addAnother();

            for (var i = 0; i < values.length; i++) {
                selects[selects.length - 1].value = values[i];
                if (i < values.length - 1) field.addAnother();
            }
        }
    }
    return field.$container;
};


Fields.Attribute.prototype.renderCheckbox = function() {

    var checkbox = document.createElement("input");
    checkbox.type = "checkbox";

    var relationship = this.relationship;
    if (relationship && relationship.fields.attrs[this.attr.name] !== undefined)
        checkbox.checked = true;

    return $("<label></label>").append(checkbox, "&#160;", this.attr.name);
};


Fields.Attribute.prototype.values = function() {
    var values = null, min = this.info[0];

    if (this.attr.children) {
        values = $.map(this.$container.find("select"), function(select, i) {
            return select.value ? parseInt(select.value, 10) : null;
        });
        if (min == 1 && values.length == 0) return null;
    } else {
        values = this.$container.find("input[type=checkbox]").is(":checked") ? 1 : 0;
    }
    return values;
};


Fields.Attribute.Select = function(attr, info) {
    this.min = info[0];
    this.max = info[1];

    if (Fields.Attribute.Select.cache[attr.id] === undefined) {
        var select = document.createElement("select");
        select.appendChild(document.createElement("option"));

        var render_options = function(attr, indent) {
            var id;
            for (var i = 0; id = attr.children[i]; i++) {
                var child = RE.attr_map[id],
                    opt = document.createElement("option");

                opt.value = id;
                (opt.dataset = opt.dataset || {}).unaccented = child.unaccented;
                opt.innerHTML = "&#160;&#160;".repeat(indent) + child.name;
                select.appendChild(opt);

                if (child.children)
                    render_options(child, indent + 1);
            }
        };
        render_options(attr, 0);
        Fields.Attribute.Select.cache[attr.id] = select;
    } else {
        var select = Fields.Attribute.Select.cache[attr.id];
    }

    var $select = $(select.cloneNode(true));
    this.$container = $("<div></div>").append(attr.name, "&#160;");

    if (this.max == null) {
        var $remove = $('<button class="rm"></button>')
            .text(MB.text.Remove).click({self: this}, this.remove),
        $add_another = $("<button></button")
            .text(MB.text.AddAnother).click({self: this}, this.addAnother);

        this.$row = $('<div class="attr-select"></div>').append($select, $remove);

        if (attr.name == "instrument")
            $select.after($('<input class="selectFilter"/>')
                .attr("placeholder", MB.text.Search));

        this.$container.append($add_another, "<br/>");
        this.selects = this.$container[0].getElementsByTagName("select");

        if (this.min == 1) {
            this.addAnother();
            this.$container.find("button.rm").attr("disabled", "disabled");
        }
    } else if (this.max == 1) {
        this.$container.append($select);
        this.selects = $select;
    }
};


Fields.Attribute.Select.cache = {};


Fields.Attribute.Select.prototype.remove = function(event) {

    var self = event.data.self;
    $(this).parent().remove();

    if (self.selects.length == self.min)
        self.$container.find("button.rm").attr("disabled", "disabled");
};


Fields.Attribute.Select.prototype.addAnother = function(event) {

    var self = (event && event.data.self) || this;
    self.$row.clone(true).appendTo(self.$container).children("select").focus();

    if (self.selects.length > self.min)
        self.$container.find("button.rm").removeAttr("disabled");
};


Fields.Date = function() {
    this.$container = $(this.template);
    this.$year = this.$container.children("input.year");
    this.$month = this.$container.children("input.month");
    this.$day = this.$container.children("input.day");
    this.$error = this.$container.children("div.error");
};


Fields.Date.prototype.fill = function(date) {
    this.$year.val(date.year);
    this.$month.val(date.month);
    this.$day.val(date.day);
};


Fields.Date.prototype.validate = function() {

    var date = {
        year: $.trim(this.$year.val()),
        month: $.trim(this.$month.val()),
        day: $.trim(this.$day.val()),
    };

    // opera 10 is broken
    if (date.year == "YYYY") date.year = "";
    if (date.month == "MM") date.month = "";
    if (date.day == "DD") date.day = "";

    if (!date.year && !date.month && !date.day)
        return undefined;

    var obj = new Date(date.year, date.month, date.day);
    if (!date.year || (date.day && !date.month) || isNaN(obj.getTime())) {

        this.$error.text(MB.text.InvalidDate);
        return false;
    } else {
        this.$error.empty();

        if (date.year) {
            date.year = parseInt(date.year, 10);
            date.month ? (date.month = parseInt(date.month, 10))
                       : (delete date.month);
            date.day   ? (date.day = parseInt(date.day, 10))
                       : (delete date.day);
            return date;
        }
        return undefined;
    }
};


Fields.Date.prototype.template =
    '<div>' +
        '<input class="year" maxlength="4" placeholder="YYYY" size="4" type="text"/>-' +
        '<input class="month" maxlength="2" placeholder="MM" size="2" type="text"/>-' +
        '<input class="day" maxlength="2" placeholder="DD" size="2" type="text"/>' +
        '<div class="error"></div>' +
    '</div>';


Fields.LinkType = {

    $select: $("<select></select>"),
    $error:  $('<div class="error"></div>'),
    $descr:  $('<div class="ar-descr"></div>').hide(),
    $change_direction: $("<button></button>").text(MB.text.ChangeDirection),

    direction: "forward",
    forward_cache: {},
    backward_cache: {},

    init: function() {
        var self = this;

        this.$change_direction.click(function(event) {
            event.preventDefault();

            if (self.direction == "backward") {
                self.direction = "forward";
                self.render(false, self.$select.val());
            } else if (self.direction == "forward") {
                self.direction = "backward";
                self.render(true, self.$select.val());
            }
            Dialog.setWidth();
        });

        $("#rel-type > td.rel-type")
            .prepend(this.$select).append(this.$error, this.$descr);
    },

    changed: function() {
        var self = Fields.LinkType, $attrs = $("#attrs").empty();
        self.$descr.empty();

        if (this.value) {
            var type_info = RE.type_info[this.value],
                allowed_attrs = type_info.attrs ? MB.utility.keys(type_info.attrs) : [];

            allowed_attrs.sort(function(a, b) {
                return RE.attr_map[a].child_order - RE.attr_map[b].child_order;
            });

            if (type_info.descr) {
                self.$descr.html(type_info.descr)
                    .children("a").attr("target", "_blank");
            } else {
                self.$descr.hide();
            }

            Dialog.attributes.length = 0;

            for (var i = 0; i < allowed_attrs.length; i++) {
                var id = allowed_attrs[i];

                Dialog.attributes.push(new Fields.Attribute(
                    Dialog.relationship, RE.attr_map[id], type_info.attrs[id]));
            }

            $attrs.parent().toggle(allowed_attrs.length > 0);
            self.$error.empty();
        }
        if (Dialog.$dialog.is(":visible")) Dialog.setWidth();
    },

    render: function(reverse, value) {

        var root = RE.type_info_by_entities, relationship = Dialog.relationship,
            cache = reverse ? this.backward_cache : this.forward_cache;

        if (relationship) {
            var type = relationship.type;
        } else {
            var type = Dialog.target_type + "-" + Dialog.source.type;
            if (root[type] === undefined)
                type = Dialog.source.type + "-" + Dialog.target_type;
        }
        root = root[type];
        value = value || (root[0].descr ? root[0].id : root[0].children[0].id);

        if (cache[type] === undefined) {
            var select = document.createElement("select");

            var expand = function(root, indent) {
                var phrase = reverse ? root.reverse_link_phrase : root.link_phrase,
                    opt = document.createElement("option");

                // remove {foo} {bar} junk, unless it's a required attribute.
                // e.g. removing {instrument} from
                //     {additional} {guest} {solo} {instrument}
                // would leave an empty string.

                var orig_phrase = phrase, re = /\{(.*?)(?::(.*?))?\}/g, m, repl;
                while (m = re.exec(orig_phrase)) {
                    var attr = RE.attr_roots[m[1]], info = root.attrs[attr.id];
                    if (info[0] < 1) {
                        repl = (m[2] ? m[2].split("|")[1] : "") || "";
                        phrase = phrase.replace(m[0], repl).replace("  ", " ");
                    }
                }

                opt.value = root.id;
                opt.innerHTML = "&#160;&#160;".repeat(indent) + phrase;
                if (!root.descr) opt.disabled = true;
                select.appendChild(opt);

                if (root.children) {
                    for (var i = 0; i < root.children.length; i++) {
                        var id = root.children[i], child = RE.type_info[id];
                        expand(child, indent + 1);
                    }
                }
            };

            for (var i = 0; i < root.length; i++) expand(root[i], 0);
            cache[type] = select;
        } else {
            var select = cache[type];
        }

        if (this.$select[0] !== select) {
            this.$select.replaceWith(select);
            this.$select = $(select).unbind().change(this.changed);
        }

        this.$change_direction.detach();
        if (Dialog.source.type == Dialog.target_type)
            this.$select.after(this.$change_direction);

        this.$select.val(value).change();
    }
};


Fields.TargetType = {

    init: function() {
        this.$select = $("#target-type").change(function() {

            Dialog.autocomplete.clear();
            Dialog.autocomplete.changeEntity(this.value);
            Dialog.target_type = this.value;

            var link_type = Fields.LinkType.$select.val(),
                direction = "forward";

            if (Dialog.relationship) {
                var rel = Dialog.relationship;
                link_type = rel.fields.link_type;
                if (rel.direction) direction = rel.direction;
            }
            Fields.LinkType.direction = direction;
            var type_info = RE.type_info[link_type],
                reverse = type_info
                    ? (RE.Util.src(type_info.types[0], type_info.types[1], direction) == 1)
                    : false;

            Fields.LinkType.render(reverse, link_type);
        });
    },

    render: function(types, value, disable) {
        this.$select.empty();
        if (!disable) this.$select.removeAttr("disabled");

        for (var i = 0; i < types.length; i++) {
            $("<option></option>")
                .val(types[i])
                .text(MB.text.Entity[types[i]])
                .appendTo(this.$select);
        }
        this.$select.val(value).change();
        if (disable) this.$select.attr("disabled", "disabled");
    }
};

})();
