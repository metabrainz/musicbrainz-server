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

MB.RelationshipEditor = (function(RE) {

var UI = RE.UI = RE.UI || {}, Util = RE.Util = RE.Util || {}, $w = $(window);

// For select attributes and the link type field, we use a custom binding handler
// for performance reasons (the instrument tree is huge, for example). We also
// need to support the unaccented instrument names. the builtin options binding
// doesn't allow anything like that.

ko.bindingHandlers.selectAttribute = (function() {

    function build(relationshipAttrs, attr, indent, doc) {

        for (var i = 0, id; id = attr.children[i]; i++) {
            var child = RE.attrMap[id], opt = document.createElement("option"),
                attrs = relationshipAttrs[child.name];

            opt.value = id;
            opt.innerHTML = _.repeat("&#160;&#160;", indent) + child.name;
            if (child.unaccented) opt.setAttribute("data-unaccented", child.unaccented);
            if (attrs && attrs.indexOf(id) > -1) opt.selected = true;
            doc.appendChild(opt);

            if (child.children) build(relationshipAttrs, child, indent + 1, doc);
        }
    }

    var getOptions = _.memoize(function(attr) {
        var doc = document.createDocumentFragment();
        build(attr.relationship.attributes(), attr.data, 0, doc);
        return doc;

    }, function(attr) {return attr.data.name});

    return {
        init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
            var $element = $(element), attr = valueAccessor(), multi = (attr.max === null);
            if (multi) element.multiple = true;

            $element.append(getOptions(attr).cloneNode(true)).val(attr.value())
                .change(function() {
                    // for mutiselects, jQuery's val() returns an array
                    var value = $(this).val();
                    attr.value(multi ? $(this).val() : [value]);
                });

            if (multi) {
                var id = attr.data.id, placeholder = "";
                if (id == 14) placeholder = MB.text.FocusInstrument;
                if (id == 3) placeholder = MB.text.FocusVocal;
                $element.multiselect(placeholder, id);
            }
        }
    };
}());


ko.bindingHandlers.linkType = (function() {

    var previousType, previousDirection;

    function build(root, indent, reverse, doc) {
        var phrase = reverse ? root.reverse_link_phrase : root.link_phrase;

        // remove {foo} {bar} junk, unless it's for a required attribute.
        var orig_phrase = phrase, re = /\{(.*?)(?::(.*?))?\}/g, m, repl;
        while (m = re.exec(orig_phrase)) {
            var attr = RE.attrRoots[m[1]], info = root.attrs[attr.id];
            if (info[0] < 1) {
                repl = (m[2] ? m[2].split("|")[1] : "") || "";
                phrase = phrase.replace(m[0], repl);
            }
        }
        var opt = document.createElement("option");
        opt.value = root.id;
        opt.innerHTML = _.repeat("&#160;&#160;", indent) + _.clean(phrase);
        root.descr || (opt.disabled = true);
        doc.appendChild(opt);

        root.children && $.each(root.children, function(i, id) {
            build(RE.typeInfo[id], indent + 1, reverse, doc);
        });
    };

    var getOptions = _.memoize(function(type, direction) {
        var reverse = (direction == "backward"), doc = document.createDocumentFragment();

        $.each(RE.typeInfoByEntities[type], function(i, root) {
            build(root, 0, reverse, doc);
        });
        return doc;
    }, function(type, direction) {return type + "-" + direction});

    return {
        update: function(element) {
            var relationship = Dialog.relationship(), type = relationship.type(),
                direction = relationship.direction();

            if (type != previousType || direction != previousDirection) {
                var doc = getOptions(relationship.type(), direction).cloneNode(true);

                $(element).empty().append(doc).val(relationship.link_type());
                Dialog.resize();

                previousType = type;
                previousDirection = direction;
            }
        },
    };
}());


ko.bindingHandlers.targetType = (function() {

    var allowedRelations = {
        recording: ["artist", "label", "recording", "release"],
        work:      ["artist", "label", "work"],
        release:   ["artist", "label", "recording", "release"],
    };

    function change() {
        var mode = Dialog.mode();
        if (!(mode == "add" || /^batch\.(recording|work)$/.test(mode))) return;

        var relationship = Dialog.relationship.peek(), ac = Dialog.autocomplete,
            name = relationship.target().name(), target = Util.tempEntity(this.value);

        // reset the current target entity
        target.name(name);
        relationship.target(target);
        relationship.target.error("");

        if (ac) {
            ac.clear();
            ac.changeEntity(this.value);
            Dialog.$autocomplete.find("input.name").removeClass("error");
        }
    }

    return {
        init: function(element) {
            var $element = $(element).change(change), relationship = Dialog.relationship(),
                types = (relationship.type.peek() == "recording-work")
                    ? ["work"] : allowedRelations[relationship.source.type];

            $element.empty();
            $.each(types, function(i, type) {
                $element.append($("<option></option>").val(type).text(MB.text.Entity[type]));
            });
            $element.val(relationship.target.peek().type);
        }
    };
}());


ko.bindingHandlers.autocomplete = {
    init: function(element) {
        var $autocomplete = Dialog.$autocomplete = $(element), autocomplete,
            $name = $autocomplete.find("input.name"), relationship = Dialog.relationship,
            target = relationship.peek().target.peek();

        $autocomplete.on("lookup-performed", function(event, data) {
            var target = relationship.peek().target;
            data.type = target.peek().type;
            target(RE.Entity(data));
        });

        autocomplete = MB.Control.EntityAutocomplete({
            inputs: $autocomplete,
            position: {collision: "fit"},
            entity: target.type
        });

        var name = target.name.peek();
        autocomplete.term = name;
        autocomplete.selectedItem = null;
        $name.removeClass("error lookup-performed").val(name);

        if (Dialog.mode() == "edit") {
            autocomplete.currentSelection = null;
            $name.addClass("lookup-performed").data("lookup-result", target);
        }

        ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
            $autocomplete.autocomplete("destroy");
        });
    }
};


