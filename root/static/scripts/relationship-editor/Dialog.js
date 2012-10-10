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

        for (var i = 0, child; child = attr.children[i]; i++) {
            var opt = document.createElement("option"),
                attrs = relationshipAttrs[child.name];

            opt.value = child.id;
            opt.innerHTML = _.repeat("&#160;&#160;", indent) + child.l_name;
            if (child.unaccented) opt.setAttribute("data-unaccented", child.unaccented);
            if (attrs && attrs.indexOf(child.id) > -1) opt.selected = true;
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
            if (multi) {
                element.multiple = true;
                $element.hide();
            }

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

    function build(root, indent, backward, doc) {
        var phrase = backward ? root.reverse_phrase : root.phrase;

        // remove {foo} {bar} junk, unless it's for a required attribute.
        var orig_phrase = phrase, re = /\{(.*?)(?::(.*?))?\}/g, m, repl;
        while (m = re.exec(orig_phrase)) {
            var attr = Util.attrRoot(m[1]), info = root.attrs[attr.id];
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

        root.children && $.each(root.children, function(i, child) {
            build(child, indent + 1, backward, doc);
        });
    };

    var getOptions = _.memoize(function(type, backward) {
        var doc = document.createDocumentFragment();

        $.each(Util.typeInfoByEntities(type), function(i, root) {
            build(root, 0, backward, doc);
        });
        return doc;
    }, function(type, backward) {return type + "-" + backward});

    return {
        update: function(element) {
            var relationship = Dialog.relationship(), type = relationship.type(),
                backward = relationship.backward();

            if (type != previousType || backward != previousDirection) {
                var doc = getOptions(relationship.type(), backward).cloneNode(true);

                $(element).empty().append(doc).val(relationship.link_type());
                Dialog.resize();

                previousType = type;
                previousDirection = backward;
            }
        }
    };
}());


