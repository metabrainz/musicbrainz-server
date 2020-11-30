/*
 * Copyright (C) 2011 Ian McEwen
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {fixedWidthInteger} from '../static/scripts/common/utility/strings';

const stats = {
  'category': {
    'artist-countries': {label: l('Artist Countries')},
    'artist-other': {label: l('Artist Types and Genders')},
    'core-entities': {label: l('Core Entities')},
    'cover-art': {hide: true, label: l('Cover Art')},
    'edit-information': {hide: true, label: l('Edit Information')},
    'formats': {label: l('Formats')},
    'label-countries': {label: l('Label Countries')},
    'other': {label: lp('Other', 'stats category')},
    'ratings-tags': {label: l('Ratings and Tags')},
    'relationships': {hide: true, label: l('Relationships')},
    'release-countries': {label: l('Release Countries')},
    'release-languages': {label: l('Release Languages')},
    'release-quality': {label: l('Release Data Quality')},
    'release-scripts': {label: l('Release Scripts')},
  },
  'count.ar.links': {
    category: 'relationships',
    color: '#ff0000',
    description: l('Count of all Relationships'),
    label: l('Relationships'),
  },
  'count.area': {
    category: 'core-entities',
    color: '#ff0000',
    description: l('Count of all areas'),
    label: l('Areas'),
  },
  'count.artist': {
    category: 'core-entities',
    color: '#ff8a00',
    description: l('Count of all artists'),
    label: l('Artists'),
  },
  'count.artist.0credits': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with no appearances in artist credits'),
    label: l('Artists not in ACs'),
  },
  'count.artist.country.null': {
    category: 'artist-countries',
    color: '#ff0000',
    description: l('Artists with no country set'),
    label: l('Unknown Country'),
  },
  'count.artist.gender.female': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with gender set to female'),
    label: l('Female Artists'),
  },
  'count.artist.gender.male': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with gender set to male'),
    label: l('Male Artists'),
  },
  'count.artist.gender.not_applicable': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with gender set to not applicable'),
    label: l('Gender Not Applicable'),
  },
  'count.artist.gender.null': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with gender unset (non-group artists)'),
    label: l('Unknown-gender Artists'),
  },
  'count.artist.gender.other': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with gender set to other'),
    label: l('Other-gender Artists'),
  },
  'count.artist.has_credits': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with at least one artist credit appearance'),
    label: l('Artists in ACs'),
  },
  'count.artist.type.character': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type set to character'),
    label: l('Characters'),
  },
  'count.artist.type.choir': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type set to choir'),
    label: l('Choirs'),
  },
  'count.artist.type.group': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type set to group'),
    label: l('Groups'),
  },
  'count.artist.type.null': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type unset'),
    label: l('Unknown-type Artists'),
  },
  'count.artist.type.orchestra': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type set to orchestra'),
    label: l('Orchestras'),
  },
  'count.artist.type.other': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type set to other'),
    label: l('Other-type Artists'),
  },
  'count.artist.type.person': {
    category: 'artist-other',
    color: '#ff0000',
    description: l('Artists with type set to person'),
    label: l('Persons'),
  },
  'count.artistcredit': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Artist Credits'),
    label: l('Artist Credits'),
  },
  'count.barcode': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Barcodes'),
    label: l('Barcodes'),
  },
  'count.cdstub': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all CDStubs'),
    label: l('CDStubs (all)'),
  },
  'count.cdstub.submitted': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all CDStubs ever submitted'),
    label: l('CDStubs (submitted)'),
  },
  'count.cdstub.track': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all CDStub tracks'),
    label: l('CDStub tracks'),
  },
  'count.coverart': {
    category: 'cover-art',
    color: '#0022dd',
    description: l('Pieces of Cover Art'),
    label: l('Pieces of Cover Art'),
  },
  'count.discid': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Disc IDs'),
    label: l('Disc IDs'),
  },
  'count.edit': {
    category: 'edit-information',
    color: '#ff00ff',
    description: l('Count of all edits'),
    hide: true,
    label: l('Edits'),
  },
  'count.edit.applied': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('All edits that have been applied'),
    label: l('Applied edits'),
  },
  'count.edit.deleted': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('Cancelled edits'),
    label: l('Cancelled edits'),
  },
  'count.edit.error': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('All edits that have hit an error'),
    label: l('Error edits'),
  },
  'count.edit.evalnochange': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('Evalnochange edits'),
    label: l('Evalnochange Edits'),
  },
  'count.edit.faileddep': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('All edits that have failed dependency checks'),
    label: l('Failed edits (dependency)'),
  },
  'count.edit.failedprereq': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('All edits that have failed prerequisite checks'),
    label: l('Failed edits (prerequisite)'),
  },
  'count.edit.failedvote': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('All edits that have failed by being voted down'),
    label: l('Failed edits (voted down)'),
  },
  'count.edit.open': {
    category: 'edit-information',
    color: '#ffe400',
    description: l('Count of open edits'),
    label: l('Open Edits'),
  },
  'count.edit.perday': {
    category: 'edit-information',
    color: '#3d8100',
    description: l('Count of edits per day'),
    hide: true,
    label: l('Edits per day'),
  },
  'count.edit.perweek': {
    category: 'edit-information',
    color: '#78ff00',
    description: l('Count of edits per week'),
    label: l('Edits per week'),
  },
  'count.editor': {
    category: 'edit-information',
    color: '#ff0000',
    description: l('Count of all editors'),
    hide: true,
    label: l('Editors (all)'),
  },
  'count.editor.activelastweek': {
    category: 'edit-information',
    color: '#ff00cc',
    description: l(
      'Count of active editors (editing or voting) during the last week',
    ),
    label: l('Active Users'),
  },
  'count.editor.deleted': {
    category: 'edit-information',
    color: '#ffaaaa',
    description: l('Count of deleted editors'),
    hide: true,
    label: l('Editors (deleted)'),
  },
  'count.editor.editlastweek': {
    category: 'edit-information',
    color: '#6600ff',
    description: l(
      'Count of editors who have submitted edits during the last 7 days',
    ),
    label: l('Active Editors'),
  },
  'count.editor.valid': {
    category: 'edit-information',
    color: '#ff3333',
    description: l('Count of non-deleted editors'),
    hide: true,
    label: l('Editors (valid)'),
  },
  'count.editor.valid.active': {
    category: 'edit-information',
    color: '#ff3333',
    description: l('Count of active editors'),
    hide: true,
    label: l('Editors (valid & active ever)'),
  },
  'count.editor.votelastweek': {
    category: 'edit-information',
    color: '#cc00ff',
    description: l(
      'Count of editors who have voted on during the last 7 days',
    ),
    label: l('Active Voters'),
  },
  'count.event': {
    category: 'core-entities',
    color: '#e8ab08',
    description: l('Count of all events'),
    label: l('Events'),
  },
  'count.instrument': {
    category: 'core-entities',
    color: '#8fddc9',
    description: l('Count of all instruments'),
    label: l('Instruments'),
  },
  'count.ipi': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all IPIs'),
    label: l('IPIs'),
  },
  'count.ipi.artist': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all IPIs for Artists'),
    label: l('Artist IPIs'),
  },
  'count.ipi.label': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all IPIs for Labels'),
    label: l('Label IPIs'),
  },
  'count.isni': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISNIs'),
    label: l('ISNIs'),
  },
  'count.isni.artist': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISNIs for Artists'),
    label: l('Artist ISNIs'),
  },
  'count.isni.label': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISNIs for Labels'),
    label: l('Label ISNIs'),
  },
  'count.isrc': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISRCs'),
    label: l('ISRCs'),
  },
  'count.isrc.all': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISRCs'),
    label: l('ISRCs (all)'),
  },
  'count.iswc': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISWCs'),
    label: l('ISWCs'),
  },
  'count.iswc.all': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all ISWCs'),
    label: l('ISWCs (all)'),
  },
  'count.label': {
    category: 'core-entities',
    color: '#ff0096',
    description: l('Count of all labels'),
    label: l('Labels'),
  },
  'count.label.country.null': {
    category: 'label-countries',
    color: '#ff0000',
    description: l('Labels with no country set'),
    label: l('Unknown Country'),
  },
  'count.medium': {
    category: 'core-entities',
    color: '#00c0ff',
    description: l('Count of all mediums'),
    label: l('Mediums'),
  },
  'count.medium.format.null': {
    category: 'formats',
    color: '#ff0000',
    description: l('Mediums with no format set'),
    label: l('Unknown Format (medium)'),
  },
  'count.medium.has_discid': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Mediums with Disc IDs'),
    label: l('Mediums with Disc IDs'),
  },
  'count.place': {
    category: 'core-entities',
    color: '#bc0a0a',
    description: l('Count of all places'),
    label: l('Places'),
  },
  'count.quality.release.default': {
    category: 'release-quality',
    color: '#ff0000',
    description: l('Count of all Releases at Default Data Quality'),
    label: l('Default Data Quality'),
  },
  'count.quality.release.high': {
    category: 'release-quality',
    color: '#ff0000',
    description: l('Count of all Releases at High Data Quality'),
    label: l('High Data Quality'),
  },
  'count.quality.release.low': {
    category: 'release-quality',
    color: '#ff0000',
    description: l('Count of all Releases at Low Data Quality'),
    label: l('Low Data Quality'),
  },
  'count.quality.release.normal': {
    category: 'release-quality',
    color: '#ff0000',
    description: l('Count of all Releases at Normal Data Quality'),
    label: l('Normal Data Quality'),
  },
  'count.quality.release.unknown': {
    category: 'release-quality',
    color: '#ff0000',
    description: l('Count of all Releases at Unknown Data Quality'),
    label: l('Unknown Data Quality'),
  },
  'count.rating': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Ratings'),
    label: l('Ratings'),
  },
  'count.rating.artist': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Artist Ratings'),
    label: l('Artist Ratings'),
  },
  'count.rating.label': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Label Ratings'),
    label: l('Label Ratings'),
  },
  'count.rating.raw': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Ratings (raw)'),
    label: l('Ratings (raw)'),
  },
  'count.rating.raw.artist': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Artist Ratings (raw)'),
    label: l('Artist Ratings (raw)'),
  },
  'count.rating.raw.label': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Label Ratings (raw)'),
    label: l('Label Ratings (raw)'),
  },
  'count.rating.raw.recording': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Recording Ratings (raw)'),
    label: l('Recording Ratings (raw)'),
  },
  'count.rating.raw.releasegroup': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Release Group Ratings (raw)'),
    label: l('Release Group Ratings (raw)'),
  },
  'count.rating.raw.work': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Work Ratings (raw)'),
    label: l('Work Ratings (raw)'),
  },
  'count.rating.recording': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Recording Ratings'),
    label: l('Recording Ratings'),
  },
  'count.rating.releasegroup': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Release Group Ratings'),
    label: l('Release Group Ratings'),
  },
  'count.rating.work': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Work Ratings'),
    label: l('Work Ratings'),
  },
  'count.recording': {
    category: 'core-entities',
    color: '#4800ff',
    description: l('Count of all recordings'),
    label: l('Recordings'),
  },
  'count.recording.has_isrc': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Recordings with ISRCs'),
    label: l('Recordings with ISRCs'),
  },
  'count.release': {
    category: 'core-entities',
    color: '#a8ff00',
    description: l('Count of all releases'),
    label: l('Releases'),
  },
  'count.release.country.null': {
    category: 'release-countries',
    color: '#ff0000',
    description: l('Releases with no country set'),
    label: l('Unknown Country'),
  },
  'count.release.coverart.amazon': {
    category: 'cover-art',
    color: '#dd22dd',
    description: l('Releases with Amazon Cover Art'),
    label: l('Releases with Amazon Cover Art'),
  },
  'count.release.coverart.caa': {
    category: 'cover-art',
    color: '#dd0022',
    description: l('Releases with CAA Cover Art'),
    label: l('Releases with CAA Cover Art'),
  },
  'count.release.coverart.none': {
    category: 'cover-art',
    color: '#00dd22',
    description: l('Releases with No Cover Art'),
    label: l('Releases with No Cover Art'),
  },
  'count.release.coverart.relationship': {
    category: 'cover-art',
    color: '#2200dd',
    description: l('Releases with Amazon Cover Art'),
    label: l('Releases with Cover Art from Relationships'),
  },
  'count.release.format.null': {
    category: 'formats',
    color: '#ff0000',
    description: l('Releases with a no-format medium'),
    label: l('Unknown Format (release)'),
  },
  'count.release.has_caa': {
    category: 'cover-art',
    color: '#22eedd',
    description: l('Releases with Cover Art'),
    label: l('Releases with Cover Art'),
  },
  'count.release.has_discid': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Releases with Disc IDs'),
    label: l('Releases with Disc IDs'),
  },
  'count.release.language.null': {
    category: 'release-languages',
    color: '#ff0000',
    description: l('Releases with no language set'),
    label: l('Unknown Language'),
  },
  'count.release.nonvarious': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Releases not V.A.'),
    label: l('Releases not VA'),
  },
  'count.release.script.null': {
    category: 'release-scripts',
    color: '#ff0000',
    description: l('Releases with no script set'),
    label: l('Unknown Script'),
  },
  'count.release.various': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Releases by Various Artists'),
    label: l('Releases (VA)'),
  },
  'count.releasegroup': {
    category: 'core-entities',
    color: '#ae00ff',
    description: l('Count of all release groups'),
    label: l('Release Groups'),
  },
  'count.series': {
    category: 'core-entities',
    color: '#1a6756',
    description: l('Count of all series'),
    label: lp('Series', 'plural'),
  },
  'count.tag': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Tags'),
    label: l('Tags'),
  },
  'count.tag.raw': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Tags (raw)'),
    label: l('Tags (raw)'),
  },
  'count.tag.raw.area': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Area Tags (raw)'),
    label: l('Area Tags (raw)'),
  },
  'count.tag.raw.artist': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Artist Tags (raw)'),
    label: l('Artist Tags (raw)'),
  },
  'count.tag.raw.instrument': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Instrument Tags (raw)'),
    label: l('Instrument Tags (raw)'),
  },
  'count.tag.raw.label': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Label Tags (raw)'),
    label: l('Label Tags (raw)'),
  },
  'count.tag.raw.recording': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Recording Tags (raw)'),
    label: l('Recording Tags (raw)'),
  },
  'count.tag.raw.release': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Release Tags (raw)'),
    label: l('Release Tags (raw)'),
  },
  'count.tag.raw.releasegroup': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Release Group Tags (raw)'),
    label: l('Release Group Tags (raw)'),
  },
  'count.tag.raw.series': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Series Tags (raw)'),
    label: l('Series Tags (raw)'),
  },
  'count.tag.raw.work': {
    category: 'ratings-tags',
    color: '#ff0000',
    description: l('Count of all Work Tags (raw)'),
    label: l('Work Tags (raw)'),
  },
  'count.track': {
    category: 'other',
    color: '#ff0000',
    description: l('Count of all Tracks'),
    label: l('Tracks'),
  },
  'count.vote': {
    category: 'edit-information',
    color: '#00ffff',
    description: l('Count of all votes'),
    hide: true,
    label: l('Votes'),
  },
  'count.vote.abstain': {
    category: 'edit-information',
    color: '#00ffff',
    description: l('Count of all Abstain votes'),
    label: l('Abstentions'),
  },
  'count.vote.no': {
    category: 'edit-information',
    color: '#00ffff',
    description: l('Count of all No votes'),
    label: l('No Votes'),
  },
  'count.vote.perday': {
    category: 'edit-information',
    color: '#007681',
    description: l('Count of votes per day'),
    hide: true,
    label: l('Votes per day'),
  },
  'count.vote.perweek': {
    category: 'edit-information',
    color: '#00eaff',
    description: l('Count of votes per week'),
    label: l('Votes per week'),
  },
  'count.vote.yes': {
    category: 'edit-information',
    color: '#00ffff',
    description: l('Count of all Yes votes'),
    label: l('Yes Votes'),
  },
  'count.work': {
    category: 'core-entities',
    color: '#00ffa8',
    description: l('Count of all works'),
    label: l('Works'),
  },
  'rateTooltipCloser': l('/day'),
};

for (let n = 0; n < 11; n++) {
  const no = {n};

  stats[`count.release.${n}discids`] = {
    category: 'other',
    color: '#ff0000',
    description: texp.l('Count of all Releases with {n} Disc IDs', no),
    label: texp.ln(
      'Releases with 1 Disc ID',
      'Releases with {n} Disc IDs',
      n,
      no,
    ),
  };

  stats[`count.medium.${n}discids`] = {
    category: 'other',
    color: '#ff0000',
    description: texp.l('Count of all Mediums with {n} Disc IDs', no),
    label: texp.ln(
      'Mediums with 1 Disc ID',
      'Mediums with {n} Disc IDs',
      n,
      no,
    ),
  };

  stats[`count.recording.${n}releases`] = {
    category: 'other',
    color: '#ff0000',
    description: texp.l('Count of all Recordings with {n} Releases', no),
    label: texp.ln(
      'Recordings with 1 Release',
      'Recordings with {n} Releases',
      n,
      no,
    ),
  };

  stats[`count.releasegroup.${n}releases`] = {
    category: 'other',
    color: '#ff0000',
    description: texp.l('Count of all Release Groups with {n} Releases', no),
    label: texp.ln(
      'Release Groups with 1 Release',
      'Release Groups with {n} Releases',
      n,
      no,
    ),
  };
}

export default stats;

export function getStat(name) {
  let stat = stats[name];
  if (!stat) {
    stat = {
      category: 'other',
      color: '#' + Math.random().toString(16).substr(-6),
      description: name,
      label: name,
    };
    stats[name] = stat;
  }
  return stat;
}

export function buildTypeStats(typeData) {
  const {
    countries,
    formats,
    languages,
    relationships,
    scripts,
  } = typeData;

  for (const key in countries) {
    const country = countries[key];
    const countryName = l_countries(country.name);
    const countryArg = {country: countryName};

    stats[`count.artist.country.${key}`] = {
      category: 'artist-countries',
      color: '#ff0000',
      description: countryName,
      label: texp.l('{country} artists', countryArg),
    };

    stats[`count.label.country.${key}`] = {
      category: 'label-countries',
      color: '#ff0000',
      description: countryName,
      label: texp.l('{country} labels', countryArg),
    };

    stats[`count.release.country.${key}`] = {
      category: 'release-countries',
      color: '#ff0000',
      description: countryName,
      label: texp.l('{country} releases', countryArg),
    };
  }

  for (const key in formats) {
    const format = formats[key];
    const formatArg = {name: lp_attributes(format.name, 'medium_format')};

    stats[`count.release.format.${key}`] = {
      category: 'formats',
      color: '#ff0000',
      description: '',
      label: texp.l('{name} releases', formatArg),
    };

    stats[`count.medium.format.${key}`] = {
      category: 'formats',
      color: '#ff0000',
      description: '',
      label: texp.l('{name} mediums', formatArg),
    };
  }

  for (const key in languages) {
    const language = languages[key];
    const languageName = l_languages(language.name);

    stats[`count.release.language.${key}`] = {
      category: 'release-languages',
      color: '#ff0000',
      description: languageName,
      label: texp.l('{language} releases', {language: languageName}),
    };
  }

  for (let i = 0; i < relationships.length; i++) {
    const pair = relationships[i];
    const hex = fixedWidthInteger((i + 1) * 3, 2);
    const label = texp.l('l_{first}_{second} Relationships', {
      first: pair[0],
      second: pair[1],
    });

    stats[`count.ar.links.l_${pair[0]}_${pair[1]}`] = {
      category: 'relationships',
      color: `#5${hex}F${hex}`,
      description: label,
      label,
    };
  }

  for (const key in scripts) {
    const script = scripts[key];
    const scriptName = l_scripts(script.name);

    stats[`count.release.script.${key}`] = {
      category: 'release-scripts',
      color: '#ff0000',
      description: scriptName,
      label: texp.l('{script} releases', {script: scriptName}),
    };
  }
}
