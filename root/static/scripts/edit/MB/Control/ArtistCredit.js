/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010,2011 MetaBrainz Foundation

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

const clean = require('../../../common/utility/clean');

MB.Control.ArtistCreditName = aclass(MB.entity.ArtistCreditName, {

    after$init: function (data, container) {
        this.container = container;
        this.artist = ko.observable(this.artist);
        this.name = ko.observable(this.name);
        this.joinPhrase = ko.observable(this.joinPhrase);
        this.automaticJoin = true;
        this.currentArtistName = data.artist.name || "";

        this.artist.subscribe(this.artistChanged, this);
        this.name.subscribe(this.nameChanged, this);
    },

    artistChanged: function (artist) {
        var newName = artist ? artist.name : "";

        if (!newName || this.currentArtistName === this.name.peek()) {
            this.name(newName);
        }
        this.currentArtistName = newName;
    },

    nameChanged: function (newName) {
        var artist = this.artist();

        if (newName === "" && artist) {
            this.name(artist.name);
        }
    },

    // This should only run after the user explicitly edits the join phrase,
    // and a change event occurs.
    joinChanged: function (element) {
        if (!this.automaticJoin) {
            return;
        }

        /* this is the first value the user has entered into this field.

           If it is a simple word (such as "and") or an abbreviation (such as
           "feat.") it is likely that it should be surrounded by spaces. Add
           those spaces automatically only this first time. Also standardise
           "feat." according to our guidelines.
        */
        var join = clean(element.value);
        join = join.replace(/^\s*(feat\.?|ft\.?|featuring)\s*$/i,"feat.");

        if (/^[A-Za-z]+\.?$/.test(join)) {
            this.joinPhrase(" " + join + " ");

        } else if (/^,$/.test(join)) {
            this.joinPhrase(", ");

        } else if (/^&$/.test(join)) {
            this.joinPhrase(" & ");

        } else if (/^;$/.test(join)) {
            this.joinPhrase("; ");
        }

        // this join phrase has been changed, it should no langer be automatic.
        this.automaticJoin = false;
    }
});


MB.Control.ArtistCredit = aclass(MB.entity.ArtistCredit, {

    init: function (options) {
        this.names = ko.observableArray([]);

        var initialData = options.initialData;

        if (!initialData || initialData.length === 0) {
            initialData = [{}];
        }
        this.setNames(initialData);

        if (options.hiddenInputs) {
            this.formName = options.formName;
            this.hiddenInputs = ko.computed(this.updateHiddenInputs, this);
        } else {
            this.hiddenInputs = null;
        }
    },

    setAutocomplete: function (autocomplete, target) {
        // The single-artist lookup changes the credit boxes in the doc bubble,
        // and the credit boxes change the single-artist lookup.
        var self = this;

        function update() {
            var names = self.names();
            target.disabled = self.isComplex();

            if (target.disabled) {
                autocomplete.setObservable(null);
                autocomplete.setSelection({ name: self.text() });

                var complete = _.all(_.invoke(names, "hasArtist"));
                $(target).toggleClass("lookup-performed", complete);
            } else {
                autocomplete.setObservable(names[0].artist);
            }
        }
        ko.computed({ read: update, disposeWhenNodeIsRemoved: target });
    },

    setNames: function (names) {
        var self = this;

        this.names(_.map(names, function (data) {
            return MB.Control.ArtistCreditName(data, self);
        }));
    },

    addName: function () {
        this.names.push(MB.Control.ArtistCreditName({}, this));
        this.setAutoJoinPhrases();
    },

    removeName: function (name) {
        // Do not allow the last name credit to be deleted.
        if (this.names().length > 1) {
            this.names.remove(name);
            this.setAutoJoinPhrases();
        }
    },

    setAutoJoinPhrases: function () {
        var names = this.names();
        var length = names.length;
        var name0 = names[length - 1];
        var name1 = names[length - 2];
        var name2 = names[length - 3];
        var auto = /^(| & |, )$/;

        if (name0 && name0.automaticJoin) {
            name0.joinPhrase("");
        }

        if (name1 && name1.automaticJoin && auto.test(name1.joinPhrase())) {
            name1.joinPhrase(" & ");
        }

        if (name2 && name2.automaticJoin && auto.test(name2.joinPhrase())) {
            name2.joinPhrase(", ");
        }
    },

    isComplex: function () {
        var firstName = this.names()[0];
        return (firstName ? firstName.artist().name : "") !== this.text();
    },

    updateHiddenInputs: function () {
        var prefix = "artist_credit.names.";

        if (this.formName) {
            prefix = this.formName + "." + prefix;
        }

        return _.flatten(_.map(this.toJSON(), function (name, index) {
            var curPrefix = prefix + index + ".";

            return [
                { name: curPrefix + "name", value: name.name },
                { name: curPrefix + "join_phrase", value: name.joinPhrase },
                { name: curPrefix + "artist.name", value: name.artist.name },
                { name: curPrefix + "artist.id", value: name.artist.id }
            ];
        }));
    }
});


// initialize_artist_credit is a helper class that takes care of generating
// hidden form inputs for submission.

MB.Control.initialize_artist_credit = function ($target, $bubble, $button) {
    $target = $target || $("#entity-artist");
    $bubble = $bubble || $("#artist-credit-bubble");
    $button = $button || $("#open-ac");

    var ac = MB.Control.ArtistCredit({
        hiddenInputs: $target.data("hidden-inputs"),
        formName: $target.data("form"),
        initialData: $target.data("artist")
    });

    var bubble = MB.Control.ArtistCreditBubbleDoc();
    bubble.target(ac);

    ko.applyBindings(ac, $target[0]);
    ko.applyBindingsToNode($button[0], { controlsBubble: bubble }, ac);
    ko.applyBindingsToNode($bubble[0], { bubble: bubble }, ac);

    return ac;
};
