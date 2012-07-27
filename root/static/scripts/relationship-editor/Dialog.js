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

var UI = RE.UI, Util = RE.Util, $w = $(window),

allowedRelations = {
    recording: ["artist", "label", "recording", "release"],
    work:      ["artist", "label", "work"],
    release:   ["artist", "label", "recording", "release"],
};

// For select attributes and the link type field, we use a custom binding handler
// for performance reasons (the instrument tree is huge, for example). We also
// need to support the unaccented instrument names. the builtin options binding
// doesn't allow anything like that.

ko.bindingHandlers.selectAttribute = (function() {

    var cache = {}, build = function(relationshipAttrs, attr, indent, frag) {

        for (var i = 0, id; id = attr.children[i]; i++) {
            var child = RE.attrMap[id], opt = document.createElement("option"),
                attrs = relationshipAttrs[child.name];

            opt.value = id;
            opt.innerHTML = "&#160;&#160;".repeat(indent) + child.name;
            if (child.unaccented) opt.setAttribute("data-unaccented", child.unaccented);
            if (attrs && attrs.indexOf(id) > -1) opt.selected = true;
            frag.appendChild(opt);

            if (child.children) build(relationshipAttrs, child, indent + 1, frag);
        }
    };
    return {
        init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            var $element = $(element), attr = valueAccessor(),
                frag, multi = (attr.max === null);

            if ((frag = cache[attr.data.name]) === undefined) {
                frag = cache[attr.data.name] = document.createDocumentFragment();
                build(attr.relationship.attributes(), attr.data, 0, frag);
            }
            if (multi) element.multiple = true;

            $element
                .append(frag.cloneNode(true))
                .val(attr.value())
                .change(function() {
                    // for mutiselects, jQuery's val() returns an array
                    var value = $(this).val();
                    attr.value(multi ? $(this).val() : [value]);
                });

            if (multi) $element.multiselect(attr.data.name);
        }
    };
})();


ko.bindingHandlers.targetType = {

    init: function(element) {
        $(element).change(function() {Dialog.targetType(this.value)});
    },
    update: function(element) {
        var $element = $(element), relationship = Dialog.relationship(),
            recordingWork = (relationship.type.peek() == "recording-work"),
            source = relationship.source;

        var types = recordingWork ? ["work"] : allowedRelations[source.type];
        $element.empty();

        $.each(types, function(i, type) {
            $element.append($("<option></option>").val(type).text(MB.text.Entity[type]));
        });
        $element.val(Dialog.targetType());
    }
};


ko.bindingHandlers.linkType = (function() {

    var linkTypesBackward = {}, linkTypesForward = {},
        previousValue, previousDirection, reverse;

    function build(root, indent, frag) {
        var phrase = reverse ? root.reverse_link_phrase : root.link_phrase, opt;

        // remove {foo} {bar} junk, unless it's for a required attribute.
        var orig_phrase = phrase, re = /\{(.*?)(?::(.*?))?\}/g, m, repl;
        while (m = re.exec(orig_phrase)) {
            var attr = RE.attrRoots[m[1]], info = root.attrs[attr.id];
            if (info[0] < 1) {
                repl = (m[2] ? m[2].split("|")[1] : "") || "";
                phrase = phrase.replace(m[0], repl).replace("  ", " ");
            }
        }
        opt = document.createElement("option");
        opt.value = root.id;
        opt.innerHTML = "&#160;&#160;".repeat(indent) + phrase;
        if (!root.descr) opt.disabled = true;
        frag.appendChild(opt);

        if (root.children) {
            for (var i = 0; i < root.children.length; i++) {
                var id = root.children[i], child = RE.typeInfo[id];
                build(child, indent + 1, frag);
            }
        }
    };

    function getOptions(type, cache) {
        var frag, root = RE.typeInfoByEntities[type];
        if (!root) return null;

        if ((frag = cache[type]) === undefined) {
            frag = cache[type] = document.createDocumentFragment();

            for (var i = 0; i < root.length; i++)
                build(root[i], 0, frag);
        }
        return frag.cloneNode(true);
    };

    return {
        update: function(element) {
            var relationship = Dialog.relationship(), value = relationship.link_type(),
                direction = relationship.direction();

            if (value != previousValue || direction != previousDirection) {
                reverse = (direction == "backward");
                var cache = reverse ? linkTypesBackward : linkTypesForward;

                $(element).empty().append(getOptions(relationship.type(), cache)).val(value);
                Dialog.resize();

                previousValue = value;
                previousDirection = direction;
            }
        },
    };
})();


