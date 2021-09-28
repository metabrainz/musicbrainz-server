/*
 * Copyright (C) 2011 Ian McEwen
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import formatEntityTypeName
  from '../static/scripts/common/utility/formatEntityTypeName';
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
    label: l('Relationships'),
  },
  'count.area': {
    category: 'core-entities',
    color: '#ff0000',
    label: l('Areas'),
  },
  'count.artist': {
    category: 'core-entities',
    color: '#ff8a00',
    label: l('Artists'),
  },
  'count.artist.0credits': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Artists with no appearances in artist credits'),
  },
  'count.artist.country.null': {
    category: 'artist-countries',
    color: '#ff0000',
    label: l('Artists with no country set'),
  },
  'count.artist.gender.female': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Female Artists'),
  },
  'count.artist.gender.male': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Male Artists'),
  },
  'count.artist.gender.not_applicable': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Gender Not Applicable'),
  },
  'count.artist.gender.null': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Artists with no gender set (non-group artists)'),
  },
  'count.artist.gender.other': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Artists with gender set to Other'),
  },
  'count.artist.has_credits': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Artists with at least one artist credit appearance'),
  },
  'count.artist.type.character': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Characters'),
  },
  'count.artist.type.choir': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Choirs'),
  },
  'count.artist.type.group': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Groups'),
  },
  'count.artist.type.null': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Artists with no type set'),
  },
  'count.artist.type.orchestra': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Orchestras'),
  },
  'count.artist.type.other': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Artists with type set to Other'),
  },
  'count.artist.type.person': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Persons'),
  },
  'count.artistcredit': {
    category: 'other',
    color: '#ff0000',
    label: l('Artist Credits'),
  },
  'count.barcode': {
    category: 'other',
    color: '#ff0000',
    label: l('Barcodes'),
  },
  'count.cdstub': {
    category: 'other',
    color: '#ff0000',
    label: l('CDStubs (current)'),
  },
  'count.cdstub.submitted': {
    category: 'other',
    color: '#ff0000',
    label: l('CDStubs (ever submitted)'),
  },
  'count.cdstub.track': {
    category: 'other',
    color: '#ff0000',
    label: l('CDStub tracks'),
  },
  'count.collection': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections'),
  },
  'count.collection.has_collaborators': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections with collaborators'),
  },
  'count.collection.private': {
    category: 'collection',
    color: '#ff0000',
    label: l('Private collections'),
  },
  'count.collection.public': {
    category: 'collection',
    color: '#ff0000',
    label: l('Public collections'),
  },
  'count.collection.type.area': {
    category: 'collection',
    color: '#ff0000',
    label: l('Area collections'),
  },
  'count.collection.type.artist': {
    category: 'collection',
    color: '#ff0000',
    label: l('Artist collections'),
  },
  'count.collection.type.attending': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections of type Attending'),
  },
  'count.collection.type.event': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections of type Event'),
  },
  'count.collection.type.event.all': {
    category: 'collection',
    color: '#ff0000',
    label: l('Event collections (all types)'),
  },
  'count.collection.type.instrument': {
    category: 'collection',
    color: '#ff0000',
    label: l('Instrument collections'),
  },
  'count.collection.type.label': {
    category: 'collection',
    color: '#ff0000',
    label: l('Label collections'),
  },
  'count.collection.type.maybe_attending': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections of type Maybe attending'),
  },
  'count.collection.type.owned': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections of type Owned music'),
  },
  'count.collection.type.place': {
    category: 'collection',
    color: '#ff0000',
    label: l('Place collections'),
  },
  'count.collection.type.recording': {
    category: 'collection',
    color: '#ff0000',
    label: l('Recording collections'),
  },
  'count.collection.type.release': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections of type Release'),
  },
  'count.collection.type.release.all': {
    category: 'collection',
    color: '#ff0000',
    label: l('Release collections (all types)'),
  },
  'count.collection.type.release_group': {
    category: 'collection',
    color: '#ff0000',
    label: l('Release group collections'),
  },
  'count.collection.type.series': {
    category: 'collection',
    color: '#ff0000',
    label: l('Series collections'),
  },
  'count.collection.type.wishlist': {
    category: 'collection',
    color: '#ff0000',
    label: l('Collections of type Wishlist'),
  },
  'count.collection.type.work': {
    category: 'collection',
    color: '#ff0000',
    label: l('Work collections'),
  },
  'count.coverart': {
    category: 'cover-art',
    color: '#0022dd',
    label: l('Pieces of Cover Art'),
  },
  'count.discid': {
    category: 'other',
    color: '#ff0000',
    label: l('Disc IDs'),
  },
  'count.edit': {
    category: 'edit-information',
    color: '#ff00ff',
    hide: true,
    label: l('Edits'),
  },
  'count.edit.applied': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Applied edits'),
  },
  'count.edit.deleted': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Cancelled edits'),
  },
  'count.edit.error': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Error edits'),
  },
  'count.edit.evalnochange': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Evalnochange Edits'),
  },
  'count.edit.faileddep': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Failed edits (failed dependency checks)'),
  },
  'count.edit.failedprereq': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Failed edits (failed prerequisite checks)'),
  },
  'count.edit.failedvote': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Failed edits (voted down)'),
  },
  'count.edit.open': {
    category: 'edit-information',
    color: '#ffe400',
    label: l('Open Edits'),
  },
  'count.edit.perday': {
    category: 'edit-information',
    color: '#3d8100',
    hide: true,
    label: l('Edits per day'),
  },
  'count.edit.perweek': {
    category: 'edit-information',
    color: '#78ff00',
    label: l('Edits per week'),
  },
  'count.editor': {
    category: 'edit-information',
    color: '#ff0000',
    hide: true,
    label: l('Editors (all)'),
  },
  'count.editor.activelastweek': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who edited or voted in the last week'),
  },
  'count.editor.deleted': {
    category: 'edit-information',
    color: '#ffaaaa',
    hide: true,
    label: l('Editors (deleted)'),
  },
  'count.editor.editlastweek': {
    category: 'edit-information',
    color: '#6600ff',
    label: l('Editors who submitted edits in the last week'),
  },
  'count.editor.valid': {
    category: 'edit-information',
    color: '#ff3333',
    hide: true,
    label: l('Editors (current)'),
  },
  'count.editor.valid.active': {
    category: 'edit-information',
    color: '#ff3333',
    hide: true,
    label: l('Editors (current) who have ever been active'),
  },
  'count.editor.votelastweek': {
    category: 'edit-information',
    color: '#cc00ff',
    label: l('Editors who have voted in the last week'),
  },
  'count.event': {
    category: 'core-entities',
    color: '#e8ab08',
    label: l('Events'),
  },
  'count.instrument': {
    category: 'core-entities',
    color: '#8fddc9',
    label: l('Instruments'),
  },
  'count.ipi': {
    category: 'other',
    color: '#ff0000',
    label: l('IPIs'),
  },
  'count.ipi.artist': {
    category: 'other',
    color: '#ff0000',
    label: l('Artist IPIs'),
  },
  'count.ipi.label': {
    category: 'other',
    color: '#ff0000',
    label: l('Label IPIs'),
  },
  'count.isni': {
    category: 'other',
    color: '#ff0000',
    label: l('ISNIs'),
  },
  'count.isni.artist': {
    category: 'other',
    color: '#ff0000',
    label: l('Artist ISNIs'),
  },
  'count.isni.label': {
    category: 'other',
    color: '#ff0000',
    label: l('Label ISNIs'),
  },
  'count.isrc': {
    category: 'other',
    color: '#ff0000',
    label: l('ISRCs (unique)'),
  },
  'count.isrc.all': {
    category: 'other',
    color: '#ff0000',
    label: l('ISRCs (all uses)'),
  },
  'count.iswc': {
    category: 'other',
    color: '#ff0000',
    label: l('ISWCs (unique)'),
  },
  'count.iswc.all': {
    category: 'other',
    color: '#ff0000',
    label: l('ISWCs (all uses)'),
  },
  'count.label': {
    category: 'core-entities',
    color: '#ff0096',
    label: l('Labels'),
  },
  'count.label.country.null': {
    category: 'label-countries',
    color: '#ff0000',
    label: l('Labels with no country set'),
  },
  'count.medium': {
    category: 'core-entities',
    color: '#00c0ff',
    label: l('Mediums'),
  },
  'count.medium.format.null': {
    category: 'formats',
    color: '#ff0000',
    label: l('Mediums with no format set'),
  },
  'count.medium.has_discid': {
    category: 'other',
    color: '#ff0000',
    label: l('Mediums with Disc IDs'),
  },
  'count.place': {
    category: 'core-entities',
    color: '#bc0a0a',
    label: l('Places'),
  },
  'count.quality.release.default': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Default (Normal + Unknown) Data Quality'),
  },
  'count.quality.release.high': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('High Data Quality'),
  },
  'count.quality.release.low': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Low Data Quality'),
  },
  'count.quality.release.normal': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Normal Data Quality'),
  },
  'count.quality.release.unknown': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Unknown Data Quality'),
  },
  'count.rating': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Entities with ratings'),
  },
  'count.rating.artist': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Artists with ratings'),
  },
  'count.rating.label': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Labels with ratings'),
  },
  'count.rating.place': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Places with ratings'),
  },
  'count.rating.raw': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Ratings'),
  },
  'count.rating.raw.artist': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Artist ratings'),
  },
  'count.rating.raw.label': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Label ratings'),
  },
  'count.rating.raw.place': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Place ratings'),
  },
  'count.rating.raw.recording': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Recording ratings'),
  },
  'count.rating.raw.releasegroup': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Release group ratings'),
  },
  'count.rating.raw.work': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Work ratings'),
  },
  'count.rating.recording': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Recordings with ratings'),
  },
  'count.rating.releasegroup': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Release Groups with ratings'),
  },
  'count.rating.work': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Works with ratings'),
  },
  'count.recording': {
    category: 'core-entities',
    color: '#4800ff',
    label: l('Recordings'),
  },
  'count.recording.has_isrc': {
    category: 'other',
    color: '#ff0000',
    label: l('Recordings with ISRCs'),
  },
  'count.recording.standalone': {
    category: 'other',
    color: '#ff0000',
    label: l('Standalone recordings'),
  },
  'count.release': {
    category: 'core-entities',
    color: '#a8ff00',
    label: l('Releases'),
  },
  'count.release.country.null': {
    category: 'release-countries',
    color: '#ff0000',
    label: l('Releases with no country set'),
  },
  'count.release.coverart.amazon': {
    category: 'cover-art',
    color: '#dd22dd',
    label: l('Releases with Amazon Cover Art'),
  },
  'count.release.coverart.caa': {
    category: 'cover-art',
    color: '#dd0022',
    label: l('Releases with CAA Cover Art'),
  },
  'count.release.coverart.none': {
    category: 'cover-art',
    color: '#00dd22',
    label: l('Releases with No Cover Art'),
  },
  'count.release.coverart.relationship': {
    category: 'cover-art',
    color: '#2200dd',
    label: l('Releases with Cover Art from Relationships'),
  },
  'count.release.format.null': {
    category: 'formats',
    color: '#ff0000',
    label: l('Releases with a no-format medium'),
  },
  'count.release.has_caa': {
    category: 'cover-art',
    color: '#22eedd',
    label: l('Releases with Cover Art'),
  },
  'count.release.has_discid': {
    category: 'other',
    color: '#ff0000',
    label: l('Releases with Disc IDs'),
  },
  'count.release.language.null': {
    category: 'release-languages',
    color: '#ff0000',
    label: l('Releases with no language set'),
  },
  'count.release.nonvarious': {
    category: 'other',
    color: '#ff0000',
    label: l('Releases not credited to Various Artists'),
  },
  'count.release.script.null': {
    category: 'release-scripts',
    color: '#ff0000',
    label: l('Releases with no script set'),
  },
  'count.release.various': {
    category: 'other',
    color: '#ff0000',
    label: l('Releases credited to Various Artists'),
  },
  'count.releasegroup': {
    category: 'core-entities',
    color: '#ae00ff',
    label: l('Release Groups'),
  },
  'count.series': {
    category: 'core-entities',
    color: '#1a6756',
    label: lp('Series', 'plural'),
  },
  'count.tag': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Unique tag names'),
  },
  'count.tag.raw': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against tags'),
  },
  'count.tag.raw.area': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against area tags'),
  },
  'count.tag.raw.artist': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against artist tags'),
  },
  'count.tag.raw.instrument': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against instrument tags'),
  },
  'count.tag.raw.label': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against label tags'),
  },
  'count.tag.raw.recording': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against recording tags'),
  },
  'count.tag.raw.release': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against release tags'),
  },
  'count.tag.raw.releasegroup': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against release group tags'),
  },
  'count.tag.raw.series': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against series tags'),
  },
  'count.tag.raw.work': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: l('Votes for/against work tags'),
  },
  'count.track': {
    category: 'other',
    color: '#ff0000',
    label: l('Tracks'),
  },
  'count.vote': {
    category: 'edit-information',
    color: '#00ffff',
    hide: true,
    label: l('Votes'),
  },
  'count.vote.abstain': {
    category: 'edit-information',
    color: '#00ffff',
    label: l('Abstentions'),
  },
  'count.vote.no': {
    category: 'edit-information',
    color: '#00ffff',
    label: l('No Votes'),
  },
  'count.vote.perday': {
    category: 'edit-information',
    color: '#007681',
    hide: true,
    label: l('Votes per day'),
  },
  'count.vote.perweek': {
    category: 'edit-information',
    color: '#00eaff',
    label: l('Votes per week'),
  },
  'count.vote.yes': {
    category: 'edit-information',
    color: '#00ffff',
    label: l('Yes Votes'),
  },
  'count.work': {
    category: 'core-entities',
    color: '#00ffa8',
    label: l('Works'),
  },
  'count.work.has_iswc': {
    category: 'other',
    color: '#ff0000',
    label: l('Works with ISWCs'),
  },
  'rateTooltipCloser': l('/day'),
};

for (let n = 0; n < 11; n++) {
  const no = {n};

  stats[`count.release.${n}discids`] = {
    category: 'other',
    color: '#ff0000',
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
      label: texp.l('{country} artists', countryArg),
    };

    stats[`count.label.country.${key}`] = {
      category: 'label-countries',
      color: '#ff0000',
      label: texp.l('{country} labels', countryArg),
    };

    stats[`count.release.country.${key}`] = {
      category: 'release-countries',
      color: '#ff0000',
      label: texp.l('{country} releases', countryArg),
    };
  }

  for (const key in formats) {
    const format = formats[key];
    const formatArg = {name: lp_attributes(format.name, 'medium_format')};

    stats[`count.release.format.${key}`] = {
      category: 'formats',
      color: '#ff0000',
      label: texp.l('{name} releases', formatArg),
    };

    stats[`count.medium.format.${key}`] = {
      category: 'formats',
      color: '#ff0000',
      label: texp.l('{name} mediums', formatArg),
    };
  }

  for (const key in languages) {
    const language = languages[key];
    const languageName = l_languages(language.name);

    stats[`count.release.language.${key}`] = {
      category: 'release-languages',
      color: '#ff0000',
      label: texp.l('{language} releases', {language: languageName}),
    };
  }

  for (let i = 0; i < relationships.length; i++) {
    const pair = relationships[i];
    const hex = fixedWidthInteger((i + 1) * 3, 2);
    const label = texp.l(
      '{first_entity_type}-{second_entity_type} Relationships',
      {
        first_entity_type: formatEntityTypeName(pair[0]),
        second_entity_type: formatEntityTypeName(pair[1]),
      },
    );

    stats[`count.ar.links.l_${pair[0]}_${pair[1]}`] = {
      category: 'relationships',
      color: `#5${hex}F${hex}`,
      label,
    };
  }

  for (const key in scripts) {
    const script = scripts[key];
    const scriptName = l_scripts(script.name);

    stats[`count.release.script.${key}`] = {
      category: 'release-scripts',
      color: '#ff0000',
      label: texp.l('{script} releases', {script: scriptName}),
    };
  }
}
