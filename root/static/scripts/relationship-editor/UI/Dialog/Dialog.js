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

var Dialog = RE.UI.Dialog = {
    attributes: [],
    current: null,
    allowed_relations: {
        recording: ["artist", "label", "recording", "release"],
        work:      ["artist", "label", "work"],
        release:   ["artist", "label", "recording", "release"],
    },
}, Fields, LinkType, $w = $(window);


Dialog.init = function() {

    var self = this;

    this.$overlay = $("#overlay");
    this.$dialog =  $("#dialog");

    this.$acname = $("#target input.name");
    this.$acid = $("#target input.id");
    this.$acgid = $("#target input.gid");

    this.$work_name = $("#work-name");
    this.$work_comment = $("#work-comment");
    this.$work_type = $("#work-type_id");
    this.$work_lang = $("#work-language_id");

    this.$ended = $("#ended");

    this.autocomplete = MB.Control.EntityAutocomplete({
        inputs: $("#target span.autocomplete"),
        position: {collision: "fit"},
        entity: "work"
    });

    Fields = this.Fields;
    LinkType = Fields.LinkType;
    LinkType.init();
    Fields.TargetType.init();

    this.beginDate = new Fields.Date();
    this.endDate = new Fields.Date(),
    this.beginDate.$container.appendTo("#begin-date");
    this.endDate.$container.appendTo("#end-date");

    $("#existing-work-button").change(function() {
        $("#target").show();
        $("#new-work, #new-work-msg").hide();
        self.setWidth();
    });

    $("#new-work-button").change(function() {
        $("#target").hide();
        $("#new-work").find("tr").show().end().show();
        $("#new-work-msg").show();
        self.setWidth();
    });

    $("#attrs-help").click(function(event) {
        event.preventDefault();
        $("#attrs").find("div.ar-descr").slideToggle("fast");
    });

    $("#rel-type-help").click(function(event) {
        event.preventDefault();
        var $descr = $("#rel-type").find("div.ar-descr");
        if ($descr.is(":empty")) $descr.hide(); else $descr.slideToggle("fast");
    });

    this.$dialog.find("button.negative").click(function(event) {
        event.preventDefault();
        self.hide();
    });

    this.$dialog.find("button.positive").click(function(event) {
        event.preventDefault();
        self.current.accept();
    });
};


function dumpErrors(errors, $container) {
    var keys = MB.utility.keys(errors), key;
    for (var i = 0; key = keys[i]; i++) {
        typeof errors[key] == "object"
            ? dumpErrors(errors[key], $container)
            : $container.append(errors[key], "<br/>");
    }
}


Dialog.setup = function(source, target_type) {
    Dialog.source = source;
    Dialog.recording_work = source.type == "recording" && target_type == "work";
    Dialog.new_work = Dialog.recording_work &&
        this.relationship && !RE.Util.isMBID(this.relationship.target.gid);

    $("#work-options").toggle(this.recording_work);

    var allowed_targets = this.recording_work
        ? ["work"] : Dialog.allowed_relations[source.type];

    Fields.TargetType.render(allowed_targets, target_type,
        this.relationship || this.recording_work);

    var $source = $("#source").show().find("td.section")
        .text(MB.text.Entity[source.type] + ":")
        .next().empty();

    source.name ? $source.prepend(RE.UI.renderEntity(source)) : $("#source").hide();

    this.$dialog.find(".error").empty();

    function dumpEntityErrors(entity, errors) {
        if (Dialog.relationship.source === entity) {
            dumpErrors(errors, $("#source div.error"));
        } else if (Dialog.new_work) {
            if (errors.name) {
                Dialog.$work_name.next("div.error")
                    .append(errors.name.join("<br/>"));
            }
            if (errors.work_comment) {
                Dialog.$work_comment.next("div.error")
                    .append(errors.work_comment.join("<br/>"));
            }
            if (errors.work_type_id) {
                Dialog.$work_type.next("div.error")
                    .append(errors.work_type_id.join("<br/>"));
            }
            if (errors.work_language_id) {
                Dialog.$work_lang.next("div.error")
                    .append(errors.work_language_id.join("<br/>"));
            }
        } else {
            dumpErrors(errors, $("#target div.error"));
        }
    }

    // populate errors we got from the server (not client-side errors)
    if (this.relationship && this.relationship.has_errors) {
        var fields = this.relationship.fields;

        if (fields.errors && fields.errors.link_type) {
            dumpErrors(fields.errors.link_type, LinkType.$error);
        }
        if (fields.entity.errors) {
            if (fields.entity.errors[0])
                dumpEntityErrors(fields.entity[0], fields.entity.errors[0]);
            if (fields.entity.errors[1])
                dumpEntityErrors(fields.entity[1], fields.entity.errors[1]);
        }
        if (fields.begin_date && fields.begin_date.errors) {
            dumpErrors(fields.begin_date.errors, this.beginDate.$error);
        }
        if (fields.end_date && fields.end_date.errors) {
            dumpErrors(fields.end_date.errors, this.endDate.$error);
        }
        if (fields.ended && fields.errors.ended) {
            dumpErrors(fields.errors.ended, this.$ended.parent().next("div.error"));
        }
        if (this.attributes) {
            for (var i = 0; i < this.attributes.length; i++) {
                var obj = this.attributes[i], field = fields.attrs[obj.attr.name];
                if (field && field.errors) dumpErrors(field.errors, obj.$error);
            }
        }
    }
};


