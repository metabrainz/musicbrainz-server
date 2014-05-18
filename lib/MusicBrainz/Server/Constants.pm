package MusicBrainz::Server::Constants;

use strict;
use warnings;

use base 'Exporter';

use Readonly;
use DateTime::Duration;

sub _get
{
    my $re = shift;
    return [
        map { "\$$_" }
        grep { $_ =~ $re }
        keys %MusicBrainz::Server::Constants::
    ];
}

our %EXPORT_TAGS = (
    edit_type       => _get(qr/^EDIT_/),
    expire_action   => _get(qr/^EXPIRE_/),
    quality         => _get(qr/^QUALITY_/),
    alias           => _get(qr/^EDIT_.*_ALIAS/),
    annotation      => _get(qr/^EDIT_.*_ADD_ANNOTATION/),
    historic        => _get(qr/^EDIT_HISTORIC/),
    editor          => _get(qr/^EDITOR_/),
    vote            => _get(qr/^VOTE_/),
    edit_status     => _get(qr/^STATUS_/),
    access_scope    => _get(qr/^ACCESS_SCOPE_/),
    privileges      => [
        qw( $AUTO_EDITOR_FLAG         $BOT_FLAG           $UNTRUSTED_FLAG
            $RELATIONSHIP_EDITOR_FLAG $DONT_NAG_FLAG      $WIKI_TRANSCLUSION_FLAG
            $MBID_SUBMITTER_FLAG      $ACCOUNT_ADMIN_FLAG $LOCATION_EDITOR_FLAG )
    ],
    election_status => [
        qw( $ELECTION_SECONDER_1 $ELECTION_SECONDER_2 $ELECTION_OPEN
            $ELECTION_ACCEPTED   $ELECTION_REJECTED   $ELECTION_CANCELLED )
    ],
    election_vote => [
        qw( $ELECTION_VOTE_YES $ELECTION_VOTE_NO $ELECTION_VOTE_ABSTAIN )
    ],
    vote => [
        qw( $VOTE_NO $VOTE_ABSTAIN $VOTE_YES $VOTE_APPROVE )
    ],
    email_addresses => [
        qw( $EMAIL_NOREPLY_ADDRESS $EMAIL_SUPPORT_ADDRESS )
    ],
);

our @EXPORT_OK = (
    qw( $DLABEL_ID $DARTIST_ID $VARTIST_ID $VARTIST_GID
        $AUTO_EDITOR_FLAG         $BOT_FLAG            $UNTRUSTED_FLAG
        $RELATIONSHIP_EDITOR_FLAG $DONT_NAG_FLAG       $WIKI_TRANSCLUSION_FLAG
        $MBID_SUBMITTER_FLAG      $ACCOUNT_ADMIN_FLAG  $LOCATION_EDITOR_FLAG
        $COVERART_FRONT_TYPE      $COVERART_BACK_TYPE  $INSTRUMENT_ROOT_ID
        $AREA_TYPE_COUNTRY        $REQUIRED_VOTES      %PART_OF_SERIES
        $ARTIST_ARTIST_COLLABORATION @FULL_TABLE_LIST  %ENTITIES
        entities_with $VOCAL_ROOT_ID
    ),
    @{ _get(qr/^(EDIT|EXPIRE|QUALITY|EDITOR|ELECTION|EMAIL|VOTE|STATUS|ACCESS_SCOPE|SERIES)_/) },
);

Readonly our $DLABEL_ID => 1;
Readonly our $DARTIST_ID => 2;

Readonly our $VARTIST_GID => '89ad4ac3-39f7-470e-963a-56509c546377';
Readonly our $VARTIST_ID  => 1;

Readonly our $EXPIRE_ACCEPT => 1;
Readonly our $EXPIRE_REJECT => 2;

Readonly our $EDITOR_ANONYMOUS => 1;
Readonly our $EDITOR_FREEDB => 2;
Readonly our $EDITOR_MODBOT => 4;

Readonly our $QUALITY_UNKNOWN        => -1;
Readonly our $QUALITY_UNKNOWN_MAPPED => 1;
Readonly our $QUALITY_LOW            => 0;
Readonly our $QUALITY_NORMAL         => 1;
Readonly our $QUALITY_HIGH           => 2;

