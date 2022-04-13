/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as EDIT_TYPES from '../../static/scripts/common/constants/editTypes';
import AddAnnotation from '../details/AddAnnotation';
import AddArea from '../details/AddArea';
import AddArtist from '../details/AddArtist';
import AddCoverArt from '../details/AddCoverArt';
import AddDiscId from '../details/AddDiscId';
import AddEvent from '../details/AddEvent';
import AddInstrument from '../details/AddInstrument';
import AddIsrcs from '../details/AddIsrcs';
import AddIswcs from '../details/AddIswcs';
import AddLabel from '../details/AddLabel';
import AddMedium from '../details/AddMedium';
import AddPlace from '../details/AddPlace';
import AddRelationship from '../details/AddRelationship';
import AddRelationshipAttribute from '../details/AddRelationshipAttribute';
import AddRelationshipType from '../details/AddRelationshipType';
import AddRelease from '../details/AddRelease';
import AddReleaseGroup from '../details/AddReleaseGroup';
import AddReleaseLabel from '../details/AddReleaseLabel';
import AddRemoveAlias from '../details/AddRemoveAlias';
import AddSeries from '../details/AddSeries';
import AddStandaloneRecording from '../details/AddStandaloneRecording';
import AddWork from '../details/AddWork';
import ChangeReleaseQuality from '../details/ChangeReleaseQuality';
import ChangeWikiDoc from '../details/ChangeWikiDoc';
import EditAlias from '../details/EditAlias';
import EditArea from '../details/EditArea';
import EditArtist from '../details/EditArtist';
import EditArtistCredit from '../details/EditArtistCredit';
import EditBarcodes from '../details/EditBarcodes';
import EditCoverArt from '../details/EditCoverArt';
import EditEvent from '../details/EditEvent';
import EditInstrument from '../details/EditInstrument';
import EditLabel from '../details/EditLabel';
import EditMedium from '../details/EditMedium';
import EditPlace from '../details/EditPlace';
import EditRecording from '../details/EditRecording';
import EditRelationship from '../details/EditRelationship';
import EditRelationshipAttribute from '../details/EditRelationshipAttribute';
import EditRelationshipType from '../details/EditRelationshipType';
import EditRelease from '../details/EditRelease';
import EditReleaseGroup from '../details/EditReleaseGroup';
import EditReleaseLabel from '../details/EditReleaseLabel';
import EditSeries from '../details/EditSeries';
import EditUrl from '../details/EditUrl';
import EditWork from '../details/EditWork';
import MergeAreas from '../details/MergeAreas';
import MergeArtists from '../details/MergeArtists';
import MergeEvents from '../details/MergeEvents';
import MergeInstruments from '../details/MergeInstruments';
import MergeLabels from '../details/MergeLabels';
import MergePlaces from '../details/MergePlaces';
import MergeRecordings from '../details/MergeRecordings';
import MergeReleaseGroups from '../details/MergeReleaseGroups';
import MergeReleases from '../details/MergeReleases';
import MergeSeries from '../details/MergeSeries';
import MergeWorks from '../details/MergeWorks';
import MoveDiscId from '../details/MoveDiscId';
import RemoveCoverArt from '../details/RemoveCoverArt';
import RemoveDiscId from '../details/RemoveDiscId';
import RemoveEntity from '../details/RemoveEntity';
import RemoveIsrc from '../details/RemoveIsrc';
import RemoveIswc from '../details/RemoveIswc';
import RemoveMedium from '../details/RemoveMedium';
import RemoveRelationship from '../details/RemoveRelationship';
import RemoveRelationshipAttribute
  from '../details/RemoveRelationshipAttribute';
import RemoveRelationshipType from '../details/RemoveRelationshipType';
import RemoveReleaseLabel from '../details/RemoveReleaseLabel';
import ReorderCoverArt from '../details/ReorderCoverArt';
import ReorderMediums from '../details/ReorderMediums';
import ReorderRelationships from '../details/ReorderRelationships';
import SetCoverArt from '../details/SetCoverArt';
import SetTrackLengths from '../details/SetTrackLengths';
import AddDiscIdHistoric from '../details/historic/AddDiscId';
import AddRelationshipHistoric from '../details/historic/AddRelationship';
import AddReleaseHistoric from '../details/historic/AddRelease';
import AddReleaseAnnotationHistoric
  from '../details/historic/AddReleaseAnnotation';
import AddTrackKV from '../details/historic/AddTrackKV';
import AddTrackOld from '../details/historic/AddTrackOld';
import ChangeArtistQuality from '../details/historic/ChangeArtistQuality';
import ChangeReleaseArtist from '../details/historic/ChangeReleaseArtist';
import ChangeReleaseGroup from '../details/historic/ChangeReleaseGroup';
import ChangeReleaseQualityHistoric
  from '../details/historic/ChangeReleaseQuality';
import EditRelationshipHistoric from '../details/historic/EditRelationship';
import EditReleaseAttributes from '../details/historic/EditReleaseAttributes';
import EditReleaseEvents from '../details/historic/EditReleaseEvents';
import EditReleaseLanguage from '../details/historic/EditReleaseLanguage';
import EditReleaseName from '../details/historic/EditReleaseName';
import EditTrack from '../details/historic/EditTrack';
import MergeReleasesHistoric from '../details/historic/MergeReleases';
import MoveDiscIdHistoric from '../details/historic/MoveDiscId';
import MoveReleaseHistoric from '../details/historic/MoveRelease';
import MoveReleaseToReleaseGroup
  from '../details/historic/MoveReleaseToReleaseGroup';
import RemoveDiscIdHistoric from '../details/historic/RemoveDiscId';
import RemoveLabelAlias from '../details/historic/RemoveLabelAlias';
import RemoveRelationshipHistoric
  from '../details/historic/RemoveRelationship';
import RemoveReleaseHistoric from '../details/historic/RemoveRelease';
import RemoveReleases from '../details/historic/RemoveReleases';
import RemoveTrack from '../details/historic/RemoveTrack';

export default function getEditDetailsElement(
  edit: EditT,
): React$MixedElement {
  switch (edit.edit_type) {
    case EDIT_TYPES.EDIT_AREA_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_ARTIST_ADD_ANNOTATION:
    case EDIT_TYPES.EDIT_EVENT_ADD_ANNOTATION:
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