var Dialog = UI.Dialog = {

    MB: MB,
    mode: ko.observable(""),
    attrsHelp: ko.observable(false),

    relationship: (function() {
        var value = ko.observable(null);

        return ko.computed({
            read:  value,
            write: function(newValue) {
                var oldValue = value();

                if (oldValue !== newValue) {
                    // if we cancelled an add dialog, the temporary relationship
                    // must be deleted.
                    if (oldValue && !oldValue.exists) oldValue.remove();

                    value(newValue);
                }
            }
        });
    })(),

    targetType: (function() {
        var value = ko.observable("");

        value.subscribe(function(newValue) {
            var mode = Dialog.mode();

            if (mode == "add" || /^batch\.(recording|work)$/.test(mode)) {
                var relationship = Dialog.relationship();

                // reset the current target entity
                var name = relationship.target().name(),
                    target = Util.tempEntity(newValue);

                target.name(name);
                relationship.target(target);
            }
        });

        value.subscribe(function(newValue) {
            if (!Dialog.autocomplete) return;

            Dialog.autocomplete.clear();
            Dialog.autocomplete.changeEntity(newValue);
            Dialog.$autocomplete.find("input.name").removeClass("error");
        });

        return value;
    })(),

    newWork: (function() {
        var value = ko.observable(null);

        value.subscribe(function(newValue) {
            var currentTarget = Dialog.relationship().target();

            if (newValue) {
                // we only want to do this when we *started* with an existing work
                if (Util.isMBID(currentTarget.gid)) {
                    Dialog.previousWork = currentTarget;
                    // wait for other newWork subscriptions to catch up
                    setTimeout(function() {Dialog.initNewWork(currentTarget.name())}, 0);
                }
            } else if (Dialog.previousWork) {
                Dialog.relationship().target(Dialog.previousWork);
                Dialog.previousWork = currentTarget;
            }
        });

        return value;
    })(),

    init: function() {
        // this is used as an "empty" state when the dialog is hidden, so that
        // none of the bindings error out.
        this.emptyRelationship = RE.Relationship({
            source: Util.tempEntity("recording"),
            target: Util.tempEntity("work"),
        }, false);

        this.relationship(this.emptyRelationship);

        this.$overlay = $("#overlay");
        this.$dialog =  $("#dialog");

        RE.dialogViewModel = ko.observable(this);

        ko.applyBindings(RE.dialogViewModel, this.$dialog[0]);
    },

    initAutocomplete: function() {
        var dlg = Dialog, relationship = dlg.relationship.peek(),
            target = relationship.target.peek();

        dlg.$autocomplete = $("#autocomplete")
            .bind("lookup-performed", function(event, data) {
                var target = dlg.relationship.peek().target;
                data.type = target.peek().type;
                target(RE.Entity(data));
            });

        dlg.autocomplete = MB.Control.EntityAutocomplete({
            inputs: dlg.$autocomplete,
            position: {collision: "fit"},
            entity: target.type
        });

        if (dlg.mode() == "edit") {
            dlg.autocomplete.term = target.name();
            dlg.autocomplete.currentSelection = target;
            dlg.autocomplete.selectedItem = null;

            dlg.$autocomplete.find("input.name")
                .removeClass("error")
                .addClass("lookup-performed")
                .data("lookup-result", target)
                .val(target.name());

        } else if (relationship.type() == "recording-work") {

            var name = relationship.source.name.peek();
            dlg.autocomplete.term = name;
            dlg.autocomplete.selectedItem = null;
            dlg.$autocomplete.find("input.name").val(name);
            target.name(name);
        }
    },

    initWorkAutocomplete: function() {
        var dlg = Dialog, $workName = $("#work-name");

        $workName.autocomplete({
            source: function(request, response) {
                var term = request.term.toLowerCase(), data = [];

                for (var id in RE.newWorks) {
                    var work = RE.newWorks[id], name = work.name.peek(),
                        lower = name.toLowerCase();

                    if (work === dlg.relationship.peek().target.peek())
                        continue;
                    if (lower.lastIndexOf(term, 0) === 0)
                        data.push({label: name, value: name, work: work});
                }
                response(data);
            },
            select: function(event, ui) {
                $workName.addClass("lookup-performed");
                dlg.relationship.peek().target(ui.item.work);
                Dialog.initialNewWork = ui.item.work;
            },
            delay: 0
        });

        if (dlg.mode.peek() == "edit") $workName.addClass("lookup-performed");
    },

    workNameChanged: function(data, event) {
        if (!event.target.value) Dialog.initNewWork("");
    },

    initNewWork: function(name) {
        $("#work-name").removeClass("lookup-performed");

        var observable = Dialog.relationship().target,
            oldWork = observable.peek(), newWork,
            obj = ko.mapping.toJS(oldWork);

        obj.id = obj.gid = Util.ID();
        obj.name = name;
        newWork = RE.Entity(obj);
        observable(newWork);

        // restore original state of old work, if it's still being used elsewhere
        if (oldWork.refcount > 0 && Dialog.initialNewWork &&
            Dialog.initialNewWork.gid === oldWork.gid) {

            ko.mapping.fromJS(Dialog.initialNewWork, oldWork);
        }
        Dialog.initialNewWork = obj;
    },

    show: function() {
        // important: objects down the prototype chain should set "this"
        RE.dialogViewModel(this);

        this.$overlay.fadeIn("fast");

        // prevents the page from jumping. these will be adjusted in resize().
        this.$dialog.css({top: $w.scrollTop(), left: $w.scrollLeft()}).fadeIn("fast");
        this.resize();

        this.newWork.peek() ? this.initWorkAutocomplete() : this.initAutocomplete();
    },

    hide: function(callback) {
        // note: this is called by the afterRender binding. Also, delete doesn't
        // affect the prototype chain anyway, so reference Dialog directly.
        var dlg = Dialog;

        delete dlg.targets;
        delete dlg.posx;
        delete dlg.posy;
        delete dlg.initialNewWork;
        delete dlg.previousWork;
        delete dlg.autocomplete;
        delete dlg.$autocomplete;

        if ($.isFunction(callback)) callback.call(dlg);

        dlg.$dialog.fadeOut("fast", function() {
            dlg.relationship(dlg.emptyRelationship);
            dlg.newWork(null);
        });

        dlg.$overlay.fadeOut("fast");
    },

    accept: function() {},

    showAttributesHelp: function() {
        this.attrsHelp(!this.attrsHelp());
    },

    resize: function() {
        // note: this is called by the afterRender binding.
        var dlg = Dialog, $d = dlg.$dialog, $hidden;
        if (!$d.is(":visible")) return;

        // we want the dialog's size to "fit" the contents. the ar-descrs stretch
        // the dialog 100%, making this impossible; hide them first.
        $hidden = $();

        $.each($d.find("div.ar-descr, p.msg"), function(i, div) {
            var $div = $(div);
            if ($div.is(":visible")) $hidden = $hidden.add($div.hide());
        });

        $d.css("max-width", "100%").css("max-width", $d.width());
        $hidden.show();

        var offx = $w.scrollLeft(), offy = $w.scrollTop(),
            wwidth = $w.width(), wheight = $w.height(),
            dwidth = $d.outerWidth(), dheight = $d.outerHeight(),
            centerx = offx + (wwidth / 2), centery = offy + (wheight / 2);

        if (!dlg.posx || !dlg.posy || wwidth < dwidth) {
            $d.css({top: Math.max(offy, centery - dheight), left: centerx - (dwidth / 2)});

        } else {
            $d.css("left", dlg.posx <= centerx ? dlg.posx : dlg.posx - dwidth);

            var dheight2 = dheight / 2, topclear = dlg.posy - dheight2 >= offy,
                botclear = dlg.posy + dheight2 <= wheight + offy;

            (topclear && botclear)
                ? $d.css("top", dlg.posy - dheight2)
                : $d.css("top", topclear ? (wheight + offy - dheight) : offy);
        }
    }
};