Readonly our $EDIT_ARTIST_CREATE => 1;
Readonly our $EDIT_ARTIST_EDIT => 2;
Readonly our $EDIT_ARTIST_DELETE => 3;
Readonly our $EDIT_ARTIST_MERGE => 4;
Readonly our $EDIT_ARTIST_ADD_ANNOTATION => 5;
Readonly our $EDIT_ARTIST_ADD_ALIAS => 6;
Readonly our $EDIT_ARTIST_DELETE_ALIAS => 7;
Readonly our $EDIT_ARTIST_EDIT_ALIAS => 8;
Readonly our $EDIT_ARTIST_EDITCREDIT => 9;

Readonly our $EDIT_LABEL_CREATE => 10;
Readonly our $EDIT_LABEL_EDIT => 11;
Readonly our $EDIT_LABEL_DELETE => 13;
Readonly our $EDIT_LABEL_MERGE => 14;
Readonly our $EDIT_LABEL_ADD_ANNOTATION => 15;
Readonly our $EDIT_LABEL_ADD_ALIAS => 16;
Readonly our $EDIT_LABEL_DELETE_ALIAS => 17;
Readonly our $EDIT_LABEL_EDIT_ALIAS => 18;

Readonly our $EDIT_RELEASEGROUP_CREATE => 20;
Readonly our $EDIT_RELEASEGROUP_EDIT => 21;
Readonly our $EDIT_RELEASEGROUP_SET_COVER_ART => 22;
Readonly our $EDIT_RELEASEGROUP_DELETE => 23;
Readonly our $EDIT_RELEASEGROUP_MERGE => 24;
Readonly our $EDIT_RELEASEGROUP_ADD_ANNOTATION => 25;

Readonly our $EDIT_RELEASE_CREATE => 31;
Readonly our $EDIT_RELEASE_EDIT => 32;
Readonly our $EDIT_RELEASE_MOVE => 33;
Readonly our $EDIT_RELEASE_ADDRELEASELABEL => 34;
Readonly our $EDIT_RELEASE_ADD_ANNOTATION => 35;
Readonly our $EDIT_RELEASE_DELETERELEASELABEL => 36;
Readonly our $EDIT_RELEASE_EDITRELEASELABEL => 37;
Readonly our $EDIT_RELEASE_CHANGE_QUALITY => 38;
Readonly our $EDIT_RELEASE_EDIT_BARCODES => 39;
Readonly our $EDIT_RELEASE_DELETE => 310;
Readonly our $EDIT_RELEASE_MERGE => 311;
Readonly our $EDIT_RELEASE_ARTIST => 312;
Readonly our $EDIT_RELEASE_REORDER_MEDIUMS => 313;
Readonly our $EDIT_RELEASE_ADD_COVER_ART => 314;
Readonly our $EDIT_RELEASE_REMOVE_COVER_ART => 315;
Readonly our $EDIT_RELEASE_EDIT_COVER_ART => 316;
Readonly our $EDIT_RELEASE_REORDER_COVER_ART => 317;

Readonly our $EDIT_WORK_CREATE => 41;
Readonly our $EDIT_WORK_EDIT => 42;
Readonly our $EDIT_WORK_DELETE => 43;
Readonly our $EDIT_WORK_MERGE => 44;
Readonly our $EDIT_WORK_ADD_ANNOTATION => 45;
Readonly our $EDIT_WORK_ADD_ALIAS => 46;
Readonly our $EDIT_WORK_DELETE_ALIAS => 47;
Readonly our $EDIT_WORK_EDIT_ALIAS => 48;
Readonly our $EDIT_WORK_ADD_ISWCS => 49;
Readonly our $EDIT_WORK_REMOVE_ISWC => 410;

Readonly our $EDIT_MEDIUM_CREATE => 51;
Readonly our $EDIT_MEDIUM_EDIT => 52;
Readonly our $EDIT_MEDIUM_DELETE => 53;
Readonly our $EDIT_MEDIUM_REMOVE_DISCID => 54;
Readonly our $EDIT_MEDIUM_ADD_DISCID => 55;
Readonly our $EDIT_MEDIUM_MOVE_DISCID => 56;
Readonly our $EDIT_SET_TRACK_LENGTHS => 58;

Readonly our $EDIT_PLACE_CREATE => 61;
Readonly our $EDIT_PLACE_EDIT => 62;
Readonly our $EDIT_PLACE_DELETE => 63;
Readonly our $EDIT_PLACE_MERGE => 64;
Readonly our $EDIT_PLACE_ADD_ANNOTATION => 65;
Readonly our $EDIT_PLACE_ADD_ALIAS => 66;
Readonly our $EDIT_PLACE_DELETE_ALIAS => 67;
Readonly our $EDIT_PLACE_EDIT_ALIAS => 68;

