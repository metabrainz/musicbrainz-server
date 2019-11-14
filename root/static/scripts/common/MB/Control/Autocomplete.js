// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import {ENTITIES, MAX_RECENT_ENTITIES} from '../../constants';
import MB_entity from '../../entity';
import commaOnlyList from '../../i18n/commaOnlyList';
import {reduceArtistCredit} from '../../immutable-entities';
import MB from '../../MB';
import clean from '../../utility/clean';
import formatDate from '../../utility/formatDate';
import formatDatePeriod from '../../utility/formatDatePeriod';
import formatTrackLength from '../../utility/formatTrackLength';
import isBlank from '../../utility/isBlank';
import primaryAreaCode from '../../utility/primaryAreaCode';
import {localStorage} from '../../utility/storage';
import bracketed from '../../utility/bracketed';

import '../../../../lib/jquery-ui';

const addNewEntityLabels = {
    artist: N_l('Add a new artist'),
    event: N_l('Add a new event'),
    label: N_l('Add a new label'),
    place: N_l('Add a new place'),
    recording: N_l('Add a new recording'),
    release_group: N_l('Add a new release group'),
    series: N_l('Add a new series'),
    work: N_l('Add a new work'),
};

$.widget('mb.entitylookup', $.ui.autocomplete, {

    mbidRegex: /[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}/,

    options: {
        minLength: 1,
        allowEmpty: true,

        // default to showing error and lookup-performed status by adding
        // those classes (red/green background) to lookup fields.
        showStatus: true,

        // Prevent menu item focus from changing the input value
        focus: function (event, data) {
            return false;
        },

        source: function (request, response) {
            var self = this;

            // always reset to first page if we're looking for something new.
            if (request.term != this.pageTerm) {
                this._resetPage();
                this.pageTerm = request.term;
            }

            if (this.xhr) {
                this.xhr.abort();
            }

            this.xhr = $.ajax(this.options.lookupHook({
                url: '/ws/js/' + this.entity,
                data: {
                    q: request.term,
                    page: this.currentPage,
                    direct: !this.indexedSearch,
                },
                dataType: 'json',
                success: $.proxy(this._lookupSuccess, this, response),
                error: function () {
                    response([{
                        label: l('An error occurred while searching. Click here to try again.'),
                        action: _.bind(self._searchAgain, self),
                    }, {
                        label: self.indexedSearch ?
                               l('Try with direct search instead.') :
                               l('Try with indexed search instead.'),
                        action: _.bind(self._searchAgain, self, true),

                    }]);
                },
            }));
        },

        resultHook: _.identity,
        lookupHook: _.identity,
    },

    _create: function () {
        this._super();

        this.currentResults = [];
        this.currentPage = 1;
        this.totalPages = 1;
        this.pageTerm = '';
        this.indexedSearch = true;
        this.changeEntity(this.options.entity);

        this.setObservable(
            this.options.currentSelection || ko.observable({
                name: this._value(),
            }),
        );

        this.$input = this.element;
        this.$search = this.element
            .closest('span.autocomplete').find('img.search');

        this.element.attr('placeholder', l('Type to search, or paste an MBID'));

        var self = this;

        // The following callbacks are triggered by jQuery UI. They're defined
        // here, and not in the "options" definition above, because they need
        // access to current instance.

        this.options.open = function (event) {
            // Automatically focus the first item in the menu.
            self.menu.focus(event, self.menu.element.children('li:eq(0)'));
        };

        this.options.select = function (event, data) {
            var entity = self._dataToEntity(data.item);

            self.currentSelection(entity);
            self.element.trigger('lookup-performed', [entity]);

            // Returning false prevents the search input's text from changing.
            // We've already changed it in setSelection.
            return false;
        };

        // End of options callbacks.

        this.element.on('input', function (event) {
            var selection = self.currentSelection.peek();

            // XXX The condition shouldn't be necessary, because the input
            // event should only fire if the value has changed. But Opera
            // doesn't fire an input event if you paste text into a field,
            // only if you type it [1]. Pressing enter after pasting an MBID,
            // then, has the effect of firing the input event too late, and
            // clearing the field. Checking the current selection against the
            // current value is done to prevent this.
            // [1] https://developer.mozilla.org/en-US/docs/Web/Reference/Events/input
            if (selection && selection.name !== this.value) {
                self.clearSelection(false);
            }
        });

        this.element.on('blur', function (event) {
            // Stop searching if someone types something and then tabs out of
            // the field.
            self.cancelSearch = true;

            var selection = self.currentSelection.peek();

            if (selection && selection.name !== self._value()) {
                self.clear(false);
            }
        });

        this.element.on('keyup focus click', function (event) {
            if (event.originalEvent === undefined) {
                // event was triggered by code, not user
                return;
            }

            if (event.type === 'keyup' && !_.includes([8, 40], event.keyCode)) {
                return;
            }

            var recent = self.recentEntities();

            if (!this.value && recent && recent.length && !self.menu.active) {
                // setting ac.term to "" prevents the autocomplete plugin
                // from running its own search, which closes our menu.
                self.term = '';

                recent.push({
                    label: l('Clear recent items'),
                    action: function () {
                        self.recentEntities([]);
                        self.clear();
                    },
                });

                self._suggest(recent);
            }
        });


        this.$search.on('click.mb', function (event) {
            if (self.element.is(':enabled')) {
                self.element.focus();

                if (self._value()) {
                    self._searchAgain();
                }
            }
        });

        // Click events inside the menu should not cause the box to close.
        this.menu.element.on('click', function (event) {
            event.stopPropagation();
        });
    },

    _dataToEntity: function (data) {
        try {
            if (this.options.entityConstructor) {
                return new this.options.entityConstructor(data);
            }
            return MB_entity(data, this.entity);
        } catch (e) {
            return data;
        }
    },

    // Overrides $.ui.autocomplete.prototype.close
    // Reset the currentPage and currentResults on menu close.
    close: function (event) {
        this._super(event);
        this._resetPage();
    },

    clear: function (clearAction) {
        this.clearSelection(clearAction);
        this.close();
    },

    clearSelection: function (clearAction) {
        var name = clearAction ? '' : this._value();
        var currentSelection = this.currentSelection.peek();

        // If the current entity doesn't have an id, it's already "blank" and
        // we don't need to unnecessarily create a new one. Doing so can even
        // have unintended effects, e.g. wiping other useful data on the
        // entity (like release group types).

        if (currentSelection.id) {
            this.currentSelection(this._dataToEntity({name: name}));
        } else if (currentSelection.name !== name) {
            currentSelection.name = name;
            this.currentSelection.notifySubscribers(currentSelection);
        }

        this.element.trigger('cleared', [clearAction]);
    },

    _resetPage: function () {
        this.currentPage = 1;
        this.currentResults = [];
    },

    _searchAgain: function (toggle) {
        if (toggle) {
            this.indexedSearch = !this.indexedSearch;
        }
        this._resetPage();
        this.term = this._value();
        this._search(this.term);
    },

    _showMore: function () {
        this.currentPage += 1;
        this._search(this._value());
    },

    setSelection: function (data) {
        data = data || {};
        var name = ko.unwrap(data.name) || '';
        var hasID = !!(data.id || data.gid);

        if (this._value() !== name) {
            this._value(name);
        }

        if (this.options.showStatus) {
            var error = !(name || hasID || this.options.allowEmpty);

            this.element
                .toggleClass('error', error)
                .toggleClass('lookup-performed', hasID);
        }
        this.term = name || '';
        this.selectedItem = data;

        if (hasID) {
            // Add/move to the top of the recent entities menu.
            var recent = this.recentEntities();
            var entityProperties = ENTITIES[this.entityType()];
            var duplicate = _.find(
                recent,
                _.pick(data, entityProperties.mbid ? 'gid' : 'id'),
            );

            duplicate && recent.splice(recent.indexOf(duplicate), 1);
            recent.unshift(data.toJSON());
            this.recentEntities(recent);
        }
    },

    setObservable: function (observable) {
        if (this._selectionSubscription) {
            this._selectionSubscription.dispose();
        }
        this.currentSelection = observable;

        if (observable) {
            this._selectionSubscription =
                observable.subscribe(this.setSelection, this);
            this.setSelection(observable.peek());
        }
    },

    // Overrides $.ui.autocomplete.prototype._searchTimeout
    _searchTimeout: function (event) {
        var newTerm = this._value();

        if (isBlank(newTerm)) {
            clearTimeout(this.searching);
            this.close();
            return;
        }

        var mbidMatch = newTerm.match(this.mbidRegex);
        if (mbidMatch) {
            clearTimeout(this.searching);
            this._lookupMBID(mbidMatch[0]);
            return;
        }

        var oldTerm = this.term;

        // Support pressing <space> to trigger a search, but ignore it if the
        // menu is already open.
        if (this.menu.element.is(':visible')) {
            newTerm = clean(newTerm);
            oldTerm = clean(oldTerm);
        }

        // only search if the value has changed
        if (oldTerm !== newTerm && this.completedTerm !== newTerm) {
            clearTimeout(this.searching);
            this.completedTerm = oldTerm;

            this.searching = this._delay(
                function () {
                    delete this.completedTerm;
                    this.selectedItem = null;
                    this.search(null, event);
                },
                this.options.delay,
            );
        }
    },

    _lookupMBID: function (mbid) {
        var self = this;

        this.close();

        if (this.xhr) {
            this.xhr.abort();
        }

        this.xhr = $.ajax({
            url: '/ws/js/entity/' + mbid,

            dataType: 'json',

            success: function (data) {
                var currentEntityType = self.entity.replace('-', '_');

                if (data.entityType !== currentEntityType) {
                    // Only RelateTo boxes and relationship-editor dialogs
                    // support changing the entity type.
                    var setEntity = self.options.setEntity;

                    if (!setEntity || setEntity(data.entityType) === false) {
                        self.clear();
                        return;
                    }
                }
                self.options.select(null, {item: data});
            },

            error: _.bind(this.clear, this),
        });
    },

    _lookupSuccess: function (response, data) {
        var self = this;
        var pager = _.last(data);
        var jumpTo = this.currentResults.length;

        data = this.options.resultHook(_.initial(data));

        // "currentResults" will contain action items that aren't results,
        // e.g. ShowMore, SwitchToDirectSearch, etc. Filter these actions out
        // before appending the new results (we re-add them below).

        var results = this.currentResults = _.filter(
            this.currentResults, function (item) {
                return !item.action;
            });

        results.push.apply(results, data);

        this.currentPage = parseInt(pager.current, 10);
        this.totalPages = parseInt(pager.pages, 10);

        if (results.length === 0) {
            results.push({
                label: '(' + l('No results') + ')',
                action: _.bind(this.close, this),
            });
        }

        if (this.currentPage < this.totalPages) {
            results.push({
                label: l('Show more...'),
                action: _.bind(this._showMore, this),
            });
        }

        results.push({
            label: this.indexedSearch ? l('Not found? Try again with direct search.') :
                                        l('Slow? Switch back to indexed search.'),
            action: _.bind(this._searchAgain, this, true),
        });

        var allowCreation = window === window.top,
            entity = this.entity.replace('-', '_');

        if (allowCreation && addNewEntityLabels[entity]) {
            const label = addNewEntityLabels[entity]();
            results.push({
                label,
                action: function () {
                    $('<div>').appendTo('body').createEntityDialog({
                        name: self._value(),
                        entity: entity,
                        title: label,
                        callback: function (item) {
                            self.options.select(null, {item: item});
                        },
                    });
                },
            });
        }

        response(results);

        this._delay(function () {
            // Once everything's rendered, jump to the first item that was
            // added. This makes the menu scroll after hitting "Show More."
            var menu = this.menu;
            var $ul = menu.element;

            if (menu.active) {
                menu.active.children('a').removeClass('ui-state-focus');
            }

            var $item = menu.active = $ul.children('li:eq(' + jumpTo + ')');
            $item.children('a').addClass('ui-state-focus');

            if (this.currentPage > 1) {
                $ul.scrollTop($item.position().top + $ul.scrollTop());
            }
        });
    },

    _renderAction: function (ul, item) {
        return $('<li>')
            .css('text-align', 'center')
            .append($('<a>').text(item.label))
            .appendTo(ul);
    },

    _renderItem: function (ul, item) {
        if (item.action) {
            return this._renderAction(ul, item);
        }
        var formatters = MB.Control.autocomplete_formatters;
        var entityType = formatters[this.entity] ? this.entity : 'generic';
        return formatters[entityType](ul, item);
    },

    changeEntity: function (entity) {
        this.entity = entity.replace('_', '-');
        if (entity === 'event') {
            this.indexedSearch = false;
        }
    },

    entityType: function () {
        return this.entity.replace('-', '_');
    },

    recentEntities: function () {
        var entityType = this.entityType();
        var recentEntities = {};
        var storedRecentEntities = localStorage('recentAutocompleteEntities');

        if (storedRecentEntities) {
            try {
                recentEntities = JSON.parse(storedRecentEntities);
            } catch (e) {
                recentEntities = {};
            }

            if (!_.isPlainObject(recentEntities)) {
                recentEntities = {};
            }
        }

        if (arguments.length) {
            recentEntities[entityType] = _.take(arguments[0], MAX_RECENT_ENTITIES);
            localStorage('recentAutocompleteEntities', JSON.stringify(recentEntities));
        } else {
            return recentEntities[entityType] || [];
        }
    },
});


