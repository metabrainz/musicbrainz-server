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
import RemoveIsrc from '../details/RemoveIsrc.js';
import RemoveIswc from '../details/RemoveIswc.js';
import RemoveMedium from '../details/RemoveMedium.js';
import RemoveRelationship from '../details/RemoveRelationship.js';
import RemoveRelationshipAttribute
  from '../details/RemoveRelationshipAttribute.js';
import RemoveRelationshipType from '../details/RemoveRelationshipType.js';
import RemoveReleaseLabel from '../details/RemoveReleaseLabel.js';
import ReorderCoverArt from '../details/ReorderCoverArt.js';
import ReorderMediums from '../details/ReorderMediums.js';
import ReorderRelationships from '../details/ReorderRelationships.js';
import SetCoverArt from '../details/SetCoverArt.js';
import SetTrackLengths from '../details/SetTrackLengths.js';

export default function getEditDetailsElement(
  edit: EditT,
): React$MixedElement {
  switch (edit.edit_type) {
    case EDIT_TYPES.EDIT_AREA_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_ARTIST_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_EVENT_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_GENRE_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_INSTRUMENT_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_LABEL_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_PLACE_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_RECORDING_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_RELEASEGROUP_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_RELEASE_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_SERIES_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_WORK_ADD_ANNOTATION:
      return <AddAnnotation edit={edit} />;
    case EDIT_TYPES.EDIT_AREA_CREATE:
      return <AddArea edit={edit} />;
    case EDIT_TYPES.EDIT_ARTIST_CREATE:
      return <AddArtist edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_ADD_COVER_ART:
      return <AddCoverArt edit={edit} />;
    case EDIT_TYPES.EDIT_MEDIUM_ADD_DISCID:
      return <AddDiscId edit={edit} />;
    case EDIT_TYPES.EDIT_EVENT_CREATE:
      return <AddEvent edit={edit} />;
    case EDIT_TYPES.EDIT_GENRE_CREATE:
      return <AddGenre edit={edit} />;
    case EDIT_TYPES.EDIT_INSTRUMENT_CREATE:
      return <AddInstrument edit={edit} />;
    case EDIT_TYPES.EDIT_RECORDING_ADD_ISRCS:
      return <AddIsrcs edit={edit} />;
    case EDIT_TYPES.EDIT_WORK_ADD_ISWCS:
      return <AddIswcs edit={edit} />;
    case EDIT_TYPES.EDIT_LABEL_CREATE:
      return <AddLabel edit={edit} />;
    case EDIT_TYPES.EDIT_MEDIUM_CREATE:
      return <AddMedium edit={edit} />;
    case EDIT_TYPES.EDIT_PLACE_CREATE:
      return <AddPlace edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_CREATE:
      return <AddRelationship edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_ADD_ATTRIBUTE:
      return <AddRelationshipAttribute edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_ADD_TYPE:
      return <AddRelationshipType edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_CREATE:
      return <AddRelease edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASEGROUP_CREATE:
      return <AddReleaseGroup edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_ADDRELEASELABEL:
      return <AddReleaseLabel edit={edit} />;
    case EDIT_TYPES.EDIT_AREA_ADD_ALIAS:
    case EDIT_TYPES.EDIT_AREA_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_ARTIST_ADD_ALIAS:
    case EDIT_TYPES.EDIT_ARTIST_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_EVENT_ADD_ALIAS:
    case EDIT_TYPES.EDIT_EVENT_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_GENRE_ADD_ALIAS:
    case EDIT_TYPES.EDIT_GENRE_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_INSTRUMENT_ADD_ALIAS:
    case EDIT_TYPES.EDIT_INSTRUMENT_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_LABEL_ADD_ALIAS:
    case EDIT_TYPES.EDIT_LABEL_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_PLACE_ADD_ALIAS:
    case EDIT_TYPES.EDIT_PLACE_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_RECORDING_ADD_ALIAS:
    case EDIT_TYPES.EDIT_RECORDING_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_RELEASEGROUP_ADD_ALIAS:
    case EDIT_TYPES.EDIT_RELEASEGROUP_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_RELEASE_ADD_ALIAS:
    case EDIT_TYPES.EDIT_RELEASE_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_SERIES_ADD_ALIAS:
    case EDIT_TYPES.EDIT_SERIES_DELETE_ALIAS:
    case EDIT_TYPES.EDIT_WORK_ADD_ALIAS:
    case EDIT_TYPES.EDIT_WORK_DELETE_ALIAS:
      return <AddRemoveAlias edit={edit} />;
    case EDIT_TYPES.EDIT_SERIES_CREATE:
      return <AddSeries edit={edit} />;
    case EDIT_TYPES.EDIT_RECORDING_CREATE:
      return <AddStandaloneRecording edit={edit} />;
    case EDIT_TYPES.EDIT_WORK_CREATE:
      return <AddWork edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_CHANGE_QUALITY:
      return <ChangeReleaseQuality edit={edit} />;
    case EDIT_TYPES.EDIT_WIKIDOC_CHANGE:
      return <ChangeWikiDoc edit={edit} />;
    case EDIT_TYPES.EDIT_AREA_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_ARTIST_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_EVENT_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_GENRE_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_INSTRUMENT_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_LABEL_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_PLACE_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_RECORDING_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_RELEASEGROUP_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_RELEASE_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_SERIES_EDIT_ALIAS:
    case EDIT_TYPES.EDIT_WORK_EDIT_ALIAS:
      return <EditAlias edit={edit} />;
    case EDIT_TYPES.EDIT_AREA_EDIT:
      return <EditArea edit={edit} />;
    case EDIT_TYPES.EDIT_ARTIST_EDIT:
      return <EditArtist edit={edit} />;
    case EDIT_TYPES.EDIT_ARTIST_EDITCREDIT:
      return <EditArtistCredit edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_EDIT_BARCODES:
      return <EditBarcodes edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_EDIT_COVER_ART:
      return <EditCoverArt edit={edit} />;
    case EDIT_TYPES.EDIT_EVENT_EDIT:
      return <EditEvent edit={edit} />;
    case EDIT_TYPES.EDIT_GENRE_EDIT:
      return <EditGenre edit={edit} />;
    case EDIT_TYPES.EDIT_INSTRUMENT_EDIT:
      return <EditInstrument edit={edit} />;
    case EDIT_TYPES.EDIT_LABEL_EDIT:
      return <EditLabel edit={edit} />;
    case EDIT_TYPES.EDIT_MEDIUM_EDIT:
      return <EditMedium edit={edit} />;
    case EDIT_TYPES.EDIT_PLACE_EDIT:
      return <EditPlace edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACK_LENGTH:
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACKNAME:
    case EDIT_TYPES.EDIT_RECORDING_EDIT:
      return <EditRecording edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_EDIT:
      return <EditRelationship edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_ATTRIBUTE:
      return <EditRelationshipAttribute edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_EDIT_LINK_TYPE:
      return <EditRelationshipType edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_ARTIST:
    case EDIT_TYPES.EDIT_RELEASE_EDIT:
      return <EditRelease edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASEGROUP_EDIT:
      return <EditReleaseGroup edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_EDITRELEASELABEL:
      return <EditReleaseLabel edit={edit} />;
    case EDIT_TYPES.EDIT_SERIES_EDIT:
      return <EditSeries edit={edit} />;
    case EDIT_TYPES.EDIT_URL_EDIT:
      return <EditUrl edit={edit} />;
    case EDIT_TYPES.EDIT_WORK_EDIT:
      return <EditWork edit={edit} />;
    case EDIT_TYPES.EDIT_AREA_MERGE:
      return <MergeAreas edit={edit} />;
    case EDIT_TYPES.EDIT_ARTIST_MERGE:
      return <MergeArtists edit={edit} />;
    case EDIT_TYPES.EDIT_EVENT_MERGE:
      return <MergeEvents edit={edit} />;
    case EDIT_TYPES.EDIT_INSTRUMENT_MERGE:
      return <MergeInstruments edit={edit} />;
    case EDIT_TYPES.EDIT_LABEL_MERGE:
      return <MergeLabels edit={edit} />;
    case EDIT_TYPES.EDIT_PLACE_MERGE:
      return <MergePlaces edit={edit} />;
    case EDIT_TYPES.EDIT_RECORDING_MERGE:
      return <MergeRecordings edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASEGROUP_MERGE:
      return <MergeReleaseGroups edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_MERGE:
      return <MergeReleases edit={edit} />;
    case EDIT_TYPES.EDIT_SERIES_MERGE:
      return <MergeSeries edit={edit} />;
    case EDIT_TYPES.EDIT_WORK_MERGE:
      return <MergeWorks edit={edit} />;
    case EDIT_TYPES.EDIT_MEDIUM_MOVE_DISCID:
      return <MoveDiscId edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_REMOVE_COVER_ART:
      return <RemoveCoverArt edit={edit} />;
    case EDIT_TYPES.EDIT_MEDIUM_REMOVE_DISCID:
      return <RemoveDiscId edit={edit} />;
    case EDIT_TYPES.EDIT_AREA_DELETE:
    case EDIT_TYPES.EDIT_ARTIST_DELETE:
    case EDIT_TYPES.EDIT_EVENT_DELETE:
    case EDIT_TYPES.EDIT_GENRE_DELETE:
    case EDIT_TYPES.EDIT_INSTRUMENT_DELETE:
    case EDIT_TYPES.EDIT_LABEL_DELETE:
    case EDIT_TYPES.EDIT_PLACE_DELETE:
    case EDIT_TYPES.EDIT_RECORDING_DELETE:
    case EDIT_TYPES.EDIT_RELEASEGROUP_DELETE:
    case EDIT_TYPES.EDIT_RELEASE_DELETE:
    case EDIT_TYPES.EDIT_SERIES_DELETE:
    case EDIT_TYPES.EDIT_WORK_DELETE:
      return <RemoveEntity edit={edit} />;
    case EDIT_TYPES.EDIT_RECORDING_REMOVE_ISRC:
      return <RemoveIsrc edit={edit} />;
    case EDIT_TYPES.EDIT_WORK_REMOVE_ISWC:
      return <RemoveIswc edit={edit} />;
    case EDIT_TYPES.EDIT_MEDIUM_DELETE:
      return <RemoveMedium edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_DELETE:
      return <RemoveRelationship edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE:
      return <RemoveRelationshipAttribute edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIP_REMOVE_LINK_TYPE:
      return <RemoveRelationshipType edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_DELETERELEASELABEL:
      return <RemoveReleaseLabel edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_REORDER_COVER_ART:
      return <ReorderCoverArt edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_REORDER_MEDIUMS:
      return <ReorderMediums edit={edit} />;
    case EDIT_TYPES.EDIT_RELATIONSHIPS_REORDER:
      return <ReorderRelationships edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASEGROUP_SET_COVER_ART:
      return <SetCoverArt edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC:
    case EDIT_TYPES.EDIT_SET_TRACK_LENGTHS:
      return <SetTrackLengths edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_DISCID:
      return <AddDiscIdHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_LINK:
      return <AddRelationshipHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE:
      return <AddReleaseHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE_ANNOTATION:
      return <AddReleaseAnnotationHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_TRACK_KV:
      return <AddTrackKV edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_TRACK:
      return <AddTrackOld edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_CHANGE_ARTIST_QUALITY:
      return <ChangeArtistQuality edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_MAC_TO_SAC:
    case EDIT_TYPES.EDIT_HISTORIC_SAC_TO_MAC:
      return <ChangeReleaseArtist edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_CHANGE_RELEASE_GROUP:
      return <ChangeReleaseGroup edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_CHANGE_RELEASE_QUALITY:
      return <ChangeReleaseQualityHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_LINK:
      return <EditRelationshipHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_ATTRS:
      return <EditReleaseAttributes edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_ADD_RELEASE_EVENTS:
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_EVENTS:
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD:
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASE_EVENTS:
      return <EditReleaseEvents edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE:
      return <EditReleaseLanguage edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_RELEASE_NAME:
      return <EditReleaseName edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_CHANGE_TRACK_ARTIST:
    case EDIT_TYPES.EDIT_HISTORIC_EDIT_TRACKNUM:
      return <EditTrack edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_MERGE_RELEASE:
    case EDIT_TYPES.EDIT_HISTORIC_MERGE_RELEASE_MAC:
      return <MergeReleasesHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_MOVE_DISCID:
      return <MoveDiscIdHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_MOVE_RELEASE:
      return <MoveReleaseHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_RELEASE_MOVE:
      return <MoveReleaseToReleaseGroup edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_DISCID:
      return <RemoveDiscIdHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_LABEL_ALIAS:
      return <RemoveLabelAlias edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_LINK:
      return <RemoveRelationshipHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASE:
      return <RemoveReleaseHistoric edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_RELEASES:
      return <RemoveReleases edit={edit} />;
    case EDIT_TYPES.EDIT_HISTORIC_REMOVE_TRACK:
      return <RemoveTrack edit={edit} />;
    default:
      /*:: exhaustive(edit); */
      throw new Error('Invalid edit type.');
  }
}