Readonly our $EDIT_RECORDING_CREATE => 71;
Readonly our $EDIT_RECORDING_EDIT => 72;
Readonly our $EDIT_RECORDING_DELETE => 73;
Readonly our $EDIT_RECORDING_MERGE => 74;
Readonly our $EDIT_RECORDING_ADD_ANNOTATION => 75;
Readonly our $EDIT_RECORDING_ADD_ISRCS => 76;
Readonly our $EDIT_RECORDING_ADD_PUIDS => 77;
Readonly our $EDIT_RECORDING_REMOVE_ISRC => 78;

Readonly our $EDIT_AREA_CREATE => 81;
Readonly our $EDIT_AREA_EDIT => 82;
Readonly our $EDIT_AREA_DELETE => 83;
Readonly our $EDIT_AREA_MERGE => 84;
Readonly our $EDIT_AREA_ADD_ANNOTATION => 85;
Readonly our $EDIT_AREA_ADD_ALIAS => 86;
Readonly our $EDIT_AREA_DELETE_ALIAS => 87;
Readonly our $EDIT_AREA_EDIT_ALIAS => 88;

Readonly our $EDIT_RELATIONSHIP_CREATE => 90;
Readonly our $EDIT_RELATIONSHIP_EDIT => 91;
Readonly our $EDIT_RELATIONSHIP_DELETE => 92;
Readonly our $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE => 93;
Readonly our $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE => 94;
Readonly our $EDIT_RELATIONSHIP_EDIT_LINK_TYPE => 95;
Readonly our $EDIT_RELATIONSHIP_ADD_TYPE => 96;
Readonly our $EDIT_RELATIONSHIP_ATTRIBUTE => 97;
Readonly our $EDIT_RELATIONSHIP_ADD_ATTRIBUTE => 98;
Readonly our $EDIT_RELATIONSHIPS_REORDER => 99;

Readonly our $EDIT_SERIES_CREATE => 140;
Readonly our $EDIT_SERIES_EDIT => 141;
Readonly our $EDIT_SERIES_DELETE => 142;
Readonly our $EDIT_SERIES_MERGE => 143;
Readonly our $EDIT_SERIES_ADD_ANNOTATION => 144;
Readonly our $EDIT_SERIES_ADD_ALIAS => 145;
Readonly our $EDIT_SERIES_DELETE_ALIAS => 146;
Readonly our $EDIT_SERIES_EDIT_ALIAS => 147;

Readonly our $EDIT_INSTRUMENT_CREATE => 131;
Readonly our $EDIT_INSTRUMENT_EDIT => 132;
Readonly our $EDIT_INSTRUMENT_DELETE => 133;
Readonly our $EDIT_INSTRUMENT_MERGE => 134;
Readonly our $EDIT_INSTRUMENT_ADD_ANNOTATION => 135;
Readonly our $EDIT_INSTRUMENT_ADD_ALIAS => 136;
Readonly our $EDIT_INSTRUMENT_DELETE_ALIAS => 137;
Readonly our $EDIT_INSTRUMENT_EDIT_ALIAS => 138;

Readonly our $EDIT_WIKIDOC_CHANGE => 120;

Readonly our $EDIT_URL_EDIT => 101;

Readonly our $EDIT_PUID_DELETE => 113;