$.widget('ui.menu', $.ui.menu, {

    // When a result is normally selected from an autocomplete menu, the menu
    // is closed and the text of the search input is changed. This is not what
    // we want to happen for menu items associated with an action (e.g. show
    // more, switch to indexed search, clear artist, etc.). To support the
    // desired behavior, the "select" method for jQuery UI menus is overridden
    // below to check if an action function is associated with the selected
    // item. If it is, the action is executed. Otherwise we fall back to the
    // default menu behavior.

    _selectAction: function (event) {
        var active = this.active || $(event.target).closest('.ui-menu-item');
        var item = active.data('ui-autocomplete-item');

        if (item && $.isFunction(item.action)) {
            item.action();

            // If this is a click event on the <a>, make sure the event
            // doesn't reach the parent <li>, or the select action will
            // close the menu.
            event.stopPropagation();
            event.preventDefault();

            return true;
        }
    },

    _create: function () {
        this._super();
        this._on({'click .ui-menu-item > a': this._selectAction});
    },

    select: function (event) {
        if (!this._selectAction(event)) {
            this._super(event);
        }
        // When mouseHandled is true, $.ui ignores future mouse events. It only
        // gets reset to false if you click outside of the menu, but we want
        // it to be false no matter what.
        this.mouseHandled = false;
    },
});