Dialog.LinkType = {
    help: ko.observable(false),

    descr: ko.computed({
        read: function() {
            var info = RE.typeInfo[Dialog.relationship().link_type()];
            return info ? info.descr : "";
        },
        // at the time this is declared, Dialog.relationship() is not set,
        // and can't be because relationships require the link type info from
        // the server. so defer this.
        deferEvaluation: true
    }),

    changeDirection: function() {
        var direction = Dialog.relationship().direction;
        direction(direction() == "backward" ? "forward" : "backward");
        Dialog.resize();
    },

    toggleHelp: function() {
        Dialog.LinkType.help(!Dialog.LinkType.help());
    }
};


Dialog.attributes = (function() {
    var value = ko.observable([]), build, sub;

    var Attribute = function(attr, info) {
        this.relationship = Dialog.relationship();
        this.value = this.relationship.attributes()[attr.name];
        this.data = attr;
        this.min = info[0];
        this.max = info[1];
        this.type = attr.children ? "select" : "boolean";
    }

    build = function(linkType) {
        var attributes = [], typeInfo = RE.typeInfo[linkType], id;
        if (!typeInfo) return attributes;

        var allowedAttrs = typeInfo.attrs ? MB.utility.keys(typeInfo.attrs) : [];

        allowedAttrs.sort(function(a, b) {
            return RE.attrMap[a].child_order - RE.attrMap[b].child_order;
        });

        for (var i = 0; id = allowedAttrs[i]; i++)
            attributes.push(new Attribute(RE.attrMap[id], typeInfo.attrs[id]));

        value(attributes);
    };

    Dialog.relationship.subscribe(function(relationship) {
        if (sub) sub.dispose();
        build(relationship.link_type());
        sub = relationship.link_type.subscribe(build);
    });
    return value;
})();


