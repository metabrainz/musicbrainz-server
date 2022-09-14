/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import {compare} from '../common/i18n.js';
import {isCompleteArtistCredit} from '../common/immutable-entities.js';
import MB from '../common/MB.js';
import {compactMap, sortByString} from '../common/utility/arrays.js';
import {debounceComputed} from '../common/utility/debounce.js';
import request from '../common/utility/request.js';

import utils from './utils.js';
import releaseEditor from './viewModel.js';


var releaseGroupReleases = ko.observableArray([]);


releaseEditor.similarReleases = ko.observableArray([]);
releaseEditor.baseRelease = ko.observable('');


releaseEditor.baseRelease.subscribe(function (gid) {
  var release = releaseEditor.rootField.release();

  if (!gid) {
    release.mediums([new releaseEditor.fields.Medium({}, release)]);
    return;
  }

  releaseEditor.loadRelease(gid, function (data) {
    release.mediums(
      data.mediums.map(function (m) {
        return new releaseEditor.fields.Medium(
          utils.reuseExistingMediumData(m), release,
        );
      }),
    );
    release.loadMedia();
  });
});


releaseEditor.findReleaseDuplicates = function () {
  var loadingFromRG = false;

  utils.withRelease(function (release) {
    var releaseGroup = release.releaseGroup();
    var gid = releaseGroup.gid;

    if (!gid) {
      return;
    }

    var url = `/ws/2/release?release-group=${gid}&inc=labels+media&fmt=json`;

    loadingFromRG = true;
    toggleLoadingIndicator(true);

    request({url: url})
      .always(function () {
        loadingFromRG = false;
        toggleLoadingIndicator(false);
      })
      .done(function (data) {
        releaseGroupReleases(data.releases.map(formatReleaseData));
      });
  });

  debounceComputed(utils.withRelease(function (release) {
    var name = release.name();

    /*
     * If a release group is selected, just show the releases from
     * there without searching.
     */
    var rgReleases = releaseGroupReleases();

    if (rgReleases.length > 0) {
      releaseEditor.similarReleases(rgReleases);
      $('#release-editor').tabs('enable', 1);
      return;
    }

    var ac = release.artistCredit();

    if (loadingFromRG || !name || !isCompleteArtistCredit(ac)) {
      return;
    }

    var query = utils.constructLuceneFieldConjunction({
      release: [utils.escapeLuceneValue(name)],

      arid: ac.names.map(
        x => utils.escapeLuceneValue(x.artist.gid),
      ),
    });

    toggleLoadingIndicator(true);

    utils.search('release', query, 10).done(gotResults);
  }));
};


function gotResults(data) {
  var releases = data.releases.filter(function (release) {
    return parseInt(release.score, 10) >= 65;
  });

  if (releases.length > 0) {
    releaseEditor.similarReleases(releases.map(formatReleaseData));

    $('#release-editor').tabs('enable', 1);
  } else {
    $('#release-editor').tabs('disable', 1);
  }

  toggleLoadingIndicator(false);
}


function toggleLoadingIndicator(show) {
  $('#release-editor').data('ui-tabs')
    .tabs.eq(1).toggleClass('loading-tab', show);
}


function formatReleaseData(release) {
  var clean = new MB.entity.Release(utils.cleanWebServiceData(release));

  var events = release['release-events'];
  var labels = release['label-info'];

  clean.formats = combinedMediumFormatName(release.media) ||
                  l('[missing media]');
  clean.tracks = release.media.map(x => x['track-count']).join(' + ') ||
    lp('-', 'missing data');

  clean.dates = events
    ? compactMap(events, x => x.date)
    : [];

  clean.countries = events ? [...new Set(events.flatMap(
    x => (x.area?.['iso-3166-1-codes']) ?? [],
  ))] : [];

  clean.labels = labels ? (
    sortByString(
      compactMap(labels, function (info) {
        const label = info.label;
        if (label) {
          return new MB.entity.Label({gid: label.id, name: label.name});
        }
        return null;
      }),
      label => label.name,
      compare,
    )
  ) : [];

  clean.catalogNumbers = labels
    ? compactMap(labels, x => x['catalog-number'])
    : [];

  clean.barcode = release.barcode || '';

  return clean;
}

const getFormat = medium => medium.format || '';

function combinedMediumFormatName(mediums) {
  const formatCounts = new Map();

  for (const medium of mediums) {
    const format = getFormat(medium);
    formatCounts.set(format, (formatCounts.get(format) ?? 0) + 1);
  }

  return Array.from(formatCounts.entries())
    .map(function ([format, count]) {
      return (count > 1 ? count + '\u00D7' : '') +
                (format
                  ? lp_attributes(format, 'medium_format')
                  : lp('(unknown)', 'medium format'));
    })
    .join(' + ');
}