ko.bindingHandlers.workName = (function() {

    function setWork(work) {
        $("#work-name").addClass("lookup-performed");
        Dialog.relationship.peek().target(work);
        Dialog.initialNewWork = work;
    }

    var autocompleteOptions = {
        source: function(request, response) {
            var term = request.term.toLowerCase(), data = [];

            for (var id in RE.newWorks) {
                var work = RE.newWorks[id], name = work.name.peek(),
                    lower = name.toLowerCase();

                if (work === Dialog.relationship.peek().target.peek()) continue;
                if (_.startsWith(lower, term))
                    data.push({label: name, value: name, work: work});
            }
            response(data);
        },
        select: function(event, ui) {setWork(ui.item.work)},
        delay: 0
    };

    function input() {
        // if the user clears the work field, initiate a new work instead
        // of editing the existing one.
        this.value
            ? Dialog.relationship.peek().target.peek().name(this.value)
            : Dialog.initNewWork("");
    }

    return {
        init: function(element) {
            var $workName = $(element)
                .on("input", input).on("set-work", function(event, work) {setWork(work)})
                .autocomplete(autocompleteOptions);
        },
        update: function(element, valueAccessor) {
            var relationship = ko.utils.unwrapObservable(valueAccessor());
            $(element).val(relationship.target().name.peek());
        }
    };
}());


