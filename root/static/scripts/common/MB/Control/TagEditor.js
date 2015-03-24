// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var i18n = require('../../i18n.js');

MB.Control.TagEditor = function (container, endpoint, viewTag, moreHtml)
{
    var self = {};
    var tagTemplate = _.template('<a href="' + viewTag + '<%- tagLink %>"><%- tag %></a>');

    self.$container = $(container);
    self.$tagList = self.$container.find('span.tags');
    self.$apply = self.$container.find('button[type="submit"]');
    self.$tagInput = self.$container.find('.tag-input');

    self.submitTags = function (tags) {
        $.post(endpoint, { tags: tags }, function (data) {
            self.updateTagDisplay(data.tags, data.more);
        }, 'json');
    };

    self.updateTagDisplay = function (tags, more) {
        var html = tags.length ? tags.map(function (tag) {
                return tagTemplate({
                    tag: tag,
                    tagLink: encodeURIComponent(tag)
                });
            }).join(', ') : i18n.lp("(none)", "tag");

        if (more) {
            html += ', ' + moreHtml;
        }

        self.$tagList.html(html);
    };

    self.$apply.click(function (ev) {
        ev.preventDefault();
        self.submitTags(self.$tagInput.val());
    });

    return self;
}
