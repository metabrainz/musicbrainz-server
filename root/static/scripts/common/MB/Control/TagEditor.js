/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

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

MB.Control.TagEditor = function(container, endpoint, viewTag, moreHtml)
{
    var self = MB.Object();
    var tagTemplate = MB.utility.template('<a href="' + viewTag + '#{tagLink}">#{tag}</a>');

    self.$container = $(container);
    self.$tagList = self.$container.find('span.tags');
    self.$apply = self.$container.find('button[type="submit"]');
    self.$tagInput = self.$container.find('.tag-input');

    self.submitTags = function(tags) {
        $.post(endpoint, { tags: tags }, function(data) {
            self.updateTagDisplay(data.tags, data.more);
        }, 'json');
    };

    self.updateTagDisplay = function(tags, more) {
        var html = tags.length ? tags.map(function(tag) {
                return tagTemplate.draw({
                    tag: tag,
                    tagLink: encodeURIComponent(tag)
                });
            }).join(', ') : MB.text.TagNone;

        if (more) {
            html += ', ' + moreHtml;
        }

        self.$tagList.html(html);
    };

    self.$apply.click(function(ev) {
        ev.preventDefault();
        self.submitTags(self.$tagInput.val());
    });

    return self;
}