var Dialog = UI.Dialog = {

    MB: MB,
    mode: ko.observable(""),
    attrsHelp: ko.observable(false),

    relationship: (function() {
        var value = ko.observable(null);

        return ko.computed({
            read: value,
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
    }()),

    newWork: (function() {
        var value = ko.observable(null);

        value.subscribe(function(newValue) {
            var currentTarget = Dialog.relationship().target();

            if (newValue) {
                // we only want to do this when we *started* with an existing work
                if (Util.isMBID(currentTarget.gid)) {
                    Dialog.previousWork = currentTarget;
                    // wait for other newWork subscriptions to catch up
                    _.defer(Dialog.initNewWork, currentTarget.name());
                }
            } else if (Dialog.previousWork) {
                Dialog.relationship().target(Dialog.previousWork);
                Dialog.previousWork = currentTarget;
            }
        });

        return value;
    }()),

    init: function() {
        // this is used as an "empty" state when the dialog is hidden, so that
        // none of the bindings error out.
        this.emptyRelationship = RE.Relationship({
            source: Util.tempEntity("recording"),
            target: Util.tempEntity("artist"),
        }, false);

        this.relationship(this.emptyRelationship);

        // there are three separate "forms" that the user can be editing: the
        // entity autocomplete, the URL field (with cleanup handlers), or the
        // new work fields. in the template, we use "editor" to decide which to
        // display. we have a separate observable to do this because depending
        // on multiple observables causes the "if" bindings to needlessly
        // re-render (and execute all associated binding handlers) multiple
        // times, while this doesn't.
        this.editor = (function() {
            var value = ko.observable(null);

            ko.computed(function() {
                var relationship = Dialog.relationship();

                if (relationship === Dialog.emptyRelationship) {
                    value(null);
                } else if (Dialog.newWork()) {
                    value("new.work");
                } else {
                    value("entity");
                }
            });
            return value;
        }());

        this.$overlay = $("#overlay");
        this.$dialog =  $("#dialog");

        Dialog.instance = ko.observable(this);
        ko.applyBindings(this, this.$dialog[0]);
    },

    initNewWork: function(name) {
        $("#work-name").removeClass("lookup-performed");

        var observable = Dialog.relationship().target,
            oldWork = observable.peek(), newWork,
            obj = ko.mapping.toJS(oldWork);

        obj.id = obj.gid = _.uniqueId("new-");
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
        // important: objects down the prototype chain should set "this" when
        // calling show. the template uses instance to decide which accept and
        // hide methods to execute.
        Dialog.instance(this);

        this.$overlay.fadeIn("fast");
        // prevents the page from jumping. these will be adjusted in resize().
        this.$dialog.css({top: $w.scrollTop(), left: $w.scrollLeft()}).fadeIn("fast");
        this.resize();
    },

    hide: function(callback) {
        var dlg = Dialog;
        dlg.$dialog.hide();
        dlg.$overlay.fadeOut("fast");

        delete dlg.targets;
        delete dlg.initialNewWork;
        delete dlg.previousWork;
        delete dlg.posx;
        delete dlg.posy;

        if ($.isFunction(callback)) callback.call(dlg);
        dlg.relationship(dlg.emptyRelationship);
        dlg.newWork(null);
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

        $.each($d.find("div.ar-descr, p.msg, div.error"), function(i, div) {
            var $div = $(div);
            if ($div.is(":visible")) $hidden = $hidden.add($div.hide());
        });

        $d.css("max-width", "100%").css("max-width", $d.outerWidth());
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
}());


UI.AddDialog = MB.utility.beget(Dialog);

UI.AddDialog.show = function(options) {
    var target = options.target, source = options.source,
        relationship = RE.Relationship({
            source: source, target: target, action: "add"}, false);

    if (target.type == "work") target.name(source.name.peek());

    this.mode(options.mode || "add");
    this.relationship(relationship);
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


UI.EditDialog = MB.utility.beget(Dialog);

UI.EditDialog.show = function(relationship) {
    var dlg = Dialog, target = relationship.target.peek(), name = target.name.peek(),
        newWork = target.type == "work" && RE.Util.isNewWork(target.gid);

    dlg.mode("edit");
    dlg.newWork(newWork);

    // originalRelationship is a copy of the relationship when the dialog was
    // opened, i.e. before the user edits it. if they cancel the dialog, this is
    // what gets copied back to revert their changes.
    dlg.originalRelationship = ko.mapping.toJS(relationship);

    // because the target is excluded from the Relationship mapping options, we
    // have to save the target as well. for new works we have to make a full
    // copy as opposed to just saving the reference, since the user can edit them.
    dlg.originalTarget = newWork ? ko.mapping.toJS(target) : target;
    if (newWork) dlg.initialNewWork = dlg.originalTarget;

    dlg.relationship(relationship);

    dlg.show.call(this);
};

UI.EditDialog.hide = function(cancel) {
    Dialog.hide(function() {
        if (cancel !== false) {
            var relationship = this.relationship.peek();
            ko.mapping.fromJS(this.originalRelationship, relationship);
            var observable = relationship.target, target = observable.peek();

            if (target !== this.originalTarget) {

                RE.Entity.isInstance(this.originalTarget)
                    ? observable(this.originalTarget)
                    : ko.mapping.fromJS(this.originalTarget, target);
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


var BatchRelationshipDialog = MB.utility.beget(UI.AddDialog);

BatchRelationshipDialog.accept = function(callback) {
    var relationship = Dialog.relationship();
    if (relationship.hasErrors()) return;

    var model = ko.mapping.toJS(relationship),
        hasCallback = $.isFunction(callback),
        targets = Dialog.targets;

    model.target = relationship.target();

    Util.renderRelationships(targets, function(target) {
        model.source = target;
        delete model.id;

        if (!hasCallback || callback(model)) {
            var newRelationship = RE.Relationship(model, true);
            if (newRelationship) return newRelationship;
        }
    });

    Dialog.hide();
};


UI.BatchRecordingRelationshipDialog = MB.utility.beget(BatchRelationshipDialog);

UI.BatchRecordingRelationshipDialog.show = function() {
    Dialog.targets = UI.checkedRecordings();
    if (Dialog.targets.length > 0) {

        UI.AddDialog.show.call(this, {
            source: Util.tempEntity("recording"), target: Util.tempEntity("artist"),
            mode: "batch.recording"
        });
    }
};


UI.BatchWorkRelationshipDialog = MB.utility.beget(BatchRelationshipDialog);

UI.BatchWorkRelationshipDialog.show = function() {
    Dialog.targets = UI.checkedWorks();
    if (Dialog.targets.length > 0) {

        UI.AddDialog.show.call(this, {
            source: Util.tempEntity("work"), target: Util.tempEntity("artist"),
            mode: "batch.work"
        });
    }
};


UI.BatchCreateWorksDialog = MB.utility.beget(BatchRelationshipDialog);

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

        newWork.id = newWork.gid = _.uniqueId("new-");
        newWork.name = obj.source.name();

        obj.target = RE.Entity(newWork);
        return true;
    });
};

return RE;

}(MB.RelationshipEditor || {}));