ko.bindingHandlers.targetType = (function() {

    var allowedRelations = {
        recording:     ["artist", "label", "recording", "release"],
        work:          ["artist", "label", "work"],
        release:       ["artist", "label", "recording", "release"],
        release_group: ["artist", "release_group"]
    };

    function change() {
        var mode = Dialog.mode();
        if (!(mode == "add" || /^batch\.(recording|work)$/.test(mode))) return;

        var relationship = Dialog.relationship.peek(), ac = Dialog.autocomplete,
            name = relationship.target().name(), target = Util.tempEntity(this.value);

        // reset the current target entity
        target.name(name);
        relationship.target(target);

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


function setAutocompleteEntity(entity, nameOnly) {
    var $ac = Dialog.$autocomplete, ac = Dialog.autocomplete,
        $name = $ac.find("input.name"), name = entity.name.peek();

    ac.term = name;
    ac.selectedItem = null;
    $name.removeClass("error lookup-performed").val(name);

    if (nameOnly === false) {
        ac.currentSelection = null;
        $name.addClass("lookup-performed").data("lookup-result", entity);
    }
};


ko.bindingHandlers.autocomplete = (function() {

    var recentEntities = {};

    function setEntity(type) {
        $("#target-type").val(type).trigger("change");
    }

    function closeOnEnter(event) {
        if (event.keyCode == 13 && !Dialog.relationship.peek().hasErrors.peek() &&
            !event.isDefaultPrevented())
                Dialog.instance.peek().accept();
    }

    function changeTarget(event, data) {
        var target = Dialog.relationship.peek().target, recent, dup;
        data.type = target.peek().type;

        // Add/move to the top of the recent entities menu.
        recent = recentEntities[data.type] = recentEntities[data.type] || [];
        dup = _.where(recent, {gid: data.gid})[0];
        dup && recent.splice(recent.indexOf(dup), 1);
        recent.unshift(data);

        target(RE.Entity(data));
    }

    function showRecentEntities(event) {
        if (event.originalEvent === undefined || // event was triggered by code, not user
            (event.type == "keyup" && !_.contains([8, 40], event.keyCode)))
            return;

        var recent = recentEntities[Dialog.relationship.peek().target.peek().type],
            ac = Dialog.autocomplete.autocomplete;

        if (!this.value && recent && recent.length && !ac.menu.active) {
            // setting ac.term to "" prevents the autocomplete plugin
            // from running its own search, which closes our menu.
            ac.term = "";
            ac._suggest(recent);
        }
    }

    return {
        init: function(element) {
            var $autocomplete = Dialog.$autocomplete = $(element),
                target = Dialog.relationship.peek().target.peek();

            Dialog.autocomplete = MB.Control.EntityAutocomplete({
                inputs: $autocomplete,
                position: {collision: "fit"},
                entity: target.type,
                setEntity: setEntity
            });

            $autocomplete
                .on("lookup-performed", changeTarget)
                .find("input.name")
                    .on("keyup focus click", showRecentEntities)
                    .on("keydown", closeOnEnter);

            setAutocompleteEntity(target, Dialog.mode() != "edit");

            ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
                $autocomplete.autocomplete("destroy");
            });
        }
    };
}());


var Dialog = UI.Dialog = {
    MB: MB,
    mode: ko.observable(""),
    loading: ko.observable(false),
    batchWorksError: ko.observable(false),

    showAutocomplete: ko.observable(false),
    showCreateWorkLink: ko.observable(false),
    showAttributesHelp: ko.observable(false),
    showLinkTypeHelp: ko.observable(false),

    relationship: (function() {
        var value = ko.observable(null);

        return ko.computed({
            read: value,
            write: function(newValue) {
                var oldValue = value();

                if (oldValue !== newValue) {
                    // if we cancelled an add dialog, the temporary relationship
                    // must be deleted.
                    if (oldValue && !oldValue.visible) oldValue.remove();

                    value(newValue);
                }
            }
        });
    }()),

    init: function() {
        // this is used as an "empty" state when the dialog is hidden, so that
        // none of the bindings error out.
        this.emptyRelationship = RE.Relationship({
            source: Util.tempEntity("recording"),
            target: Util.tempEntity("artist"),
            backward: true
        }, false);

        this.relationship(this.emptyRelationship);

        this.$overlay = $("#overlay");
        this.$dialog =  $("#dialog");

        Dialog.instance = ko.observable(this);
        ko.applyBindings(this, this.$dialog[0]);
    },

    show: function(posx, posy) {
        var dlg = Dialog;

        dlg.posx = posx;
        dlg.posy = posy;
        // important: objects down the prototype chain should set "this" when
        // calling show. the template uses instance to decide which accept and
        // hide methods to execute.
        dlg.instance(this);

        var relationship = dlg.relationship.peek(),
            notBatchWorks = dlg.mode.peek() != "batch.create.works";

        dlg.showAutocomplete(relationship.target().type != "url" && notBatchWorks);
        dlg.showCreateWorkLink(relationship.type() == "recording-work" && notBatchWorks);

        dlg.$overlay.show();
        // prevents the page from jumping. these will be adjusted in positionDialog.
        dlg.$dialog.css({top: $w.scrollTop(), left: $w.scrollLeft()}).show();

        positionDialog(dlg.$dialog, posx, posy);
        $("#link-type").focus();
    },

    hide: function(callback) {
        var dlg = Dialog;

        WorkDialog.hide();
        dlg.$dialog.hide();
        dlg.$overlay.hide();
        delete dlg.targets;

        if ($.isFunction(callback)) callback.call(dlg);

        dlg.showAutocomplete(false);
        dlg.relationship(dlg.emptyRelationship);
    },

    accept: function() {},

    createWork: function(data, event) {

        WorkDialog.show(function(work) {
            var target = RE.Entity(work, "work");
            setAutocompleteEntity(target, false);
            Dialog.relationship.peek().target(target);

        }, event.pageX, event.pageY);

        WorkDialog.name(Dialog.relationship.peek().source.name.peek());
        $("#work-name").focus();
    },

    batchWorksMode: function() {
        $("#work-type").clone(true).removeAttr("id").removeAttr("data-bind")
            .appendTo("#batch-work-type");

        $("#work-language").clone(true).removeAttr("id").removeAttr("data-bind")
            .appendTo("#batch-work-lang");
    },

    toggleAttributesHelp: function() {
        this.showAttributesHelp(!this.showAttributesHelp());
    },

    linkTypeDescription: ko.computed({
        read: function() {
            var info = Util.typeInfo(Dialog.relationship().link_type());
            return info ? info.descr : "";
        },
        // at the time this is declared, Dialog.relationship() is not set,
        // and can't be because relationships require the link type info from
        // the server. so defer this.
        deferEvaluation: true
    }),

    changeDirection: function() {
        var backward = this.relationship().backward;
        backward(!backward());
        this.resize();
    },

    toggleLinkTypeHelp: function() {
        var newValue = !this.showLinkTypeHelp.peek();
        this.showLinkTypeHelp(newValue);

        if (newValue)
            _.defer(function() {
                $("#link-type").parent().find("div.ar-descr a").attr("target", "_blank");
            });
    },

    resize: function() {
        // note: this is called by the afterRender binding.
        resizeDialog(Dialog.$dialog);
    }
};


function resizeDialog($dialog) {
    // we want the dialog's size to "fit" the contents. the ar-descrs stretch
    // the dialog 100%, making this impossible; hide them first.
    var $d = $dialog, $hidden = $();

    $.each($d.find("div.ar-descr, p.msg, div.error"), function(i, div) {
        var $div = $(div);
        if ($div.is(":visible")) $hidden = $hidden.add($div.hide());
    });

    $d.css("width", "").css("width", $d[0].offsetWidth + 1);
    $hidden.show();
}


function positionDialog($dialog, posx, posy) {
    var $d = $dialog;
    if (!$d.is(":visible")) return;

    resizeDialog($d);

    var offx = $w.scrollLeft(), offy = $w.scrollTop(),
        wwidth = $w.width(), wheight = $w.height(),
        dwidth = $d[0].offsetWidth, dheight = $d[0].offsetHeight,
        centerx = offx + (wwidth / 2), centery = offy + (wheight / 2);

    if (!posx || !posy || wwidth < dwidth) {
        $d.css({top: Math.max(offy, centery - dheight), left: centerx - (dwidth / 2)});

    } else {
        $d.css("left", posx <= centerx ? posx : posx - dwidth);

        var dheight2 = dheight / 2, topclear = posy - dheight2 >= offy,
            botclear = posy + dheight2 <= wheight + offy;

        (topclear && botclear)
            ? $d.css("top", posy - dheight2)
            : $d.css("top", topclear ? (wheight + offy - dheight) : offy);
    }
}


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
        var attributes = [], typeInfo = Util.typeInfo(linkType), id;
        if (!typeInfo) return attributes;

        var allowedAttrs = typeInfo.attrs ? MB.utility.keys(typeInfo.attrs) : [];

        allowedAttrs.sort(function(a, b) {
            return Util.attrInfo(a).child_order - Util.attrInfo(b).child_order;
        });

        for (var i = 0; id = allowedAttrs[i]; i++)
            attributes.push(new Attribute(Util.attrInfo(id), typeInfo.attrs[id]));

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

UI.AddDialog.show = function(options, posx, posy) {
    var target = options.target, source = options.source,
        relationship = RE.Relationship({
            source: source, target: target, action: "add"}, false);

    if (target.type == "work") target.name(source.name.peek());

    this.mode(options.mode || "add");
    this.relationship(relationship);
    Dialog.show.call(this, posx, posy);
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

UI.EditDialog.show = function(relationship, posx, posy) {
    var dlg = Dialog, target = relationship.target.peek(), name = target.name.peek();

    dlg.mode("edit");

    // originalRelationship is a copy of the relationship when the dialog was
    // opened, i.e. before the user edits it. if they cancel the dialog, this is
    // what gets copied back to revert their changes.
    dlg.originalRelationship = ko.mapping.toJS(relationship);

    // because the target is excluded from the Relationship mapping options, we
    // have to save the target as well.
    dlg.originalTarget = target;

    dlg.relationship(relationship);
    dlg.show.call(this, posx, posy);
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

    Util.callbackQueue(targets, function(target) {
        model.source = target;
        delete model.id;

        if (!hasCallback || callback(model))
            RE.Relationship(model, true, true);
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
    Dialog.targets = _.filter(UI.checkedRecordings(), function(obj) {
        return obj.performanceRelationships.peek().length == 0;
    });

    if (Dialog.targets.length > 0) {
        var source = Util.tempEntity("recording"), target = Util.tempEntity("work");

        // the user can't edit the target in this dialog, but the gid of the
        // temporary target entity has to be set to something valid, so that
        // validation passes and the dialog can be okay'd.
        target.gid = "00000000-0000-0000-0000-000000000000";
        UI.AddDialog.show.call(this, {source: source, target: target, mode: "batch.create.works"});
    }
};

UI.BatchCreateWorksDialog.accept = function() {
    Dialog.loading(true);

    var type_id = $("#batch-work-type > select").val(),
        language_id = $("#batch-work-lang > select").val(), works = [];

    _.each(Dialog.targets, function(obj) {
        works.push({
            name: obj.name.peek(), comment: "",
            type: type_id, language: language_id
        });
    });

    function success(data) {
        BatchRelationshipDialog.accept.call(this, function(obj) {
            obj.target = RE.Entity(data.works.shift(), "work");
            if (data.works.length == 0) Dialog.loading(false);
            return true;
        });
    }

    function error() {
        Dialog.loading(false);
        Dialog.batchWorksError(true);
    }

    RE.createWorks(works, "", success, error);
};

UI.BatchCreateWorksDialog.hide = function() {
    Dialog.hide(function() {
        Dialog.batchWorksError(false);
    });
};


var WorkDialog = UI.WorkDialog = {
    RE: RE,
    showName: ko.observable(true),
    loading: ko.observable(false),
    error: ko.observable(false),
    callback: ko.observable(null),

    name: ko.observable(""),
    comment: ko.observable(""),
    type: ko.observable(""),
    language: ko.observable(""),
    editNote: ko.observable(""),

    init: function() {
        var self = this, $dialog = $("#new-work-dialog")
            .on("keydown", "#work-name", function(event) {
                if (event.keyCode == 13 && self.name.peek() && !self.loading.peek())
                    self.accept();
            });

        ko.applyBindings(this, $dialog[0]);
    },

    data: function() {
        var self = WorkDialog;

        return {
            name: self.name(),
            comment: self.comment(),
            type: self.type(),
            language: self.language()
        };
    },

    show: function(callback, posx, posy) {
        var self = WorkDialog;

        self.showName(true);
        self.loading(false);
        self.error(false);
        self.callback(callback);

        self.name("");
        self.comment("");
        self.type("");
        self.language("");

        positionDialog($("#new-work-dialog").show(), posx, posy);
    },

    accept: function() {
        var self = WorkDialog;
        self.error(false);
        self.loading(true);

        RE.createWorks([self.data()], self.editNote(),
            self.successCallback, self.errorCallback);
    },

    hide: function() {
        WorkDialog.callback(null);
        $("#new-work-dialog").hide();
        WorkDialog.type("");
        WorkDialog.language("");
        $("#link-type").focus();
    },

    successCallback: function(data) {
        WorkDialog.loading(false);
        WorkDialog.callback()(data.works[0]);
        WorkDialog.hide();
    },

    errorCallback: function() {
        WorkDialog.loading(false);
        WorkDialog.error(true);
    }
};


return RE;

}(MB.RelationshipEditor || {}));