MB.Control.autocomplete_formatters = {
    'generic': function (ul, item) {
        var a = $('<a>').text(item.name);

        var comment = [];

        if (item.primaryAlias && item.primaryAlias != item.name)
        {
            comment.push(item.primaryAlias);
        }

        if (item.sort_name && !isLatin(item.name) && item.sort_name != item.name && !item.primaryAlias)
        {
            comment.push(item.sort_name);
        }

        if (item.comment)
        {
            comment.push(item.comment);
        }

        if (comment.length)
        {
            a.append(' <span class="autocomplete-comment">' +
                     _.escape(bracketed(commaOnlyList(comment))) + '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'recording': function (ul, item) {
        var a = $('<a>').text(item.name);

        if (item.length)
        {
            a.prepend('<span class="autocomplete-length">' +
                formatTrackLength(item.length) + '</span>');
        }

        if (item.comment)
        {
            a.append('<span class="autocomplete-comment">' +
                      _.escape(bracketed(item.comment)) + '</span>');
        }

        if (item.video)
        {
            const title = _.escape(l('This recording is a video'));
            a.prepend($(`<span class="video" title="${title}"></span>`));
        }

        a.append('<br /><span class="autocomplete-comment">by ' +
                  _.escape(item.artist) + '</span>');

        if (item.appearsOn && item.appearsOn.hits > 0)
        {
            var rgs = [];
            $.each(item.appearsOn.results, function (idx, item) {
                rgs.push(item.name);
            });

            if (item.appearsOn.hits > item.appearsOn.results.length)
            {
                rgs.push('...');
            }

            a.append('<br /><span class="autocomplete-appears">' + _.escape(addColon(l('appears on'))) + ' ' +
                     _.escape(commaOnlyList(rgs)) + '</span>');
        }
        else if (item.appearsOn && item.appearsOn.hits === 0) {
            a.append('<br /><span class="autocomplete-appears">' + _.escape(l('standalone recording')) + '</span>');
        }

        if (item.isrcs && item.isrcs.length)
        {
            a.append('<br /><span class="autocomplete-isrcs">' + _.escape(addColon(l('ISRCs'))) + ' ' +
                     _.escape(commaOnlyList(item.isrcs.map(isrc => isrc.isrc))) + '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'release': function (ul, item) {
        var $li = this.generic(ul, item);
        var $a = $li.children('a');

        appendComment($a, _.escape(reduceArtistCredit(item.artistCredit)));

        item.events && item.events.forEach(function (event) {
            var country = event.country;
            var countryHTML = '';

            if (country) {
                const primaryCode = primaryAreaCode(country);
                countryHTML = (
                    `<span class="flag flag-${primaryCode}">` +
                    `<abbr title="${country.name}">${primaryCode}</abbr></span>`
                );
            }

            const date = formatDate(event.date);
            appendComment(
                $a,
                date +
                (countryHTML ? maybeParentheses(countryHTML, date) : ''),
            );
        });

        _(item.labels)
            .groupBy(getLabelName)
            .each(function (releaseLabels, name) {
                var catalogNumbers = _(releaseLabels).map(getCatalogNumber).compact().sort().value();

                if (catalogNumbers.length > 2) {
                    appendComment(
                        $a,
                        name +
                        maybeParentheses(_.head(catalogNumbers) + ' … ' + _.last(catalogNumbers), name),
                    );
                } else {
                    _.each(releaseLabels, function (releaseLabel) {
                        var name = getLabelName(releaseLabel);
                        appendComment($a, name + maybeParentheses(getCatalogNumber(releaseLabel), name));
                    });
                }
            });

        if (item.barcode) {
            appendComment($a, item.barcode);
        }

        return $li;
    },

    'release-group': function (ul, item) {
        var a = $('<a>').text(item.name);

        if (item.firstReleaseDate)
        {
            a.append('<span class="autocomplete-comment">' +
                        bracketed(item.firstReleaseDate) + '</span>');
        }

        if (item.comment)
        {
            a.append('<span class="autocomplete-comment">' +
                      _.escape(bracketed(item.comment)) + '</span>');
        }

        if (item.typeName) {
            a.append('<br /><span class="autocomplete-comment">' +
              _.escape(texp.l('{release_group_type} by {artist}', {
                artist: item.artist,
                release_group_type: item.l_type_name,
             })) + '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'series': function (ul, item) {
        var a = $('<a>').text(item.name);

        if (item.comment) {
            a.append('<span class="autocomplete-comment">' + _.escape(bracketed(item.comment)) + '</span>');
        }

        if (item.type) {
            a.append(' <span class="autocomplete-comment">' + _.escape(bracketed(lp_attributes(item.type.name, 'series_type'))) + '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'work': function (ul, item) {
        var a = $('<a>').text(item.name);
        var comment = [];

        if (item.languages && item.languages.length) {
            a.prepend('<span class="autocomplete-language">' +
                      _.escape(commaOnlyList(item.languages.map(wl => l_languages(wl.language.name)))) +
                      '</span>');
        }

        if (item.primaryAlias && item.primaryAlias != item.name)
        {
            comment.push(item.primaryAlias);
        }

        if (item.comment)
        {
            comment.push(item.comment);
        }

        if (comment.length)
        {
            a.append(' <span class="autocomplete-comment">' +
                     _.escape(bracketed(commaOnlyList(comment))) + '</span>');
        }

        if (item.typeName)
        {
            a.append('<br /><span class="autocomplete-comment">' + _.escape(addColon(l('Type')) + ' ' + lp_attributes(item.typeName, 'work_type')) + '</span>');
        }

        var artistRenderer = function (prefix, artists) {
            if (artists && artists.hits > 0)
            {
                var toRender = artists.results;
                if (artists.hits > toRender.length)
                {
                    toRender.push('...');
                }

                a.append('<br /><span class="autocomplete-comment">' +
                         prefix + ': ' + _.escape(commaOnlyList(toRender)) + '</span>');
            }
        };

        if (item.artists) {
            artistRenderer(l('Writers'), item.artists.writers);
            artistRenderer(l('Artists'), item.artists.artists);
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'area': function (ul, item) {
        var a = $('<a>').text(item.name);

        if (item.comment)
        {
            a.append('<span class="autocomplete-comment">' +
                      _.escape(bracketed(item.comment)) + '</span>');
        }

        if (item.typeName || (item.containment && item.containment.length)) {
            var items = [];
            if (item.typeName) {
                items.push(lp_attributes(item.typeName, 'area_type'));
            }
            if (item.containment && item.containment.length) {
                items.push(renderContainingAreas(item));
            }
            a.append('<br /><span class="autocomplete-comment">' +
                     _.escape(commaOnlyList(items)) + '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'place': function (ul, item) {
        var a = $('<a>').text(item.name);

        var comment = [];

        if (item.primaryAlias && item.primaryAlias != item.name)
        {
            comment.push(item.primaryAlias);
        }

        if (item.comment)
        {
            comment.push(item.comment);
        }

        if (comment.length)
        {
            a.append(' <span class="autocomplete-comment">' +
                     _.escape(bracketed(commaOnlyList(comment))) + '</span>');
        }

        var area = item.area;
        if (item.typeName || area) {
            var items =[];
            if (item.typeName) {
                items.push(lp_attributes(item.typeName, 'place_type'));
            }
            if (area) {
                items.push(area.name);
                if (area.containment && area.containment.length) {
                    items.push(renderContainingAreas(area));
                }
            }
            a.append('<br /><span class="autocomplete-comment">' +
                     _.escape(commaOnlyList(items)) + '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'instrument': function (ul, item) {
        var a = $('<a>').text(item.name);

        var comment = [];

        if (item.primaryAlias && item.primaryAlias != item.name) {
            comment.push(item.primaryAlias);
        }

        if (item.comment) {
            comment.push(item.comment);
        }

        if (item.typeName) {
            comment.push(lp_attributes(item.typeName, 'instrument_type'));
        }

        if (comment.length)
        {
            a.append(' <span class="autocomplete-comment">' +
                     _.escape(bracketed(commaOnlyList(comment))) + '</span>');
        }

        if (item.description) {
            // We want to strip html from the non-clickable description
            a.append('<br /><span class="autocomplete-comment">' +
                      _.escape($('<div/>').html(
                        l_instrument_descriptions(item.description),
                      ).text()) +
                      '</span>');
        }

        return $('<li>').append(a).appendTo(ul);
    },

    'event': function (ul, item) {
        var a = $('<a>').text(item.name);
        var comment = [];

        if (item.primaryAlias && item.primaryAlias != item.name)
        {
            comment.push(item.primaryAlias);
        }

        if (item.comment)
        {
            comment.push(item.comment);
        }

        if (comment.length)
        {
            a.append(' <span class="autocomplete-comment">' +
                     _.escape(bracketed(commaOnlyList(comment))) + '</span>');
        }

        if (item.typeName) {
            a.append(' <span class="autocomplete-comment">' + _.escape(bracketed(lp_attributes(item.typeName, 'event_type'))) + '</span>');
        }

        if (item.begin_date || item.time)
        {
            a.append('<br /><span class="autocomplete-comment">' + (item.begin_date ? (formatDatePeriod(item) + ' ') : '') + (item.time ? item.time : '') + '</span>');
        }

        var entityRenderer = function (prefix, related_entities) {
            if (related_entities && related_entities.hits > 0)
            {
                var toRender = related_entities.results;
                if (related_entities.hits > toRender.length)
                {
                    toRender.push('...');
                }

                a.append('<br /><span class="autocomplete-comment">' +
                         prefix + ': ' + _.escape(commaOnlyList(toRender)) + '</span>');
            }
        };

        if (item.related_entities) {
            entityRenderer(l('Performers'), item.related_entities.performers);
            entityRenderer(l('Location'), item.related_entities.places);
        }

        return $('<li>').append(a).appendTo(ul);
    },

};

function maybeParentheses(text, condition) {
    return condition ? ` (${text})` : text;
}

function appendComment($a, comment) {
    return $a.append(`<br /><span class="autocomplete-comment">${comment}</span>`);
}

function getLabelName(releaseLabel) {
    return releaseLabel.label ? releaseLabel.label.name : '';
}

function getCatalogNumber(releaseLabel) {
    return releaseLabel.catalogNumber || '';
}

function renderContainingAreas(area) {
    if (!area.containment) {
        return '';
    }
    return commaOnlyList(_(area.containment).map('name').value());
}

/*
   MB.Control.EntityAutocomplete is a helper class which simplifies using
   Autocomplete to look up entities.  It takes care of setting id and gid
   values on related hidden inputs.

   It expects to see html looking like this:

       <span class="ENTITY autocomplete">
          <img class="search" src="search.png" />
          <input type="text" class="name" />
          <input type="hidden" class="id" />
          <input type="hidden" class="gid" />
       </span>

   Do a lookup of the span with jQuery and pass it into EntityAutocomplete
   as options.inputs, for example, for a release group do this:

       MB.Control.EntityAutocomplete({ inputs: $('span.release-group.autocomplete') });

   The 'lookup-performed' and 'cleared' events will be triggered on the input.name
   element (though you can just bind on the span, as events will bubble up).
*/

MB.Control.EntityAutocomplete = function (options) {
    var $inputs = options.inputs || $();
    var $name = options.input || $inputs.find('input.name');

    if (!options.entity) {
        // guess the entity from span classes.
        _.some(_.keys(ENTITIES), function (entity) {
            entity = entity.replace(/_/g, '-');
            if ($inputs.hasClass(entity)) {
                options.entity = entity;
                return true;
            }
        });
    }

    $name.entitylookup(options);
    var autocomplete = $name.data('mb-entitylookup');

    autocomplete.currentSelection(MB_entity({
        name: $name.val(),
        id: $inputs.find('input.id').val(),
        gid: $inputs.find('input.gid').val(),
    }, options.entity));

    autocomplete.currentSelection.subscribe(function (item) {
        var $hidden = $inputs.find('input[type=hidden]').val('');

        // We need to do this manually, rather than using $.each, due to recordings
        // having a 'length' property.
        for (let key in item) {
            if (item.hasOwnProperty(key)) {
                $hidden.filter('input.' + key)
                    .val(item[key]).trigger('change');
            }
        }
    });

    return autocomplete;
};


ko.bindingHandlers.autocomplete = {

    init: function (element, valueAccessor) {
        var options = valueAccessor();

        $(element)
            .entitylookup(options)
            .data('mb-entitylookup')
            .menu.element[0]
            .setAttribute('data-input-id', element.id);
    },
};

function isLatin(str) {
    return !/[^\u0000-\u02ff\u1E00-\u1EFF\u2000-\u207F]/.test(str);
}