var beget = function(o) {
    function F() {};
    F.prototype = o;
    return new F;
};


UI.AddDialog = beget(Dialog);

UI.AddDialog.show = function(options) {
    var target = options.target, source = options.source,
        relationship = RE.Relationship({
            source: source, target: target, action: "add"}, false);

    this.mode(options.mode || "add");
    this.relationship(relationship);
    this.targetType(target.type);
    this.newWork(options.newWork || false);

    Dialog.show.call(this);
}

UI.AddDialog.accept = function() {
    var relationship = this.relationship();

    if (!relationship.hasErrors()) {
        if (!relationship.source.mergeRelationship(relationship)) {
            relationship.show();
        }
        Dialog.hide();
    }
};


UI.EditDialog = beget(Dialog);

UI.EditDialog.show = function(relationship) {
    var dlg = Dialog, target = relationship.target();

    dlg.mode("edit");
    dlg.newWork(target.type == "work" && !RE.Util.isMBID(target.gid));
    dlg.originalRelationship = ko.mapping.toJS(relationship);

    // saving the relationship isn't sufficient, because the target is excluded
    // from the Relationship mapping options. for new works, we have to copy
    // everything, because the user can edit it - i.e., we have to revert their
    // changes to the work if they cancel.
    dlg.originalTarget = dlg.newWork() ? ko.mapping.toJS(target) : target;

    dlg.relationship(relationship);
    dlg.targetType(target.type);

    if (dlg.newWork()) dlg.initialNewWork = dlg.originalTarget;

    dlg.show.call(this);
};