Dialog.setWidth = function() {
    var $hidden = $();
    // the ar-descrs stretch the dialog
    $.each(this.$dialog.find("div.ar-descr, p.msg"), function(i, div) {
        var $div = $(div);
        if ($div.is(":visible")) $hidden = $hidden.add($div.hide());
    });
    this.$dialog.css("max-width", "100%").css("max-width", this.$dialog.width());
    $hidden.show();
    this.position();
};


Dialog.show = function(setup, dontsetwidth) {
    this.setup.apply(this, setup);
    this.$overlay.show();
    // setting top & left before showing prevents the page from jumping
    this.$dialog.css({top: $w.scrollTop(), left: $w.scrollLeft()}).fadeIn("fast");
    if (dontsetwidth !== true) this.setWidth();
    LinkType.$select.focus();
};


Dialog.hide = function() {
    var self = Dialog;

    this.$dialog.fadeOut("fast", function() {
        $("#attrs").empty();
        $("#new-work").hide();
        $("#target").show();
        $("#edits-pending-msg").hide();

        self.autocomplete.clear(true);
        self.$acname.removeClass("error");
        self.$dialog.find(":input").val("");
        self.$dialog.find("input[type=checkbox]").prop("checked", false);
        self.$dialog.find("p.msg").hide();
        self.$dialog.find("div.ar-descr").empty().hide();
    });
    self.$overlay.fadeOut("fast");
    delete self.relationship;
    delete self.source;
    delete self.target_type;
    delete self.recording_work;
    self.attributes.length = 0;
    delete self.posx;
    delete self.posy;
};


Dialog.position = function() {
    var $d = this.$dialog,
        posx = this.posx, posy = this.posy,
        offx = $w.scrollLeft(), offy = $w.scrollTop(),
        wwidth = $w.width(), wheight = $w.height(),
        dwidth = $d.outerWidth(), dheight = $d.outerHeight(),
        centerx = offx + (wwidth / 2), centery = offy + (wheight / 2);

    if (!posx || !posy || wwidth < dwidth) {
        $d.css({
            top: Math.max(offy, centery - dheight),
            left: centerx - (dwidth / 2)
        });
    } else {
        $d.css("left", posx <= centerx ? posx : posx - dwidth);

        var dheight2 = dheight / 2,
            topclear = posy - dheight2 >= offy,
            botclear = posy + dheight2 <= wheight + offy;

        if (topclear && botclear) {
            $d.css("top", posy - dheight2);
        } else if (topclear) {
            $d.css("top", wheight + offy - dheight);
        } else {
            $d.css("top", offy)
        }
    }
};


Dialog.result = function(result) {
    this.$dialog.find(".error").empty();

    var fields = result.fields;
    fields.entity = [];
    fields.link_type = parseInt(LinkType.$select.val(), 10);

    if (!fields.link_type) {
        LinkType.$error.text(MB.text.PleaseSelectARType);
        return;
    }
    var relationship = this.relationship;

    this.source.type == this.target_type && LinkType.direction == "backward"
        ? (fields.direction = LinkType.direction)
        : (delete fields.direction);

    if (!this.recording_work || $("#existing-work-button").is(":checked")) {
        var item = this.autocomplete.currentSelection, target, src;

        if (!(item && this.$acname.hasClass("lookup-performed"))) {
            $("div.error", "#target").text(MB.text.RequiredField);
            return;
        }
        // $.extend removes undefined props for us
        target = RE.Entity($.extend({}, {
            id: item.id,
            gid: item.gid,
            name: item.name,
            sortname: item.sortname || undefined,
            type: this.target_type,
        }));

        src = RE.Util.src(fields.link_type, LinkType.direction);
        fields.entity[1 - src] = target;
        fields.entity[src] = this.source;
    } else {
        var name = $.trim(this.$work_name.val()), id, gid;

        if (!name) {
            this.$work_name.next(".error").text(MB.text.RequiredField);
            return;
        }
        fields.entity[0] = this.source;

        if (relationship && !RE.Util.isMBID(relationship.target.gid)) {
            id = relationship.target.id;
            gid = relationship.target.gid;
        } else {
            id = gid = RE.Util.fakeID();
        }
        fields.entity[1] = RE.Entity({
            id: id, gid: gid, name: name, type: "work",
            work_comment:       $.trim(this.$work_comment.val())  || null,
            work_type_id:     parseInt(this.$work_type.val(), 10) || null,
            work_language_id: parseInt(this.$work_lang.val(), 10) || null,
        });
    }

    fields.attrs = {};
    for (var i = 0; i < this.attributes.length; i++) {
        var obj = this.attributes[i], values = obj.values();

        if (values == null) {
            obj.$error.text(MB.text.RequiredField);
            return;
        } else if (values === 1 || (typeof values == "object" && values.length > 0)) {
            fields.attrs[obj.attr.name] = values;
        }
    }

    $.extend(fields, {
        begin_date: this.beginDate.validate(),
        end_date: this.endDate.validate(),
    });
    if (fields.begin_date === false || fields.end_date === false) return;
    if (this.$ended.is(":checked")) fields.ended = 1;

    return result;
};


