/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as EDIT_TYPES
  from '../../static/scripts/common/constants/editTypes.js';
import invariant from '../../utility/invariant.js';
import AddAnnotation from '../details/AddAnnotation.js';
import AddArea from '../details/AddArea.js';
import AddArtist from '../details/AddArtist.js';
import AddCoverArt from '../details/AddCoverArt.js';
import AddDiscId from '../details/AddDiscId.js';
import AddEvent from '../details/AddEvent.js';
import AddEventArt from '../details/AddEventArt.js';
import AddGenre from '../details/AddGenre.js';
import AddInstrument from '../details/AddInstrument.js';
import AddIsrcs from '../details/AddIsrcs.js';
import AddIswcs from '../details/AddIswcs.js';
import AddLabel from '../details/AddLabel.js';
import AddMedium from '../details/AddMedium.js';
import AddPlace from '../details/AddPlace.js';
import AddRelationship from '../details/AddRelationship.js';
import AddRelationshipAttribute from '../details/AddRelationshipAttribute.js';
import AddRelationshipType from '../details/AddRelationshipType.js';
import AddRelease from '../details/AddRelease.js';
import AddReleaseGroup from '../details/AddReleaseGroup.js';
import AddReleaseLabel from '../details/AddReleaseLabel.js';
import AddRemoveAlias from '../details/AddRemoveAlias.js';
import AddSeries from '../details/AddSeries.js';
import AddStandaloneRecording from '../details/AddStandaloneRecording.js';
import AddWork from '../details/AddWork.js';
import ChangeReleaseQuality from '../details/ChangeReleaseQuality.js';
import ChangeWikiDoc from '../details/ChangeWikiDoc.js';
import EditAlias from '../details/EditAlias.js';
import EditArea from '../details/EditArea.js';
import EditArtist from '../details/EditArtist.js';
import EditArtistCredit from '../details/EditArtistCredit.js';
import EditBarcodes from '../details/EditBarcodes.js';
import EditCoverArt from '../details/EditCoverArt.js';
import EditEvent from '../details/EditEvent.js';
import EditEventArt from '../details/EditEventArt.js';
import EditGenre from '../details/EditGenre.js';
import EditInstrument from '../details/EditInstrument.js';
import EditLabel from '../details/EditLabel.js';
import EditMedium from '../details/EditMedium.js';
import EditPlace from '../details/EditPlace.js';
import EditRecording from '../details/EditRecording.js';
import EditRelationship from '../details/EditRelationship.js';
import EditRelationshipAttribute
  from '../details/EditRelationshipAttribute.js';
import EditRelationshipType from '../details/EditRelationshipType.js';
import EditRelease from '../details/EditRelease.js';
import EditReleaseGroup from '../details/EditReleaseGroup.js';
import EditReleaseLabel from '../details/EditReleaseLabel.js';
import EditSeries from '../details/EditSeries.js';
import EditUrl from '../details/EditUrl.js';
import EditWork from '../details/EditWork.js';
import AddDiscIdHistoric from '../details/historic/AddDiscId.js';
import AddRelationshipHistoric from '../details/historic/AddRelationship.js';
import AddReleaseHistoric from '../details/historic/AddRelease.js';
import AddReleaseAnnotationHistoric
  from '../details/historic/AddReleaseAnnotation.js';
import AddTrackKV from '../details/historic/AddTrackKV.js';
import AddTrackOld from '../details/historic/AddTrackOld.js';
import ChangeArtistQuality from '../details/historic/ChangeArtistQuality.js';
import ChangeReleaseArtist from '../details/historic/ChangeReleaseArtist.js';
import ChangeReleaseGroup from '../details/historic/ChangeReleaseGroup.js';
import ChangeReleaseQualityHistoric
  from '../details/historic/ChangeReleaseQuality.js';
import EditRelationshipHistoric
  from '../details/historic/EditRelationship.js';
import EditReleaseAttributes
  from '../details/historic/EditReleaseAttributes.js';
import EditReleaseEvents from '../details/historic/EditReleaseEvents.js';
import EditReleaseLanguage from '../details/historic/EditReleaseLanguage.js';
import EditReleaseName from '../details/historic/EditReleaseName.js';
import EditTrack from '../details/historic/EditTrack.js';
import MergeReleasesHistoric from '../details/historic/MergeReleases.js';
import MoveDiscIdHistoric from '../details/historic/MoveDiscId.js';
import MoveReleaseHistoric from '../details/historic/MoveRelease.js';
import MoveReleaseToReleaseGroup
  from '../details/historic/MoveReleaseToReleaseGroup.js';
import RemoveDiscIdHistoric from '../details/historic/RemoveDiscId.js';
import RemoveLabelAlias from '../details/historic/RemoveLabelAlias.js';
import RemoveRelationshipHistoric
  from '../details/historic/RemoveRelationship.js';