Readonly our $EDIT_HISTORIC_EDIT_RELEASE_NAME       => 201;
Readonly our $EDIT_HISTORIC_EDIT_TRACKNAME          => 204;
Readonly our $EDIT_HISTORIC_EDIT_TRACKNUM           => 205;
Readonly our $EDIT_HISTORIC_ADD_TRACK               => 207;
Readonly our $EDIT_HISTORIC_MOVE_RELEASE            => 208;
Readonly our $EDIT_HISTORIC_SAC_TO_MAC              => 209;
Readonly our $EDIT_HISTORIC_CHANGE_TRACK_ARTIST     => 210;
Readonly our $EDIT_HISTORIC_REMOVE_TRACK            => 211;
Readonly our $EDIT_HISTORIC_REMOVE_RELEASE          => 212;
Readonly our $EDIT_HISTORIC_MAC_TO_SAC              => 213;
Readonly our $EDIT_HISTORIC_ADD_RELEASE             => 216;
Readonly our $EDIT_HISTORIC_ADD_TRACK_KV            => 218;
Readonly our $EDIT_HISTORIC_REMOVE_DISCID           => 220;
Readonly our $EDIT_HISTORIC_MOVE_DISCID             => 221;
Readonly our $EDIT_HISTORIC_MERGE_RELEASE           => 223;
Readonly our $EDIT_HISTORIC_REMOVE_RELEASES         => 224;
Readonly our $EDIT_HISTORIC_MERGE_RELEASE_MAC       => 225;
Readonly our $EDIT_HISTORIC_EDIT_RELEASE_ATTRS      => 226;
Readonly our $EDIT_HISTORIC_EDIT_RELEASE_EVENTS_OLD => 229;
Readonly our $EDIT_HISTORIC_ADD_RELEASE_ANNOTATION  => 231;
Readonly our $EDIT_HISTORIC_ADD_DISCID              => 232;
Readonly our $EDIT_HISTORIC_ADD_LINK                => 233;
Readonly our $EDIT_HISTORIC_EDIT_LINK               => 234;
Readonly our $EDIT_HISTORIC_REMOVE_LINK             => 235;
Readonly our $EDIT_HISTORIC_EDIT_LINK_TYPE          => 237;
Readonly our $EDIT_HISTORIC_REMOVE_LINK_TYPE        => 238;
Readonly our $EDIT_HISTORIC_REMOVE_LINK_ATTR        => 243;
Readonly our $EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE   => 244;
Readonly our $EDIT_HISTORIC_EDIT_TRACK_LENGTH       => 245;
Readonly our $EDIT_HISTORIC_REMOVE_PUID             => 246;
Readonly our $EDIT_HISTORIC_ADD_RELEASE_EVENTS      => 249;
Readonly our $EDIT_HISTORIC_EDIT_RELEASE_EVENTS     => 250;
Readonly our $EDIT_HISTORIC_REMOVE_RELEASE_EVENTS   => 251;
Readonly our $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY   => 252;
Readonly our $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC => 253;
Readonly our $EDIT_HISTORIC_REMOVE_LABEL_ALIAS      => 262;
Readonly our $EDIT_HISTORIC_CHANGE_RELEASE_QUALITY  => 263;
Readonly our $EDIT_HISTORIC_CHANGE_RELEASE_GROUP    => 273;

Readonly our $ELECTION_SECONDER_1 => 1;
Readonly our $ELECTION_SECONDER_2 => 2;
Readonly our $ELECTION_OPEN       => 3;
Readonly our $ELECTION_ACCEPTED   => 4;
Readonly our $ELECTION_REJECTED   => 5;
Readonly our $ELECTION_CANCELLED  => 6;

Readonly our $EMAIL_NOREPLY_ADDRESS => 'MusicBrainz Server <noreply@musicbrainz.org>';
Readonly our $EMAIL_SUPPORT_ADDRESS => 'MusicBrainz <support@musicbrainz.org>';

Readonly our $VOTE_ABSTAIN => -1;
Readonly our $VOTE_NO      =>  0;
Readonly our $VOTE_YES     =>  1;
Readonly our $VOTE_APPROVE =>  2;

Readonly our $STATUS_OPEN         => 1;
Readonly our $STATUS_APPLIED      => 2;
Readonly our $STATUS_FAILEDVOTE   => 3;
Readonly our $STATUS_FAILEDDEP    => 4;
Readonly our $STATUS_ERROR        => 5;
Readonly our $STATUS_FAILEDPREREQ => 6;
Readonly our $STATUS_NOVOTES      => 7;
Readonly our $STATUS_TOBEDELETED  => 8;
Readonly our $STATUS_DELETED      => 9;

Readonly our $AUTO_EDITOR_FLAG         => 1;
Readonly our $BOT_FLAG                 => 2;
Readonly our $UNTRUSTED_FLAG           => 4;
Readonly our $RELATIONSHIP_EDITOR_FLAG => 8;
Readonly our $DONT_NAG_FLAG            => 16;
Readonly our $WIKI_TRANSCLUSION_FLAG   => 32;
Readonly our $MBID_SUBMITTER_FLAG      => 64;
Readonly our $ACCOUNT_ADMIN_FLAG       => 128;
Readonly our $LOCATION_EDITOR_FLAG     => 256;