var beget = function(o) {
    function F() {};
    F.prototype = o;
    return new F();
};


var AddDialog = RE.UI.AddDialog = beget(Dialog),
    EditDialog = RE.UI.EditDialog = beget(Dialog),
    BatchAddDialog = RE.UI.BatchAddDialog = beget(AddDialog),
    BatchCreateWorksDialog = RE.UI.BatchCreateWorksDialog = beget(BatchAddDialog);


AddDialog.setup = function(source, target_type) {
    Dialog.current = this;
    Dialog.setup.call(this, source, target_type);

    if (this.recording_work) {
        $("#existing-work-button").click().change();
        this.autocomplete.currentSelection = {name: source.name};
        this.$acname.val(source.name);
        this.$work_name.val(source.name);
    }
};


AddDialog.accept = function() {
    var result = {fields: {action: "add"}};

    if (Dialog.result.call(this, result)) {
        RE.processRelationship(result, this.source);
        this.hide();
    }
}


EditDialog.setup = function(relationship, source, target_type) {
    Dialog.current = this;
    Dialog.relationship = relationship;
    Dialog.setup.call(this, source, target_type);

    if (relationship.edits_pending) {
        $("#edits-pending-msg").show().find("a")
            .attr({href: relationship.openEditsSearch(), target: "_blank"});
    }

    var fields = relationship.fields;

    if (Dialog.new_work) {
        $("#new-work-button").click().change();
        this.$work_name.val(relationship.target.name);
        this.$work_comment.val(relationship.target.work_comment);
        this.$work_type.val(relationship.target.work_type_id);
        this.$work_lang.val(relationship.target.work_language_id);
    } else {
        $("#existing-work-button").click().change();
        var target = relationship.target;

        // XXX simulate an autocomplete lookup. ew
        this.autocomplete.term = target.name;
        this.autocomplete.currentSelection = target
        this.autocomplete.selectedItem = null;

        this.$acid.val(target.id);
        this.$acgid.val(target.gid);
        this.$acname.val(target.name)
            .removeClass("error")
            .addClass("lookup-performed")
            .data("lookup-result", target)
            .trigger("lookup-performed", [target]);
    }

    if (fields.begin_date) this.beginDate.fill(fields.begin_date);
    if (fields.end_date) this.endDate.fill(fields.end_date);
    if (fields.ended) this.$ended.prop("checked", true);
};


EditDialog.accept = function() {
    var result = {fields: {}}, relationship = this.relationship;

    if (relationship.fields.id) result.fields.id = relationship.fields.id;
    if (relationship.fields.action == "add") result.fields.action = "add";

    if (Dialog.result.call(this, result)) {
        delete relationship.has_errors;
        relationship.update(result, true);
        this.hide();
    }
}


BatchAddDialog.setup = function(source_type) {
    var source = {type: source_type};
    AddDialog.setup.call(this, source, "artist");
};


BatchAddDialog.show = function(source_type) {

    this.targets = source_type == "recording"
        ? RE.UI.checkedRecordings()
        : RE.UI.checkedWorks();

    if (this.targets.length > 0) {
        Dialog.show.call(this, [source_type], true);
        this.setWidth();
        $("#batch-" + this.source.type + "-msg").show();
    }
};


BatchAddDialog.accept = function(callback) {
    var result;
    for (var i = 0; i < this.targets.length; i++) {
        result = {fields: {action: "add"}};
        Dialog.source = this.targets[i];

        if (!callback || callback.call(this)) {
            if (!Dialog.result.call(this, result)) return;
            RE.processRelationship(result, Dialog.source);
        }
    }
    this.hide();
}


BatchCreateWorksDialog.setup = function() {
    var source = {type: "recording"};
    AddDialog.setup.call(this, source, "work");
};


BatchCreateWorksDialog.show = function() {
    this.targets = RE.UI.checkedRecordings();

    if (this.targets.length > 0) {
        Dialog.show.call(this, ["recording"], true);

        $("#work-options").hide();
        $("#new-work-button").click().change();
        Dialog.$work_name.parents("tr:first").hide();
        this.setWidth();
        $("#batch-create-works-msg").show();
    }
};


BatchCreateWorksDialog.accept = function() {
    BatchAddDialog.accept.call(this, function() {
        var rels = this.source.relationships;
        // check that this recording has no work rels already
        for (var i = 0; i < rels.length; i++) {
            if (rels[i].type == "recording-work") return false;
        }
        this.$work_name.val(this.source.name);
        return true;
    });
}


String.prototype.repeat = function(n) {
    return (new Array(n + 1)).join(this);
};

})();
