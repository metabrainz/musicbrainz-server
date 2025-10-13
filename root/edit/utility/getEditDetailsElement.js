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

export default function getEditDetailsElement(
  edit: EditT,
): React.MixedElement {
  return match (edit) {
    {
      edit_type:
        | EDIT_TYPES.EDIT_AREA_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_ARTIST_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_EVENT_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_GENRE_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_INSTRUMENT_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_LABEL_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_PLACE_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_RECORDING_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_RELEASEGROUP_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_RELEASE_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_SERIES_ADD_ANNOTATION
        | EDIT_TYPES.EDIT_WORK_ADD_ANNOTATION,
      ...
    } as edit =>
      <AddAnnotation edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_AREA_CREATE, ...} as edit =>
      <AddArea edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_ARTIST_CREATE, ...} as edit =>
      <AddArtist edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_ADD_COVER_ART, ...} as edit =>
      <AddCoverArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_ADD_EVENT_ART, ...} as edit =>
      <AddEventArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_MEDIUM_ADD_DISCID, ...} as edit =>
      <AddDiscId edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_CREATE, ...} as edit =>
      <AddEvent edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_GENRE_CREATE, ...} as edit =>
      <AddGenre edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_INSTRUMENT_CREATE, ...} as edit =>
      <AddInstrument edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RECORDING_ADD_ISRCS, ...} as edit =>
      <AddIsrcs edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_WORK_ADD_ISWCS, ...} as edit =>
      <AddIswcs edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_LABEL_CREATE, ...} as edit =>
      <AddLabel edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_MEDIUM_CREATE, ...} as edit =>
      <AddMedium edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_PLACE_CREATE, ...} as edit =>
      <AddPlace edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_CREATE, ...} as edit =>
      <AddRelationship edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_ADD_ATTRIBUTE, ...} as edit =>
      <AddRelationshipAttribute edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_ADD_TYPE, ...} as edit =>
      <AddRelationshipType edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_CREATE, ...} as edit =>
      <AddRelease edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASEGROUP_CREATE, ...} as edit =>
      <AddReleaseGroup edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_ADDRELEASELABEL, ...} as edit =>
      <AddReleaseLabel edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_AREA_ADD_ALIAS
        | EDIT_TYPES.EDIT_AREA_DELETE_ALIAS
        | EDIT_TYPES.EDIT_ARTIST_ADD_ALIAS
        | EDIT_TYPES.EDIT_ARTIST_DELETE_ALIAS
        | EDIT_TYPES.EDIT_EVENT_ADD_ALIAS
        | EDIT_TYPES.EDIT_EVENT_DELETE_ALIAS
        | EDIT_TYPES.EDIT_GENRE_ADD_ALIAS
        | EDIT_TYPES.EDIT_GENRE_DELETE_ALIAS
        | EDIT_TYPES.EDIT_INSTRUMENT_ADD_ALIAS
        | EDIT_TYPES.EDIT_INSTRUMENT_DELETE_ALIAS
        | EDIT_TYPES.EDIT_LABEL_ADD_ALIAS
        | EDIT_TYPES.EDIT_LABEL_DELETE_ALIAS
        | EDIT_TYPES.EDIT_PLACE_ADD_ALIAS
        | EDIT_TYPES.EDIT_PLACE_DELETE_ALIAS
        | EDIT_TYPES.EDIT_RECORDING_ADD_ALIAS
        | EDIT_TYPES.EDIT_RECORDING_DELETE_ALIAS
        | EDIT_TYPES.EDIT_RELEASEGROUP_ADD_ALIAS
        | EDIT_TYPES.EDIT_RELEASEGROUP_DELETE_ALIAS
        | EDIT_TYPES.EDIT_RELEASE_ADD_ALIAS
        | EDIT_TYPES.EDIT_RELEASE_DELETE_ALIAS
        | EDIT_TYPES.EDIT_SERIES_ADD_ALIAS
        | EDIT_TYPES.EDIT_SERIES_DELETE_ALIAS
        | EDIT_TYPES.EDIT_WORK_ADD_ALIAS
        | EDIT_TYPES.EDIT_WORK_DELETE_ALIAS,
      ...
    } as edit =>
      <AddRemoveAlias edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_SERIES_CREATE, ...} as edit =>
      <AddSeries edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RECORDING_CREATE, ...} as edit =>
      <AddStandaloneRecording edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_WORK_CREATE, ...} as edit =>
      <AddWork edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_CHANGE_QUALITY, ...} as edit =>
      <ChangeReleaseQuality edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_WIKIDOC_CHANGE, ...} as edit =>
      <ChangeWikiDoc edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_AREA_EDIT_ALIAS
        | EDIT_TYPES.EDIT_ARTIST_EDIT_ALIAS
        | EDIT_TYPES.EDIT_EVENT_EDIT_ALIAS
        | EDIT_TYPES.EDIT_GENRE_EDIT_ALIAS
        | EDIT_TYPES.EDIT_INSTRUMENT_EDIT_ALIAS
        | EDIT_TYPES.EDIT_LABEL_EDIT_ALIAS
        | EDIT_TYPES.EDIT_PLACE_EDIT_ALIAS
        | EDIT_TYPES.EDIT_RECORDING_EDIT_ALIAS
        | EDIT_TYPES.EDIT_RELEASEGROUP_EDIT_ALIAS
        | EDIT_TYPES.EDIT_RELEASE_EDIT_ALIAS
        | EDIT_TYPES.EDIT_SERIES_EDIT_ALIAS
        | EDIT_TYPES.EDIT_WORK_EDIT_ALIAS,
      ...
    } as edit =>
      <EditAlias edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_AREA_EDIT, ...} as edit =>
      <EditArea edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_ARTIST_EDIT, ...} as edit =>
      <EditArtist edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_ARTIST_EDITCREDIT, ...} as edit =>
      <EditArtistCredit edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_EDIT_BARCODES, ...} as edit =>
      <EditBarcodes edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_EDIT_COVER_ART, ...} as edit =>
      <EditCoverArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_EDIT_EVENT_ART, ...} as edit =>
      <EditEventArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_EDIT, ...} as edit =>
      <EditEvent edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_GENRE_EDIT, ...} as edit =>
      <EditGenre edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_INSTRUMENT_EDIT, ...} as edit =>
      <EditInstrument edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_LABEL_EDIT, ...} as edit =>
      <EditLabel edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_MEDIUM_EDIT, ...} as edit =>
      <EditMedium edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_PLACE_EDIT, ...} as edit =>
      <EditPlace edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACK_LENGTH
        | EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACKNAME
        | EDIT_TYPES.EDIT_RECORDING_EDIT,
      ...
    } as edit =>
      <EditRecording edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_EDIT, ...} as edit =>
      <EditRelationship edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_ATTRIBUTE, ...} as edit =>
      <EditRelationshipAttribute edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_EDIT_LINK_TYPE, ...} as edit =>
      <EditRelationshipType edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_RELEASE_ARTIST
        | EDIT_TYPES.EDIT_RELEASE_EDIT,
      ...
    } as edit =>
      <EditRelease edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASEGROUP_EDIT, ...} as edit =>
      <EditReleaseGroup edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_EDITRELEASELABEL, ...} as edit =>
      <EditReleaseLabel edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_SERIES_EDIT, ...} as edit =>
      <EditSeries edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_URL_EDIT, ...} as edit =>
      <EditUrl edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_WORK_EDIT, ...} as edit =>
      <EditWork edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_AREA_MERGE, ...} as edit =>
      <MergeAreas edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_ARTIST_MERGE, ...} as edit =>
      <MergeArtists edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_MERGE, ...} as edit =>
      <MergeEvents edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_INSTRUMENT_MERGE, ...} as edit =>
      <MergeInstruments edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_LABEL_MERGE, ...} as edit =>
      <MergeLabels edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_PLACE_MERGE, ...} as edit =>
      <MergePlaces edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RECORDING_MERGE, ...} as edit =>
      <MergeRecordings edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASEGROUP_MERGE, ...} as edit =>
      <MergeReleaseGroups edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_MERGE, ...} as edit =>
      <MergeReleases edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_SERIES_MERGE, ...} as edit =>
      <MergeSeries edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_WORK_MERGE, ...} as edit =>
      <MergeWorks edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_MEDIUM_MOVE_DISCID, ...} as edit =>
      <MoveDiscId edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_REMOVE_COVER_ART, ...} as edit =>
      <RemoveCoverArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_REMOVE_EVENT_ART, ...} as edit =>
      <RemoveEventArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_MEDIUM_REMOVE_DISCID, ...} as edit =>
      <RemoveDiscId edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_AREA_DELETE
        | EDIT_TYPES.EDIT_ARTIST_DELETE
        | EDIT_TYPES.EDIT_EVENT_DELETE
        | EDIT_TYPES.EDIT_GENRE_DELETE
        | EDIT_TYPES.EDIT_INSTRUMENT_DELETE
        | EDIT_TYPES.EDIT_LABEL_DELETE
        | EDIT_TYPES.EDIT_PLACE_DELETE
        | EDIT_TYPES.EDIT_RECORDING_DELETE
        | EDIT_TYPES.EDIT_RELEASEGROUP_DELETE
        | EDIT_TYPES.EDIT_RELEASE_DELETE
        | EDIT_TYPES.EDIT_SERIES_DELETE
        | EDIT_TYPES.EDIT_WORK_DELETE,
      ...
    } as edit =>
      <RemoveEntity edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RECORDING_REMOVE_ISRC, ...} as edit =>
      <RemoveIsrc edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_WORK_REMOVE_ISWC, ...} as edit =>
      <RemoveIswc edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_MEDIUM_DELETE, ...} as edit =>
      <RemoveMedium edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_DELETE, ...} as edit =>
      <RemoveRelationship edit={edit} />,
    {
      edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE,
      ...
    } as edit =>
      <RemoveRelationshipAttribute edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIP_REMOVE_LINK_TYPE, ...} as edit =>
      <RemoveRelationshipType edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_DELETERELEASELABEL, ...} as edit =>
      <RemoveReleaseLabel edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_REORDER_COVER_ART, ...} as edit =>
      <ReorderCoverArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_EVENT_REORDER_EVENT_ART, ...} as edit =>
      <ReorderEventArt edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_REORDER_MEDIUMS, ...} as edit =>
      <ReorderMediums edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELATIONSHIPS_REORDER, ...} as edit =>
      <ReorderRelationships edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASEGROUP_SET_COVER_ART, ...} as edit =>
      <SetCoverArt edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC
        | EDIT_TYPES.EDIT_SET_TRACK_LENGTHS,
      ...
    } as edit =>
      <SetTrackLengths edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_ADD_DISCID, ...} as edit =>
      <AddDiscIdHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_ADD_LINK, ...} as edit =>
      <AddRelationshipHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE, ...} as edit =>
      <AddReleaseHistoric edit={edit} />,
    {
      edit_type: EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE_ANNOTATION,
      ...
    } as edit =>
      <AddReleaseAnnotationHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_ADD_TRACK_KV, ...} as edit =>
      <AddTrackKV edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_ADD_TRACK, ...} as edit =>
      <AddTrackOld edit={edit} />,
    {
      edit_type: EDIT_TYPES.EDIT_HISTORIC_CHANGE_ARTIST_QUALITY,
      ...
    } as edit =>
      <ChangeArtistQuality edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_HISTORIC_MAC_TO_SAC
        | EDIT_TYPES.EDIT_HISTORIC_SAC_TO_MAC,
      ...
    } as edit =>
      <ChangeReleaseArtist edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_CHANGE_RELEASE_GROUP, ...} as edit =>
      <ChangeReleaseGroup edit={edit} />,
    {
      edit_type: EDIT_TYPES.EDIT_HISTORIC_CHANGE_RELEASE_QUALITY,
      ...
    } as edit =>
      <ChangeReleaseQualityHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_EDIT_LINK, ...} as edit =>
      <EditRelationshipHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_ATTRS, ...} as edit =>
      <EditReleaseAttributes edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE_EVENTS
        | EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_EVENTS
        | EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD
        | EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASE_EVENTS,
      ...
    } as edit =>
      <EditReleaseEvents edit={edit} />,
    {
      edit_type: EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE,
      ...
    } as edit =>
      <EditReleaseLanguage edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_NAME, ...} as edit =>
      <EditReleaseName edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_HISTORIC_CHANGE_TRACK_ARTIST
        | EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACKNUM,
      ...
    } as edit =>
      <EditTrack edit={edit} />,
    {
      edit_type:
        | EDIT_TYPES.EDIT_HISTORIC_MERGE_RELEASE
        | EDIT_TYPES.EDIT_HISTORIC_MERGE_RELEASE_MAC,
      ...
    } as edit =>
      <MergeReleasesHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_MOVE_DISCID, ...} as edit =>
      <MoveDiscIdHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_MOVE_RELEASE, ...} as edit =>
      <MoveReleaseHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_RELEASE_MOVE, ...} as edit =>
      <MoveReleaseToReleaseGroup edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_REMOVE_DISCID, ...} as edit =>
      <RemoveDiscIdHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_REMOVE_LABEL_ALIAS, ...} as edit =>
      <RemoveLabelAlias edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_REMOVE_LINK, ...} as edit =>
      <RemoveRelationshipHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASE, ...} as edit =>
      <RemoveReleaseHistoric edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASES, ...} as edit =>
      <RemoveReleases edit={edit} />,
    {edit_type: EDIT_TYPES.EDIT_HISTORIC_REMOVE_TRACK, ...} as edit =>
      <RemoveTrack edit={edit} />,
  };
}