Readonly our $ELECTION_VOTE_NO      => -1;
Readonly our $ELECTION_VOTE_ABSTAIN => 0;
Readonly our $ELECTION_VOTE_YES     => 1;

Readonly our $COVERART_FRONT_TYPE   => 1;
Readonly our $COVERART_BACK_TYPE   => 2;

Readonly our $INSTRUMENT_ROOT_ID => 14;
Readonly our $VOCAL_ROOT_ID => 3;

Readonly our $AREA_TYPE_COUNTRY => 1;

Readonly our $REQUIRED_VOTES => 3;
Readonly our $EDIT_MINIMUM_RESPONSE_PERIOD => DateTime::Duration->new(hours => 72);

Readonly our $ACCESS_SCOPE_PROFILE        => 1;
Readonly our $ACCESS_SCOPE_EMAIL          => 2;
Readonly our $ACCESS_SCOPE_TAG            => 4;
Readonly our $ACCESS_SCOPE_RATING         => 8;
Readonly our $ACCESS_SCOPE_COLLECTION     => 16;
Readonly our $ACCESS_SCOPE_SUBMIT_ISRC    => 64;
Readonly our $ACCESS_SCOPE_SUBMIT_BARCODE => 128;

Readonly our $ARTIST_ARTIST_COLLABORATION => '75c09861-6857-4ec0-9729-84eefde7fc86';

Readonly our $SERIES_ORDERING_TYPE_AUTOMATIC => 1;
Readonly our $SERIES_ORDERING_TYPE_MANUAL => 2;

Readonly our %PART_OF_SERIES => (
    recording       => 'ea6f0698-6782-30d6-b16d-293081b66774',
    release         => '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d',
    release_group   => '01018437-91d8-36b9-bf89-3f885d53b5bd',
    work            => 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
);

Readonly our $SERIES_ORDERING_ATTRIBUTE => 'a59c5830-5ec7-38fe-9a21-c7ea54f6650a';

Readonly our %ENTITIES => (
    area => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Area',
        annotations => { edit_type => $EDIT_AREA_ADD_ANNOTATION }
    },
    artist => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Artist',
        annotations => { edit_type => $EDIT_ARTIST_ADD_ANNOTATION },
        ratings    => 1,
        tags       => 1,
        subscriptions => { entity => 1, deleted => 1 }
    },
    instrument => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Instrument',
        annotations => { edit_type => $EDIT_INSTRUMENT_ADD_ANNOTATION }
    },
    label => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Label',
        annotations => { edit_type => $EDIT_LABEL_ADD_ANNOTATION },
        ratings    => 1,
        tags       => 1,
        subscriptions => { entity => 1, deleted => 1 }
    },
    place => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Place',
        annotations => { edit_type => $EDIT_PLACE_ADD_ANNOTATION },
        tags       => 1,
    },
    recording => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Recording',
        annotations => { edit_type => $EDIT_RECORDING_ADD_ANNOTATION },
        ratings    => 1,
        tags       => 1,
        artist_credits => 1
    },
    release => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Release',
        annotations => { edit_type => $EDIT_RELEASE_ADD_ANNOTATION },
        tags       => 1,
        artist_credits => 1
    },
    release_group => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'ReleaseGroup',
        url        => 'release-group',
        annotations => { edit_type => $EDIT_RELEASEGROUP_ADD_ANNOTATION },
        ratings    => 1,
        tags       => 1,
        artist_credits => 1
    },
    series => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Series',
        annotations => { edit_type => $EDIT_SERIES_ADD_ANNOTATION },
        subscriptions => { entity => 1, deleted => 1 }
    },
    url => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model => 'URL',
    },
    work => {
        mbid => { relatable => 1 },
        edit_table => 1,
        model      => 'Work',
        annotations => { edit_type => $EDIT_WORK_ADD_ANNOTATION },
        ratings    => 1,
        tags       => 1,
    },
    track => {
        mbid => { relatable => 0 },
        model      => 'Track',
        artist_credits => 1
    },
    editor => {
        model      => 'Editor',
        subscriptions => { entity => 0 }
    },
    collection => {
        mbid => { relatable => 0 },
        model      => 'Collection',
        subscriptions => { entity => 1 }
    },
    cdstub => {
        model => 'CDStub',
    },
    annotation => {
        model => 'Annotation'
    },
    isrc => {
        model => 'ISRC'
    },
    iswc => {
        model => 'ISWC'
    },
    freedb => {
        model => 'FreeDB'
    }
);