import RemoveReleaseHistoric from '../details/historic/RemoveRelease.js';
import RemoveReleases from '../details/historic/RemoveReleases.js';
import RemoveTrack from '../details/historic/RemoveTrack.js';
import MergeAreas from '../details/MergeAreas.js';
import MergeArtists from '../details/MergeArtists.js';
import MergeEvents from '../details/MergeEvents.js';
import MergeInstruments from '../details/MergeInstruments.js';
import MergeLabels from '../details/MergeLabels.js';
import MergePlaces from '../details/MergePlaces.js';
import MergeRecordings from '../details/MergeRecordings.js';
import MergeReleaseGroups from '../details/MergeReleaseGroups.js';
import MergeReleases from '../details/MergeReleases.js';
import MergeSeries from '../details/MergeSeries.js';
import MergeWorks from '../details/MergeWorks.js';
import MoveDiscId from '../details/MoveDiscId.js';
import RemoveCoverArt from '../details/RemoveCoverArt.js';
import RemoveDiscId from '../details/RemoveDiscId.js';
import RemoveEntity from '../details/RemoveEntity.js';
import RemoveEventArt from '../details/RemoveEventArt.js';
import RemoveIsrc from '../details/RemoveIsrc.js';
import RemoveIswc from '../details/RemoveIswc.js';
import RemoveMedium from '../details/RemoveMedium.js';
import RemoveRelationship from '../details/RemoveRelationship.js';
import RemoveRelationshipAttribute
  from '../details/RemoveRelationshipAttribute.js';
import RemoveRelationshipType from '../details/RemoveRelationshipType.js';
import RemoveReleaseLabel from '../details/RemoveReleaseLabel.js';
import ReorderCoverArt from '../details/ReorderCoverArt.js';
import ReorderEventArt from '../details/ReorderEventArt.js';
import ReorderMediums from '../details/ReorderMediums.js';
import ReorderRelationships from '../details/ReorderRelationships.js';
import SetCoverArt from '../details/SetCoverArt.js';
import SetTrackLengths from '../details/SetTrackLengths.js';

