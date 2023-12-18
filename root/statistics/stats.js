/*
 * Copyright (C) 2011 Ian McEwen
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import formatEntityTypeName
  from '../static/scripts/common/utility/formatEntityTypeName.js';
import {fixedWidthInteger} from '../static/scripts/common/utility/strings.js';

const stats = {
  'category': {
    'area-types': {label: l('Area types')},
    'artist-countries': {label: l('Artist countries')},
    'artist-other': {label: l('Artist types and genders')},
    'collection': {label: l('Collections')},
    'core-entities': {label: l('Core entities')},
    'cover-art': {hide: true, label: lp('Cover art', 'plural')},
    'edit-information': {hide: true, label: lp('Edit information', 'noun')},
    'edit-types': {label: lp('Edit types', 'noun')},
    'event-types': {label: l('Event types')},
    'formats': {label: l('Formats')},
    'instrument-types': {label: l('Instrument types')},
    'label-countries': {label: l('Label countries')},
    'label-types': {label: l('Label types')},
    'other': {label: lp('Other', 'stats category')},
    'place-types': {label: l('Place types')},
    'ratings-tags': {label: lp('Ratings and tags', 'folksonomy')},
    'relationships': {hide: true, label: l('Relationships')},
    'release-countries': {label: l('Release countries')},
    'release-group-types': {label: l('Release group types')},
    'release-languages': {label: l('Release languages')},
    'release-packagings': {label: l('Release packagings')},
    'release-quality': {label: l('Release data quality')},
    'release-scripts': {label: l('Release scripts')},
    'release-statuses': {label: l('Release statuses')},
    'series-types': {label: l('Series types')},
    'work-attributes': {label: l('Work attributes')},
    'work-languages': {label: l('Work languages')},
    'work-types': {label: l('Work types')},
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
  'count.area.type.null': {
    category: 'area-types',
    color: '#ff0000',
    label: l('Areas with no type set'),
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
    label: l('Female artists'),
  },
  'count.artist.gender.male': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Male artists'),
  },
  'count.artist.gender.nonbinary': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Non-binary Artists'),
  },
  'count.artist.gender.not_applicable': {
    category: 'artist-other',
    color: '#ff0000',
    label: l('Gender not applicable'),
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
    label: l('Artist credits'),
  },
  'count.barcode': {
    category: 'other',
    color: '#ff0000',
    label: l('Barcodes'),
  },
  'count.cdstub': {
    category: 'other',
    color: '#ff0000',
    label: l('CD stubs (current)'),
  },
  'count.cdstub.submitted': {
    category: 'other',
    color: '#ff0000',
    label: l('CD stubs (ever submitted)'),
  },
  'count.cdstub.track': {
    category: 'other',
    color: '#ff0000',
    label: l('CD stub tracks'),
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
    label: l('Pieces of cover art'),
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
  'count.edit.faileddep': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Edits that have failed dependency checks'),
  },
  'count.edit.failedprereq': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Edits that have failed prerequisite checks'),
  },
  'count.edit.failedvote': {
    category: 'edit-information',
    color: '#ff0000',
    label: l('Edits that have been voted down'),
  },
  'count.edit.open': {
    category: 'edit-information',
    color: '#ffe400',
    label: lp('Open edits', 'noun'),
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
  'count.editor.valid.active.applications': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have registered applications'),
  },
  'count.editor.valid.active.collections': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who use collections'),
  },
  'count.editor.valid.active.edits': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have made edits'),
  },
  'count.editor.valid.active.notes': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have written edit notes'),
  },
  'count.editor.valid.active.ratings': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have added ratings'),
  },
  'count.editor.valid.active.subscriptions': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who use subscriptions'),
  },
  'count.editor.valid.active.tags': {
    category: 'edit-information',
    color: '#ff00cc',
    label: lp('Editors who have added tags', 'folksonomy'),
  },
  'count.editor.valid.active.votes': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have voted on edits'),
  },
  'count.editor.valid.inactive': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have not been active at all'),
  },
  'count.editor.valid.validated_only': {
    category: 'edit-information',
    color: '#ff00cc',
    label: l('Editors who have only validated their email'),
  },
  'count.editor.votelastweek': {
    category: 'edit-information',
    color: '#cc00ff',
    label: l('Editors who voted in the last week'),
  },
  'count.event': {
    category: 'core-entities',
    color: '#e8ab08',
    label: l('Events'),
  },
  'count.event.country.null': {
    category: 'event-countries',
    color: '#ff0000',
    label: l('Events with no country set'),
  },
  'count.event.type.null': {
    category: 'event-types',
    color: '#ff0000',
    label: l('Events with no type set'),
  },
  'count.genre': {
    category: 'core-entities',
    color: '#ff0000',
    label: l('Genres'),
  },
  'count.instrument': {
    category: 'core-entities',
    color: '#8fddc9',
    label: l('Instruments'),
  },
  'count.instrument.type.null': {
    category: 'instrument-types',
    color: '#ff0000',
    label: l('Instruments with no type set'),
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
  'count.label.type.null': {
    category: 'label-types',
    color: '#ff0000',
    label: l('Labels with no type set'),
  },
  'count.mbid': {
    category: 'other',
    color: '#ff0000',
    label: l('MBIDs'),
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
    label: l('Mediums with disc IDs'),
  },
  'count.place': {
    category: 'core-entities',
    color: '#bc0a0a',
    label: l('Places'),
  },
  'count.place.country.null': {
    category: 'place-countries',
    color: '#ff0000',
    label: l('Places with no country set'),
  },
  'count.place.type.null': {
    category: 'place-types',
    color: '#ff0000',
    label: l('Places with no type set'),
  },
  'count.quality.release.default': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Default (Normal + Unknown) Data Quality'),
  },
  'count.quality.release.high': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('High data quality'),
  },
  'count.quality.release.low': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Low data quality'),
  },
  'count.quality.release.normal': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Normal data quality'),
  },
  'count.quality.release.unknown': {
    category: 'release-quality',
    color: '#ff0000',
    label: l('Unknown data quality'),
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
    label: l('Release groups with ratings'),
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
  'count.release.coverart.caa': {
    category: 'cover-art',
    color: '#dd0022',
    label: l('Releases with CAA cover art'),
  },
  'count.release.coverart.none': {
    category: 'cover-art',
    color: '#00dd22',
    label: l('Releases with no cover art'),
  },
  'count.release.format.null': {
    category: 'formats',
    color: '#ff0000',
    label: l('Releases with a medium with no format set'),
  },
  'count.release.format.null.has_coverart': {
    category: 'cover-art',
    color: '#ff0000',
    label: l('Releases with a medium with no format set that have cover art'),
  },
  'count.release.has_caa': {
    category: 'cover-art',
    color: '#22eedd',
    label: l('Releases with cover art'),
  },
  'count.release.has_discid': {
    category: 'other',
    color: '#ff0000',
    label: l('Releases with disc IDs'),
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
  'count.release.packaging.null': {
    category: 'release-packagings',
    color: '#ff0000',
    label: l('Releases with no packaging set'),
  },
  'count.release.script.null': {
    category: 'release-scripts',
    color: '#ff0000',
    label: l('Releases with no script set'),
  },
  'count.release.status.null': {
    category: 'release-statuses',
    color: '#ff0000',
    label: l('Releases with no status set'),
  },
  'count.release.status.null.has_coverart': {
    category: 'cover-art',
    color: '#ff0000',
    label: l('Releases with no status set that have cover art'),
  },
  'count.release.type.null.has_coverart': {
    category: 'cover-art',
    color: '#ff0000',
    label: l('Releases in groups with no type set that have cover art'),
  },
  'count.release.various': {
    category: 'other',
    color: '#ff0000',
    label: l('Releases credited to Various Artists'),
  },
  'count.releasegroup': {
    category: 'core-entities',
    color: '#ae00ff',
    label: l('Release groups'),
  },
  'count.releasegroup.caa.inferred': {
    category: 'cover-art',
    color: '#ff0000',
    label: l('Release groups with automatically inferred cover art'),
  },
  'count.releasegroup.caa.manually_selected': {
    category: 'cover-art',
    color: '#ff0000',
    label: l('Release groups with user-selected cover art'),
  },
  'count.releasegroup.primary_type.null': {
    category: 'release-group-types',
    color: '#ff0000',
    label: l('Release groups with no primary type set'),
  },
  'count.releasegroup.secondary_type.null': {
    category: 'release-group-types',
    color: '#ff0000',
    label: l('Release groups with no secondary type set'),
  },
  'count.series': {
    category: 'core-entities',
    color: '#1a6756',
    label: lp('Series', 'plural'),
  },
  'count.series.type.null': {
    category: 'series-types',
    color: '#ff0000',
    label: l('Series with no type set'),
  },
  'count.tag': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: lp('Unique tag names', 'folksonomy'),
  },
  'count.tag.raw': {
    category: 'ratings-tags',
    color: '#ff0000',
    label: lp('Votes for/against tags', 'folksonomy'),
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
  'count.url': {
    category: 'core-entities',
    color: '#1a6756',
    label: l('URLs'),
  },
  'count.video': {
    category: 'other',
    color: '#ff0000',
    label: l('Videos'),
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
  'count.vote.approve': {
    category: 'edit-information',
    color: '#00ffff',
    label: l('Approvals'),
  },
  'count.vote.no': {
    category: 'edit-information',
    color: '#00ffff',
    label: l('No votes'),
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
    label: l('Yes votes'),
  },
  'count.work': {
    category: 'core-entities',
    color: '#00ffa8',
    label: l('Works'),
  },
  'count.work.attribute.null': {
    category: 'work-attributes',
    color: '#ff0000',
    label: l('Works with no attributes'),
  },
  'count.work.has_iswc': {
    category: 'other',
    color: '#ff0000',
    label: l('Works with ISWCs'),
  },
  'count.work.language.null': {
    category: 'work-languages',
    color: '#ff0000',
    label: l('Works with no language set'),
  },
  'count.work.type.null': {
    category: 'work-types',
    color: '#ff0000',
    label: l('Works with no type set'),
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
    areaTypes,
    countries,
    editTypes,
    eventTypes,
    formats,
    instrumentTypes,
    labelTypes,
    languages,
    packagings,
    placeTypes,
    relationshipTables,
    relationshipTypes,
    releaseGroupTypes,
    releaseGroupSecondaryTypes,
    scripts,
    seriesTypes,
    statuses,
    workAttributes,
    workTypes,
  } = typeData;

  for (const key in areaTypes) {
    const type = areaTypes[key];
    const typeName = lp_attributes(type.name, 'area_type');

    stats[`count.area.type.${key}`] = {
      category: 'area-types',
      color: '#ff0000',
      label: texp.l('{type} areas', {type: typeName}),
    };
  }

  for (const key in countries) {
    const country = countries[key];
    const countryName = l_countries(country.name);
    const countryArg = {country: countryName};

    stats[`count.artist.country.${key}`] = {
      category: 'artist-countries',
      color: '#ff0000',
      label: texp.l('{country} artists', countryArg),
    };

    stats[`count.event.country.${key}`] = {
      category: 'event-countries',
      color: '#ff0000',
      label: texp.l('{country} events', countryArg),
    };

    stats[`count.label.country.${key}`] = {
      category: 'label-countries',
      color: '#ff0000',
      label: texp.l('{country} labels', countryArg),
    };

    stats[`count.place.country.${key}`] = {
      category: 'place-countries',
      color: '#ff0000',
      label: texp.l('{country} places', countryArg),
    };

    stats[`count.release.country.${key}`] = {
      category: 'release-countries',
      color: '#ff0000',
      label: texp.l('{country} releases', countryArg),
    };
  }

  for (const key in editTypes) {
    const type = editTypes[key];
    const typeName = l(type.name);

    stats[`count.edit.type.${key}`] = {
      category: 'edit-types',
      color: '#ff0000',
      label: texp.l('{type} edits', {type: typeName}),
    };
  }

  for (const key in eventTypes) {
    const type = eventTypes[key];
    const typeName = lp_attributes(type.name, 'event_type');

    stats[`count.event.type.${key}`] = {
      category: 'event-types',
      color: '#ff0000',
      label: texp.l('{type} events', {type: typeName}),
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

    stats[`count.release.format.${encodeURI(format.name)}.has_coverart`] = {
      category: 'cover-art',
      color: '#ff0000',
      label: texp.l(
        'Releases with a medium of format “{format}” that have cover art',
        {format: formatArg.name},
      ),
    };
  }

  for (const key in instrumentTypes) {
    const type = instrumentTypes[key];
    const typeName = lp_attributes(type.name, 'instrument_type');

    stats[`count.instrument.type.${key}`] = {
      category: 'instrument-types',
      color: '#ff0000',
      label: texp.l('{type} instruments', {type: typeName}),
    };
  }

  for (const key in labelTypes) {
    const type = labelTypes[key];
    const typeName = lp_attributes(type.name, 'label_type');

    stats[`count.label.type.${key}`] = {
      category: 'label-types',
      color: '#ff0000',
      label: texp.l('{type} labels', {type: typeName}),
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

    stats[`count.work.language.${key}`] = {
      category: 'work-languages',
      color: '#ff0000',
      label: texp.l('{language} works', {language: languageName}),
    };
  }

  for (const key in packagings) {
    const packaging = packagings[key];
    const packagingName = lp_attributes(packaging.name, 'release_packaging');

    stats[`count.release.packaging.${key}`] = {
      category: 'release-packagings',
      color: '#ff0000',
      label: texp.l(
        'Releases with packaging “{packaging}”',
        {packaging: packagingName},
      ),
    };
  }

  for (const key in placeTypes) {
    const type = placeTypes[key];
    const typeName = lp_attributes(type.name, 'place_type');

    stats[`count.place.type.${key}`] = {
      category: 'place-types',
      color: '#ff0000',
      label: texp.l('{type} places', {type: typeName}),
    };
  }

  for (let i = 0; i < relationshipTables.length; i++) {
    const pair = relationshipTables[i];
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

  for (const key in relationshipTypes) {
    const type = relationshipTypes[key];
    const typeName = l_relationships(type.name);

    const label = texp.l(
      `{first_entity_type_name}-{second_entity_type_name}
       “{relationship_type_name}” relationships`,
      {
        first_entity_type_name: formatEntityTypeName(type.entity0),
        relationship_type_name: typeName,
        second_entity_type_name: formatEntityTypeName(type.entity1),
      },
    );

    stats[`count.ar.links.${encodeURI(key)}`] = {
      category: 'relationships',
      color: `#ff0000`,
      label,
    };

    const labelInclusive = texp.l(
      `{first_entity_type_name}-{second_entity_type_name}
       “{relationship_type_name}” relationships
       including child relationship types`,
      {
        first_entity_type_name: formatEntityTypeName(type.entity0),
        relationship_type_name: typeName,
        second_entity_type_name: formatEntityTypeName(type.entity1),
      },
    );
    stats[`count.ar.links.${encodeURI(key)}.inclusive`] = {
      category: 'relationships',
      color: `#ff0000`,
      label: labelInclusive,
    };
  }

  for (const key in releaseGroupTypes) {
    const type = releaseGroupTypes[key];
    const typeName = lp_attributes(type.name, 'release_group_primary_type');

    stats[`count.releasegroup.primary_type.${key}`] = {
      category: 'release-group-types',
      color: '#ff0000',
      label: texp.l('{type} release groups', {type: typeName}),
    };

    stats[`count.release.type.${encodeURI(type.name)}.has_coverart`] = {
      category: 'cover-art',
      color: '#ff0000',
      label: texp.l(
        'Releases in groups of type “{type}” with cover art',
        {type: typeName},
      ),
    };
  }

  for (const key in releaseGroupSecondaryTypes) {
    const type = releaseGroupSecondaryTypes[key];
    const typeName = lp_attributes(type.name, 'release_group_secondary_type');

    stats[`count.releasegroup.secondary_type.${key}`] = {
      category: 'release-group-types',
      color: '#ff0000',
      label: texp.l('{type} release groups', {type: typeName}),
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

  for (const key in seriesTypes) {
    const type = seriesTypes[key];
    const typeName = lp_attributes(type.name, 'series_type');

    stats[`count.series.type.${key}`] = {
      category: 'series-types',
      color: '#ff0000',
      label: texp.l('{type} series', {type: typeName}),
    };
  }

  for (const key in statuses) {
    const status = statuses[key];
    const statusName = lp_attributes(status.name, 'release_status');

    stats[`count.release.status.${key}`] = {
      category: 'release-statuses',
      color: '#ff0000',
      label: texp.l('{status} releases', {status: statusName}),
    };

    stats[`count.release.status.${encodeURI(status.name)}.has_coverart`] = {
      category: 'cover-art',
      color: '#ff0000',
      label: texp.l(
        'Releases of status “{status}” with cover art',
        {status: statusName},
      ),
    };
  }

  for (const key in workAttributes) {
    const attribute = workAttributes[key];
    const attributeName = lp_attributes(
      attribute.name,
      'work_attribute_type',
    );

    stats[`count.work.attribute.${key}`] = {
      category: 'work-attributes',
      color: '#ff0000',
      label: texp.l(
        'Works with attribute “{attribute}”',
        {attribute: attributeName},
      ),
    };
  }

  for (const key in workTypes) {
    const type = workTypes[key];
    const typeName = lp_attributes(type.name, 'work_type');

    stats[`count.work.type.${key}`] = {
      category: 'work-types',
      color: '#ff0000',
      label: texp.l('{type} works', {type: typeName}),
    };
  }
}