sub entities_with {
    my ($props, %opts) = @_;
    if (ref($props) ne 'ARRAY') {
        $props = [[$props]];
    }
    if (ref($props->[0]) ne 'ARRAY') {
        $props = [$props];
    }
    my $extract_path = sub {
        my ($entity, $path) = @_;
        my $final = $entity;
        for my $prop (@$path) {
            if (exists $final->{$prop}) {
                $final = $final->{$prop};
            } else {
                return;
            }
        }
        return $final;
    };

    my @entity_types;
    ENTITY: for my $entity_type (keys %ENTITIES) {
        for my $prop (@$props) {
            $extract_path->($ENTITIES{$entity_type}, $prop) or next ENTITY;
        }
        push @entity_types, $entity_type;
    }

    if (my $take = $opts{take}) {
        if (ref($take) eq 'CODE') {
            return map { $take->($_, $ENTITIES{$_}) } @entity_types;
        }

        if (ref($take) ne 'ARRAY') {
            $take = [$take];
        }
        return map { $extract_path->($ENTITIES{$_}, $take) } @entity_types;
    } else {
        return @entity_types;
    }
}

Readonly our @FULL_TABLE_LIST => qw(
    artist_rating_raw
    artist_tag_raw
    cdtoc_raw
    edit
    edit_area
    edit_artist
    edit_instrument
    edit_label
    edit_note
    edit_place
    edit_recording
    edit_release
    edit_release_group
    edit_series
    edit_url
    edit_work
    label_rating_raw
    label_tag_raw
    place_tag_raw
    recording_rating_raw
    recording_tag_raw
    release_group_rating_raw
    release_group_tag_raw
    release_tag_raw
    release_raw
    series
    series_alias
    series_alias_type
    series_annotation
    series_gid_redirect
    series_ordering_type
    series_type
    track_raw
    vote
    work_rating_raw
    work_tag_raw
    annotation
    application
    area
    area_type
    area_alias
    area_alias_type
    area_annotation
    area_gid_redirect
    country_area
    iso_3166_1
    iso_3166_2
    iso_3166_3
    artist
    artist_alias
    artist_alias_type
    artist_annotation
    artist_credit
    artist_credit_name
    artist_gid_redirect
    artist_ipi
    artist_isni
    artist_meta
    artist_tag
    artist_type
    autoeditor_election
    autoeditor_election_vote
    cdtoc
    editor
    editor_oauth_token
    editor_preference
    editor_language
    editor_sanitised
    editor_subscribe_artist
    editor_subscribe_collection
    editor_subscribe_editor
    editor_subscribe_label
    editor_subscribe_series
    editor_watch_artist
    editor_watch_preferences
    editor_watch_release_group_type
    editor_watch_release_status
    gender
    instrument
    instrument_alias
    instrument_alias_type
    instrument_annotation
    instrument_gid_redirect
    instrument_type
    isrc
    iswc
    l_area_area
    l_area_artist
    l_area_instrument
    l_area_label
    l_area_place
    l_area_recording
    l_area_release
    l_area_release_group
    l_area_series
    l_area_url
    l_area_work
    l_artist_artist
    l_artist_instrument
    l_artist_label
    l_artist_place
    l_artist_recording
    l_artist_release
    l_artist_release_group
    l_artist_series
    l_artist_url
    l_artist_work
    l_instrument_instrument
    l_instrument_label
    l_instrument_place
    l_instrument_recording
    l_instrument_release
    l_instrument_release_group
    l_instrument_series
    l_instrument_url
    l_instrument_work
    l_label_label
    l_label_place
    l_label_recording
    l_label_release
    l_label_release_group
    l_label_series
    l_label_url
    l_label_work
    l_place_place
    l_place_recording
    l_place_release
    l_place_release_group
    l_place_series
    l_place_url
    l_place_work
    l_recording_recording
    l_recording_release
    l_recording_release_group
    l_recording_series
    l_recording_url
    l_recording_work
    l_release_group_release_group
    l_release_group_series
    l_release_group_url
    l_release_group_work
    l_release_release
    l_release_release_group
    l_release_series
    l_release_url
    l_release_work
    l_series_series
    l_series_url
    l_series_work
    l_url_url
    l_url_work
    l_work_work
    label
    label_alias
    label_alias_type
    label_annotation
    label_gid_redirect
    label_ipi
    label_isni
    label_meta
    label_tag
    label_type
    language
    link
    link_attribute
    link_attribute_credit
    link_attribute_text_value
    link_attribute_type
    link_creditable_attribute_type
    link_text_attribute_type
    link_type
    link_type_attribute_type
    editor_collection
    editor_collection_release
    medium
    medium_cdtoc
    medium_format
    orderable_link_type
    place
    place_alias
    place_alias_type
    place_annotation
    place_gid_redirect
    place_tag
    place_type
    recording
    recording_annotation
    recording_gid_redirect
    recording_meta
    recording_tag
    release
    release_annotation
    release_country
    release_gid_redirect
    release_group
    release_group_annotation
    release_group_gid_redirect
    release_group_meta
    release_group_tag
    release_group_primary_type
    release_group_secondary_type
    release_group_secondary_type_join
    release_label
    release_meta
    release_coverart
    release_packaging
    release_status
    release_tag
    release_unknown_country
    replication_control
    script
    tag
    tag_relation
    track
    track_gid_redirect
    medium_index
    url
    url_gid_redirect
    work
    work_alias
    work_alias_type
    work_annotation
    work_attribute
    work_attribute_type
    work_attribute_type_allowed_value
    work_gid_redirect
    work_meta
    work_tag
    work_type

    cover_art_archive.art_type
    cover_art_archive.image_type
    cover_art_archive.cover_art
    cover_art_archive.cover_art_type
    cover_art_archive.release_group_cover_art

    documentation.l_area_area_example
    documentation.l_area_artist_example
    documentation.l_area_instrument_example
    documentation.l_area_label_example
    documentation.l_area_place_example
    documentation.l_area_recording_example
    documentation.l_area_release_example
    documentation.l_area_release_group_example
    documentation.l_area_series_example
    documentation.l_area_url_example
    documentation.l_area_work_example
    documentation.l_artist_artist_example
    documentation.l_artist_instrument_example
    documentation.l_artist_label_example
    documentation.l_artist_recording_example
    documentation.l_artist_release_example
    documentation.l_artist_release_group_example
    documentation.l_artist_place_example
    documentation.l_artist_series_example
    documentation.l_artist_url_example
    documentation.l_artist_work_example
    documentation.l_instrument_instrument_example
    documentation.l_instrument_label_example
    documentation.l_instrument_place_example
    documentation.l_instrument_recording_example
    documentation.l_instrument_release_example
    documentation.l_instrument_release_group_example
    documentation.l_instrument_series_example
    documentation.l_instrument_url_example
    documentation.l_instrument_work_example
    documentation.l_label_label_example
    documentation.l_label_recording_example
    documentation.l_label_release_example
    documentation.l_label_release_group_example
    documentation.l_label_place_example
    documentation.l_label_series_example
    documentation.l_label_url_example
    documentation.l_label_work_example
    documentation.l_place_place_example
    documentation.l_place_recording_example
    documentation.l_place_release_example
    documentation.l_place_release_group_example
    documentation.l_place_series_example
    documentation.l_place_url_example
    documentation.l_place_work_example
    documentation.l_recording_recording_example
    documentation.l_recording_release_example
    documentation.l_recording_release_group_example
    documentation.l_recording_series_example
    documentation.l_recording_url_example
    documentation.l_recording_work_example
    documentation.l_release_group_release_group_example
    documentation.l_release_group_series_example
    documentation.l_release_group_url_example
    documentation.l_release_group_work_example
    documentation.l_release_release_example
    documentation.l_release_release_group_example
    documentation.l_release_series_example
    documentation.l_release_url_example
    documentation.l_release_work_example
    documentation.l_series_series_example
    documentation.l_series_url_example
    documentation.l_series_work_example
    documentation.l_url_url_example
    documentation.l_url_work_example
    documentation.l_work_work_example
    documentation.link_type_documentation

    statistics.statistic
    statistics.statistic_event

    wikidocs.wikidocs_index
);

=head1 NAME

MusicBrainz::Server::Constant - constants used in the database that
have a specific meaning

=head1 DESCRIPTION

Various row IDs have a specific meaning in the database, such as representing
special entities like "Various Artists" and "Deleted Label"

=head1 CONSTANTS

=over 4

=item $DLABEL_ID

Row ID for the Deleted Label entity

=item $VARTIST_ID, $VARTIST_GID

Row ID and GID's for the special artist "Various Artists"

=item $DARTIST_ID

Row ID for the Deleted Artist entity

=back

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

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

=cut