const editDetailsElementMap: {
  /* eslint-disable ft-flow/no-weak-types */
  /* eslint-disable-next-line ft-flow/no-flow-suppressions-in-strict-files */
  // $FlowFixMe[unclear-type]
  +[edit_type: EditT['edit_type']]: component(edit: any),
  /* eslint-enable ft-flow/no-weak-types */
} = {
  [EDIT_TYPES.EDIT_AREA_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_ARTIST_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_EVENT_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_GENRE_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_INSTRUMENT_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_LABEL_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_PLACE_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_RECORDING_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_RELEASEGROUP_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_RELEASE_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_SERIES_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_WORK_ADD_ANNOTATION]: AddAnnotation,
  [EDIT_TYPES.EDIT_AREA_CREATE]: AddArea,
  [EDIT_TYPES.EDIT_ARTIST_CREATE]: AddArtist,
  [EDIT_TYPES.EDIT_RELEASE_ADD_COVER_ART]: AddCoverArt,
  [EDIT_TYPES.EDIT_EVENT_ADD_EVENT_ART]: AddEventArt,
  [EDIT_TYPES.EDIT_MEDIUM_ADD_DISCID]: AddDiscId,
  [EDIT_TYPES.EDIT_EVENT_CREATE]: AddEvent,
  [EDIT_TYPES.EDIT_GENRE_CREATE]: AddGenre,
  [EDIT_TYPES.EDIT_INSTRUMENT_CREATE]: AddInstrument,
  [EDIT_TYPES.EDIT_RECORDING_ADD_ISRCS]: AddIsrcs,
  [EDIT_TYPES.EDIT_WORK_ADD_ISWCS]: AddIswcs,
  [EDIT_TYPES.EDIT_LABEL_CREATE]: AddLabel,
  [EDIT_TYPES.EDIT_MEDIUM_CREATE]: AddMedium,
  [EDIT_TYPES.EDIT_PLACE_CREATE]: AddPlace,
  [EDIT_TYPES.EDIT_RELATIONSHIP_CREATE]: AddRelationship,
  [EDIT_TYPES.EDIT_RELATIONSHIP_ADD_ATTRIBUTE]: AddRelationshipAttribute,
  [EDIT_TYPES.EDIT_RELATIONSHIP_ADD_TYPE]: AddRelationshipType,
  [EDIT_TYPES.EDIT_RELEASE_CREATE]: AddRelease,
  [EDIT_TYPES.EDIT_RELEASEGROUP_CREATE]: AddReleaseGroup,
  [EDIT_TYPES.EDIT_RELEASE_ADDRELEASELABEL]: AddReleaseLabel,
  [EDIT_TYPES.EDIT_AREA_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_AREA_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_ARTIST_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_ARTIST_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_EVENT_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_EVENT_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_GENRE_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_GENRE_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_INSTRUMENT_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_INSTRUMENT_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_LABEL_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_LABEL_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_PLACE_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_PLACE_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_RECORDING_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_RECORDING_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_RELEASEGROUP_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_RELEASEGROUP_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_RELEASE_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_RELEASE_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_SERIES_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_SERIES_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_WORK_ADD_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_WORK_DELETE_ALIAS]: AddRemoveAlias,
  [EDIT_TYPES.EDIT_SERIES_CREATE]: AddSeries,
  [EDIT_TYPES.EDIT_RECORDING_CREATE]: AddStandaloneRecording,
  [EDIT_TYPES.EDIT_WORK_CREATE]: AddWork,
  [EDIT_TYPES.EDIT_RELEASE_CHANGE_QUALITY]: ChangeReleaseQuality,
  [EDIT_TYPES.EDIT_WIKIDOC_CHANGE]: ChangeWikiDoc,
  [EDIT_TYPES.EDIT_AREA_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_ARTIST_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_EVENT_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_GENRE_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_INSTRUMENT_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_LABEL_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_PLACE_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_RECORDING_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_RELEASEGROUP_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_RELEASE_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_SERIES_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_WORK_EDIT_ALIAS]: EditAlias,
  [EDIT_TYPES.EDIT_AREA_EDIT]: EditArea,
  [EDIT_TYPES.EDIT_ARTIST_EDIT]: EditArtist,
  [EDIT_TYPES.EDIT_ARTIST_EDITCREDIT]: EditArtistCredit,
  [EDIT_TYPES.EDIT_RELEASE_EDIT_BARCODES]: EditBarcodes,
  [EDIT_TYPES.EDIT_RELEASE_EDIT_COVER_ART]: EditCoverArt,
  [EDIT_TYPES.EDIT_EVENT_EDIT_EVENT_ART]: EditEventArt,
  [EDIT_TYPES.EDIT_EVENT_EDIT]: EditEvent,
  [EDIT_TYPES.EDIT_GENRE_EDIT]: EditGenre,
  [EDIT_TYPES.EDIT_INSTRUMENT_EDIT]: EditInstrument,
  [EDIT_TYPES.EDIT_LABEL_EDIT]: EditLabel,
  [EDIT_TYPES.EDIT_MEDIUM_EDIT]: EditMedium,
  [EDIT_TYPES.EDIT_PLACE_EDIT]: EditPlace,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACK_LENGTH]: EditRecording,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACKNAME]: EditRecording,
  [EDIT_TYPES.EDIT_RECORDING_EDIT]: EditRecording,
  [EDIT_TYPES.EDIT_RELATIONSHIP_EDIT]: EditRelationship,
  [EDIT_TYPES.EDIT_RELATIONSHIP_ATTRIBUTE]: EditRelationshipAttribute,
  [EDIT_TYPES.EDIT_RELATIONSHIP_EDIT_LINK_TYPE]: EditRelationshipType,
  [EDIT_TYPES.EDIT_RELEASE_ARTIST]: EditRelease,
  [EDIT_TYPES.EDIT_RELEASE_EDIT]: EditRelease,
  [EDIT_TYPES.EDIT_RELEASEGROUP_EDIT]: EditReleaseGroup,
  [EDIT_TYPES.EDIT_RELEASE_EDITRELEASELABEL]: EditReleaseLabel,
  [EDIT_TYPES.EDIT_SERIES_EDIT]: EditSeries,
  [EDIT_TYPES.EDIT_URL_EDIT]: EditUrl,
  [EDIT_TYPES.EDIT_WORK_EDIT]: EditWork,
  [EDIT_TYPES.EDIT_AREA_MERGE]: MergeAreas,
  [EDIT_TYPES.EDIT_ARTIST_MERGE]: MergeArtists,
  [EDIT_TYPES.EDIT_EVENT_MERGE]: MergeEvents,
  [EDIT_TYPES.EDIT_INSTRUMENT_MERGE]: MergeInstruments,
  [EDIT_TYPES.EDIT_LABEL_MERGE]: MergeLabels,
  [EDIT_TYPES.EDIT_PLACE_MERGE]: MergePlaces,
  [EDIT_TYPES.EDIT_RECORDING_MERGE]: MergeRecordings,
  [EDIT_TYPES.EDIT_RELEASEGROUP_MERGE]: MergeReleaseGroups,
  [EDIT_TYPES.EDIT_RELEASE_MERGE]: MergeReleases,
  [EDIT_TYPES.EDIT_SERIES_MERGE]: MergeSeries,
  [EDIT_TYPES.EDIT_WORK_MERGE]: MergeWorks,
  [EDIT_TYPES.EDIT_MEDIUM_MOVE_DISCID]: MoveDiscId,
  [EDIT_TYPES.EDIT_RELEASE_REMOVE_COVER_ART]: RemoveCoverArt,
  [EDIT_TYPES.EDIT_EVENT_REMOVE_EVENT_ART]: RemoveEventArt,
  [EDIT_TYPES.EDIT_MEDIUM_REMOVE_DISCID]: RemoveDiscId,
  [EDIT_TYPES.EDIT_AREA_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_ARTIST_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_EVENT_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_GENRE_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_INSTRUMENT_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_LABEL_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_PLACE_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_RECORDING_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_RELEASEGROUP_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_RELEASE_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_SERIES_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_WORK_DELETE]: RemoveEntity,
  [EDIT_TYPES.EDIT_RECORDING_REMOVE_ISRC]: RemoveIsrc,
  [EDIT_TYPES.EDIT_WORK_REMOVE_ISWC]: RemoveIswc,
  [EDIT_TYPES.EDIT_MEDIUM_DELETE]: RemoveMedium,
  [EDIT_TYPES.EDIT_RELATIONSHIP_DELETE]: RemoveRelationship,
  [EDIT_TYPES.EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE]:
    RemoveRelationshipAttribute,
  [EDIT_TYPES.EDIT_RELATIONSHIP_REMOVE_LINK_TYPE]: RemoveRelationshipType,
  [EDIT_TYPES.EDIT_RELEASE_DELETERELEASELABEL]: RemoveReleaseLabel,
  [EDIT_TYPES.EDIT_RELEASE_REORDER_COVER_ART]: ReorderCoverArt,
  [EDIT_TYPES.EDIT_EVENT_REORDER_EVENT_ART]: ReorderEventArt,
  [EDIT_TYPES.EDIT_RELEASE_REORDER_MEDIUMS]: ReorderMediums,
  [EDIT_TYPES.EDIT_RELATIONSHIPS_REORDER]: ReorderRelationships,
  [EDIT_TYPES.EDIT_RELEASEGROUP_SET_COVER_ART]: SetCoverArt,
  [EDIT_TYPES.EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC]: SetTrackLengths,
  [EDIT_TYPES.EDIT_SET_TRACK_LENGTHS]: SetTrackLengths,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_DISCID]: AddDiscIdHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_LINK]: AddRelationshipHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE]: AddReleaseHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE_ANNOTATION]:
    AddReleaseAnnotationHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_TRACK_KV]: AddTrackKV,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_TRACK]: AddTrackOld,
  [EDIT_TYPES.EDIT_HISTORIC_CHANGE_ARTIST_QUALITY]: ChangeArtistQuality,
  [EDIT_TYPES.EDIT_HISTORIC_MAC_TO_SAC]: ChangeReleaseArtist,
  [EDIT_TYPES.EDIT_HISTORIC_SAC_TO_MAC]: ChangeReleaseArtist,
  [EDIT_TYPES.EDIT_HISTORIC_CHANGE_RELEASE_GROUP]: ChangeReleaseGroup,
  [EDIT_TYPES.EDIT_HISTORIC_CHANGE_RELEASE_QUALITY]:
    ChangeReleaseQualityHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_LINK]: EditRelationshipHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_ATTRS]: EditReleaseAttributes,
  [EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE_EVENTS]: EditReleaseEvents,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_EVENTS]: EditReleaseEvents,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD]: EditReleaseEvents,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASE_EVENTS]: EditReleaseEvents,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE]: EditReleaseLanguage,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_NAME]: EditReleaseName,
  [EDIT_TYPES.EDIT_HISTORIC_CHANGE_TRACK_ARTIST]: EditTrack,
  [EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACKNUM]: EditTrack,
  [EDIT_TYPES.EDIT_HISTORIC_MERGE_RELEASE]: MergeReleasesHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_MERGE_RELEASE_MAC]: MergeReleasesHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_MOVE_DISCID]: MoveDiscIdHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_MOVE_RELEASE]: MoveReleaseHistoric,
  [EDIT_TYPES.EDIT_RELEASE_MOVE]: MoveReleaseToReleaseGroup,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_DISCID]: RemoveDiscIdHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_LABEL_ALIAS]: RemoveLabelAlias,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_LINK]: RemoveRelationshipHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASE]: RemoveReleaseHistoric,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASES]: RemoveReleases,
  [EDIT_TYPES.EDIT_HISTORIC_REMOVE_TRACK]: RemoveTrack,
};

export default function getEditDetailsElement(
  edit: EditT,
): React.MixedElement {
  const EditDetailsElement = editDetailsElementMap[edit.edit_type];
  invariant(
    EditDetailsElement != null,
    `No component found for edit type ${edit.edit_type}`,
  );
  return <EditDetailsElement edit={edit} />;
}