UI.EditDialog.hide = function(cancel) {
    Dialog.hide(function() {
        if (cancel !== false) {
            ko.mapping.fromJS(this.originalRelationship, this.relationship());
            var target = this.relationship().target;

            if (target.peek() !== this.originalTarget) {
                RE.Entity.isInstance(this.originalTarget)
                    ? target(this.originalTarget)
                    : ko.mapping.fromJS(this.originalTarget, target.peek());
            }
        }
        delete Dialog.originalRelationship;
        delete Dialog.originalTarget;
    });
};

UI.EditDialog.accept = function() {
    var relationship = Dialog.relationship();

    if (!relationship.hasErrors()) {
        delete Dialog.originalRelationship;

        UI.EditDialog.hide(false);
    }
};


var BatchRelationshipDialog = beget(UI.AddDialog);

BatchRelationshipDialog.accept = function(callback) {
    var relationship = Dialog.relationship();
    if (relationship.hasErrors()) return;

    var model = ko.mapping.toJS(relationship),
        hasCallback = $.isFunction(callback),
        targets = Dialog.targets;

    model.target = relationship.target();

    // trying to create and render a ton of relationships all at once is *slow*.
    // this is designed to not do that. each relationship promises to create
    // the next one once it's done rendering itself. this is called back in
    // RelationshipEditor.js -> UI.release.addRelationship.

    function createRelationship(index) {

        return function() {
            var target = targets[index], next = targets[index + 1], promise;

            model.source = target;
            delete model.id;

            if (next) promise = createRelationship(index + 1);

            if (!hasCallback || callback(model)) {
                var newRelationship = RE.Relationship(model, true);

                if (newRelationship) {

                    newRelationship.promise = promise;
                    newRelationship.show();

                } else if (promise) promise();

            } else if (promise) promise();
        };
    };

    createRelationship(0)();
    Dialog.hide();
};


UI.BatchRecordingRelationshipDialog = beget(BatchRelationshipDialog);

UI.BatchRecordingRelationshipDialog.show = function() {
    Dialog.targets = UI.checkedRecordings();
    if (Dialog.targets.length > 0) {

        UI.AddDialog.show.call(this, {
            source: Util.tempEntity("recording"), target: Util.tempEntity("artist"),
            mode: "batch.recording"
        });
    }
};


UI.BatchWorkRelationshipDialog = beget(BatchRelationshipDialog);

UI.BatchWorkRelationshipDialog.show = function() {
    Dialog.targets = UI.checkedWorks();
    if (Dialog.targets.length > 0) {

        UI.AddDialog.show.call(this, {
            source: Util.tempEntity("work"), target: Util.tempEntity("artist"),
            mode: "batch.work"
        });
    }
};


UI.BatchCreateWorksDialog = beget(BatchRelationshipDialog);

UI.BatchCreateWorksDialog.show = function() {
    Dialog.targets = UI.checkedRecordings();

    if (Dialog.targets.length > 0) {
        var target = Util.tempEntity("work");

        // the user can't edit the work name in this dialog (the names are
        // taken from the recordings), but this has to be set to something
        // so that validation passes.
        target.name("foo");

        UI.AddDialog.show.call(this, {
            source: Util.tempEntity("recording"), target: target,
            mode: "batch.create.works", newWork: true
        });
    }
};

UI.BatchCreateWorksDialog.accept = function() {
    BatchRelationshipDialog.accept.call(this, function(obj) {

        // check that this recording has no work rels already
        if (obj.source.performanceRelationships.peek().length > 0)
            return false;

        var newWork = ko.mapping.toJS(obj.target);

        newWork.id = newWork.gid = Util.ID();
        newWork.name = obj.source.name();

        obj.target = RE.Entity(newWork);
        return true;
    });
};


String.prototype.repeat = function(n) {
    return (new Array(n + 1)).join(this);
};

})();
