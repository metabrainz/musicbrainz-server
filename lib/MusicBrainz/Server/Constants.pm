package MusicBrainz::Server::Constants;

use strict;
use warnings;

use base 'Exporter';

use DateTime::Duration;
use DateTime::Locale '1.00';
use File::Basename qw( dirname );
use File::Slurp qw( read_file );
use File::Spec;
use JSON qw( decode_json );
use List::AllUtils qw( uniq );
use Readonly;

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
    direction          => _get(qr/^DIRECTION_/),
    edit_type          => _get(qr/^EDIT_/),
    expire_action      => _get(qr/^EXPIRE_/),
    quality            => _get(qr/^QUALITY_/),
    alias              => _get(qr/^EDIT_.*_ALIAS$/),
    annotation         => _get(qr/^EDIT_.*_ADD_ANNOTATION$/),
    create_entity      => _get(qr/^EDIT_.*_CREATE$/),
    historic           => _get(qr/^EDIT_HISTORIC_/),
    editor             => _get(qr/^EDITOR_/),
    vote               => _get(qr/^VOTE_/),
    edit_status        => _get(qr/^STATUS_/),
    access_scope       => _get(qr/^ACCESS_SCOPE_/),
    privileges         => _get(qr/_FLAGS?$/),
    language_frequency => _get(qr/^LANGUAGE_FREQUENCY/),
    script_frequency   => _get(qr/^SCRIPT_FREQUENCY/),
    election_status => [
        qw( $ELECTION_SECONDER_1 $ELECTION_SECONDER_2 $ELECTION_OPEN
            $ELECTION_ACCEPTED   $ELECTION_REJECTED   $ELECTION_CANCELLED )
    ],
    election_vote => [
        qw( $ELECTION_VOTE_YES $ELECTION_VOTE_NO $ELECTION_VOTE_ABSTAIN )
    ],
    email_addresses => [
        qw( $EMAIL_NOREPLY_ADDR_SPEC $EMAIL_NOREPLY_ADDRESS
            $EMAIL_SUPPORT_ADDRESS $EMAIL_ACCOUNT_ADMINS_ADDRESS )
    ],
    oauth_redirect_uri_re => [
        qw( $OAUTH_INSTALLED_APP_REDIRECT_URI_RE $OAUTH_WEB_APP_REDIRECT_URI_RE )
    ],
);

our @EXPORT_OK = (
    (uniq map { @$_ } values %EXPORT_TAGS),
    qw(
        $DLABEL_ID $DARTIST_ID $VARTIST_ID $VARTIST_GID $NOLABEL_ID $NOLABEL_GID
        $COVERART_FRONT_TYPE $COVERART_BACK_TYPE
        $AREA_TYPE_COUNTRY $AREA_TYPE_CITY
        $ARTIST_TYPE_PERSON $ARTIST_TYPE_GROUP
        $INSTRUMENT_ROOT_ID $VOCAL_ROOT_ID
        $REQUIRED_VOTES $OPEN_EDIT_DURATION
        $MINIMUM_RESPONSE_PERIOD $MINIMUM_VOTING_PERIOD
        $LIMIT_FOR_EDIT_LISTING
        $ARTIST_ARTIST_COLLABORATION
        $AMAZON_ASIN_LINK_TYPE_ID
        %PART_OF_SERIES $PART_OF_AREA_LINK_TYPE $PART_OF_AREA_LINK_TYPE_ID
        $SERIES_ORDERING_TYPE_AUTOMATIC $SERIES_ORDERING_TYPE_MANUAL
        $ARTIST_RENAME_LINK_TYPE
        $LABEL_RENAME_LINK_TYPE
        $MAX_INITIAL_MEDIUMS $MAX_INITIAL_TRACKS
        $MAX_POSTGRES_INT $MAX_POSTGRES_BIGINT
        @FULL_TABLE_LIST
        @CORE_TABLE_LIST
        @DERIVED_TABLE_LIST
        @STATS_TABLE_LIST
        @EDITOR_TABLE_LIST
        @EDIT_TABLE_LIST
        @PRIVATE_TABLE_LIST
        @CDSTUBS_TABLE_LIST
        @CAA_TABLE_LIST
        @EAA_TABLE_LIST
        @WIKIDOCS_TABLE_LIST
        @DOCUMENTATION_TABLE_LIST
        @SITEMAPS_TABLE_LIST
        $CONTACT_URL
        $WS_EDIT_RESPONSE_OK $WS_EDIT_RESPONSE_NO_CHANGES
        %ENTITIES_WITH_RELATIONSHIP_CREDITS
        %HISTORICAL_RELEASE_GROUP_TYPES
        %ENTITIES entities_with @RELATABLE_ENTITIES
        $EDITOR_SANITISED_COLUMNS
        $PASSPHRASE_BCRYPT_COST
        %ALIAS_LOCALES
    ),
);

Readonly our $DLABEL_ID => 1;
Readonly our $DARTIST_ID => 2;

Readonly our $VARTIST_GID => '89ad4ac3-39f7-470e-963a-56509c546377';
Readonly our $VARTIST_ID  => 1;

Readonly our $NOLABEL_GID => '157afde4-4bf5-4039-8ad2-5a15acc85176';
Readonly our $NOLABEL_ID  => 3267;

Readonly our $DIRECTION_FORWARD => 1;
Readonly our $DIRECTION_BACKWARD => 2;

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
Readonly our $EDIT_RELEASEGROUP_ADD_ALIAS => 26;
Readonly our $EDIT_RELEASEGROUP_DELETE_ALIAS => 27;
Readonly our $EDIT_RELEASEGROUP_EDIT_ALIAS => 28;

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
Readonly our $EDIT_RELEASE_ADD_ALIAS => 318;
Readonly our $EDIT_RELEASE_DELETE_ALIAS => 319;
Readonly our $EDIT_RELEASE_EDIT_ALIAS => 320;

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
Readonly our $EDIT_RECORDING_REMOVE_ISRC => 78;
Readonly our $EDIT_RECORDING_ADD_ALIAS => 711;
Readonly our $EDIT_RECORDING_DELETE_ALIAS => 712;
Readonly our $EDIT_RECORDING_EDIT_ALIAS => 713;

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

Readonly our $EDIT_EVENT_CREATE => 150;
Readonly our $EDIT_EVENT_EDIT => 151;
Readonly our $EDIT_EVENT_DELETE => 152;
Readonly our $EDIT_EVENT_MERGE => 153;
Readonly our $EDIT_EVENT_ADD_ANNOTATION => 154;
Readonly our $EDIT_EVENT_ADD_ALIAS => 155;
Readonly our $EDIT_EVENT_DELETE_ALIAS => 156;
Readonly our $EDIT_EVENT_EDIT_ALIAS => 157;

Readonly our $EDIT_GENRE_CREATE => 160;
Readonly our $EDIT_GENRE_EDIT => 161;
Readonly our $EDIT_GENRE_DELETE => 162;
# 163 reserved for EDIT_GENRE_MERGE if ever implemented
Readonly our $EDIT_GENRE_ADD_ANNOTATION => 164;
Readonly our $EDIT_GENRE_ADD_ALIAS => 165;
Readonly our $EDIT_GENRE_DELETE_ALIAS => 166;
Readonly our $EDIT_GENRE_EDIT_ALIAS => 167;

Readonly our $EDIT_WIKIDOC_CHANGE => 120;

Readonly our $EDIT_URL_EDIT => 101;

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
Readonly our $EDIT_HISTORIC_EDIT_RELEASE_LANGUAGE   => 244;
Readonly our $EDIT_HISTORIC_EDIT_TRACK_LENGTH       => 245;
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

Readonly our $EMAIL_NOREPLY_ADDR_SPEC => 'noreply@musicbrainz.org';
Readonly our $EMAIL_NOREPLY_ADDRESS => 'MusicBrainz Server <' . $EMAIL_NOREPLY_ADDR_SPEC . '>';
Readonly our $EMAIL_SUPPORT_ADDRESS => 'MusicBrainz <support@musicbrainz.org>';
Readonly our $EMAIL_ACCOUNT_ADMINS_ADDRESS => 'MusicBrainz Account Admins <musicbrainz-account-admin@metabrainz.org>';

Readonly our $LANGUAGE_FREQUENCY_HIDDEN   =>  0;
Readonly our $LANGUAGE_FREQUENCY_OTHER    =>  1;
Readonly our $LANGUAGE_FREQUENCY_FREQUENT =>  2;

Readonly our $SCRIPT_FREQUENCY_HIDDEN   =>  1;
Readonly our $SCRIPT_FREQUENCY_UNCOMMON =>  2;
Readonly our $SCRIPT_FREQUENCY_OTHER    =>  3;
Readonly our $SCRIPT_FREQUENCY_FREQUENT =>  4;

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
Readonly our $STATUS_DELETED      => 9;

Readonly our $AUTO_EDITOR_FLAG              => 1;
Readonly our $BOT_FLAG                      => 2;
Readonly our $UNTRUSTED_FLAG                => 4;
Readonly our $RELATIONSHIP_EDITOR_FLAG      => 8;
Readonly our $DONT_NAG_FLAG                 => 16;
Readonly our $WIKI_TRANSCLUSION_FLAG        => 32;
Readonly our $MBID_SUBMITTER_FLAG           => 64;
Readonly our $ACCOUNT_ADMIN_FLAG            => 128;
Readonly our $LOCATION_EDITOR_FLAG          => 256;
Readonly our $BANNER_EDITOR_FLAG            => 512;
Readonly our $EDITING_DISABLED_FLAG         => 1024;
Readonly our $ADDING_NOTES_DISABLED_FLAG    => 2048;
Readonly our $SPAMMER_FLAG                  => 4096;
# If you update this, also update root/utility/sanitizedEditor.js
Readonly our $PUBLIC_PRIVILEGE_FLAGS        => $AUTO_EDITOR_FLAG &
                                               $BOT_FLAG &
                                               $RELATIONSHIP_EDITOR_FLAG &
                                               $WIKI_TRANSCLUSION_FLAG &
                                               $ACCOUNT_ADMIN_FLAG &
                                               $LOCATION_EDITOR_FLAG &
                                               $BANNER_EDITOR_FLAG;

Readonly our $ELECTION_VOTE_NO      => -1;
Readonly our $ELECTION_VOTE_ABSTAIN => 0;
Readonly our $ELECTION_VOTE_YES     => 1;

Readonly our $COVERART_FRONT_TYPE   => 1;
Readonly our $COVERART_BACK_TYPE   => 2;

Readonly our $INSTRUMENT_ROOT_ID => 14;
Readonly our $VOCAL_ROOT_ID => 3;

Readonly our $AREA_TYPE_COUNTRY => 1;
Readonly our $AREA_TYPE_CITY => 3;

Readonly our $ARTIST_TYPE_PERSON => 1;
Readonly our $ARTIST_TYPE_GROUP => 2;

Readonly our $REQUIRED_VOTES => 3;
Readonly our $OPEN_EDIT_DURATION => DateTime::Duration->new(days => 7);
Readonly our $MINIMUM_RESPONSE_PERIOD => DateTime::Duration->new(hours => 72);
Readonly our $MINIMUM_VOTING_PERIOD => DateTime::Duration->new(hours => 48);
Readonly our $LIMIT_FOR_EDIT_LISTING => 500;

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
    artist          => 'd1a845d1-8c03-3191-9454-e4e8d37fa5e0',
    event           => '707d947d-9563-328a-9a7d-0c5b9c3a9791',
    recording       => 'ea6f0698-6782-30d6-b16d-293081b66774',
    release         => '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d',
    release_group   => '01018437-91d8-36b9-bf89-3f885d53b5bd',
    work            => 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0',
);

Readonly our $AMAZON_ASIN_LINK_TYPE_ID => 77;

Readonly our $PART_OF_AREA_LINK_TYPE => 'de7cc874-8b1b-3a05-8272-f3834c968fb7';

Readonly our $PART_OF_AREA_LINK_TYPE_ID => 356;

Readonly our $ARTIST_RENAME_LINK_TYPE => '9752bfdf-13ca-441a-a8bc-18928c600c73';
Readonly our $LABEL_RENAME_LINK_TYPE => 'e6159066-6013-4d09-a2f8-bc473f21e89e';

Readonly our $MAX_INITIAL_MEDIUMS => 10;
Readonly our $MAX_INITIAL_TRACKS => 100;

Readonly our $MAX_POSTGRES_INT => 2147483647;
Readonly our $MAX_POSTGRES_BIGINT => 9223372036854775807;

Readonly our $CONTACT_URL => 'https://metabrainz.org/contact'; # Converted to React/JSX at root/static/scripts/common/constants.js

Readonly our $WS_EDIT_RESPONSE_OK => 1;
Readonly our $WS_EDIT_RESPONSE_NO_CHANGES => 2;

Readonly our %ENTITIES_WITH_RELATIONSHIP_CREDITS => map { $_ => 1 } qw(
    area
    artist
    instrument
    label
    place
);

Readonly our %HISTORICAL_RELEASE_GROUP_TYPES => (
    1 => 'Album',
    2 => 'Single',
    3 => 'EP',
    4 => 'Compilation',
    5 => 'Soundtrack',
    6 => 'Spokenword',
    7 => 'Interview',
    8 => 'Audiobook',
    9 => 'Live',
    10 => 'Remix',
    11 => 'Other',
);

sub _decode_entities_json {
    my $entities_json = decode_json(read_file(File::Spec->catfile(dirname(__FILE__), '../../../entities.json')));
    delete $entities_json->{''};
    return $entities_json;
}

Readonly our %ENTITIES => %{ _decode_entities_json() };

sub extract_path {
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
}

sub entities_with {
    my ($props, %opts) = @_;
    if (ref($props) ne 'ARRAY') {
        $props = [[$props]];
    }
    if (ref($props->[0]) ne 'ARRAY') {
        $props = [$props];
    }

    my @entity_types;
    ENTITY: for my $entity_type (keys %ENTITIES) {
        for my $prop (@$props) {
            extract_path($ENTITIES{$entity_type}, $prop) or next ENTITY;
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
        return map { extract_path($ENTITIES{$_}, $take) } @entity_types;
    } else {
        return @entity_types;
    }
}

Readonly our @RELATABLE_ENTITIES =>
    sort { $a cmp $b } entities_with(['mbid', 'relatable']);

Readonly our @CORE_TABLE_LIST => qw(
    alternative_medium
    alternative_medium_track
    alternative_release
    alternative_release_type
    alternative_track
    area
    area_alias
    area_alias_type
    area_attribute
    area_attribute_type
    area_attribute_type_allowed_value
    area_gid_redirect
    area_type
    artist
    artist_alias
    artist_alias_type
    artist_attribute
    artist_attribute_type
    artist_attribute_type_allowed_value
    artist_credit
    artist_credit_gid_redirect
    artist_credit_name
    artist_gid_redirect
    artist_ipi
    artist_isni
    artist_type
    cdtoc
    country_area
    editor_collection_type
    event
    event_alias
    event_alias_type
    event_attribute
    event_attribute_type
    event_attribute_type_allowed_value
    event_gid_redirect
    event_type
    gender
    genre
    genre_alias
    genre_alias_type
    instrument
    instrument_alias
    instrument_alias_type
    instrument_attribute
    instrument_attribute_type
    instrument_attribute_type_allowed_value
    instrument_gid_redirect
    instrument_type
    iso_3166_1
    iso_3166_2
    iso_3166_3
    isrc
    iswc
    l_area_area
    l_area_artist
    l_area_event
    l_area_genre
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
    l_artist_event
    l_artist_genre
    l_artist_instrument
    l_artist_label
    l_artist_place
    l_artist_recording
    l_artist_release
    l_artist_release_group
    l_artist_series
    l_artist_url
    l_artist_work
    l_event_event
    l_event_genre
    l_event_instrument
    l_event_label
    l_event_place
    l_event_recording
    l_event_release
    l_event_release_group
    l_event_series
    l_event_url
    l_event_work
    l_genre_genre
    l_genre_instrument
    l_genre_label
    l_genre_place
    l_genre_recording
    l_genre_release
    l_genre_release_group
    l_genre_series
    l_genre_url
    l_genre_work
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
    label_attribute
    label_attribute_type
    label_attribute_type_allowed_value
    label_gid_redirect
    label_ipi
    label_isni
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
    medium
    medium_attribute
    medium_attribute_type
    medium_attribute_type_allowed_format
    medium_attribute_type_allowed_value
    medium_attribute_type_allowed_value_allowed_format
    medium_cdtoc
    medium_format
    orderable_link_type
    place
    place_alias
    place_alias_type
    place_attribute
    place_attribute_type
    place_attribute_type_allowed_value
    place_gid_redirect
    place_type
    recording
    recording_alias
    recording_alias_type
    recording_attribute
    recording_attribute_type
    recording_attribute_type_allowed_value
    recording_gid_redirect
    release
    release_alias
    release_alias_type
    release_attribute
    release_attribute_type
    release_attribute_type_allowed_value
    release_country
    release_gid_redirect
    release_group
    release_group_alias
    release_group_alias_type
    release_group_attribute
    release_group_attribute_type
    release_group_attribute_type_allowed_value
    release_group_gid_redirect
    release_group_primary_type
    release_group_secondary_type
    release_group_secondary_type_join
    release_label
    release_packaging
    release_status
    release_unknown_country
    replication_control
    script
    series
    series_alias
    series_alias_type
    series_attribute
    series_attribute_type
    series_attribute_type_allowed_value
    series_gid_redirect
    series_ordering_type
    series_type
    track
    track_gid_redirect
    url
    url_gid_redirect
    work
    work_alias
    work_alias_type
    work_attribute
    work_attribute_type
    work_attribute_type_allowed_value
    work_gid_redirect
    work_language
    work_type
);

Readonly our @DERIVED_TABLE_LIST => qw(
    annotation
    area_annotation
    area_tag
    artist_annotation
    artist_meta
    artist_tag
    event_annotation
    event_meta
    event_tag
    instrument_annotation
    instrument_tag
    label_annotation
    label_meta
    label_tag
    medium_index
    place_annotation
    place_meta
    place_tag
    recording_annotation
    recording_meta
    recording_tag
    release_annotation
    release_group_annotation
    release_group_meta
    release_group_tag
    release_meta
    release_tag
    series_annotation
    series_tag
    tag
    tag_relation
    work_annotation
    work_meta
    work_tag
);

Readonly our @STATS_TABLE_LIST => qw(
    statistics.statistic
    statistics.statistic_event
);

Readonly our @EDIT_TABLE_LIST => qw(
    edit
    edit_area
    edit_artist
    edit_data
    edit_event
    edit_instrument
    edit_label
    edit_note
    edit_note_recipient
    edit_place
    edit_recording
    edit_release
    edit_release_group
    edit_series
    edit_url
    edit_work
    vote
);

Readonly our @EDITOR_TABLE_LIST => qw(
    editor_sanitised
);

Readonly our @PRIVATE_TABLE_LIST => qw(
    application
    area_tag_raw
    artist_rating_raw
    artist_tag_raw
    autoeditor_election
    autoeditor_election_vote
    editor
    editor_collection
    editor_collection_area
    editor_collection_artist
    editor_collection_collaborator
    editor_collection_deleted_entity
    editor_collection_event
    editor_collection_gid_redirect
    editor_collection_instrument
    editor_collection_label
    editor_collection_place
    editor_collection_recording
    editor_collection_release
    editor_collection_release_group
    editor_collection_series
    editor_collection_work
    editor_language
    editor_oauth_token
    editor_preference
    editor_subscribe_artist
    editor_subscribe_collection
    editor_subscribe_editor
    editor_subscribe_label
    editor_subscribe_series
    editor_watch_artist
    editor_watch_preferences
    editor_watch_release_group_type
    editor_watch_release_status
    event_rating_raw
    event_tag_raw
    instrument_tag_raw
    label_rating_raw
    label_tag_raw
    old_editor_name
    place_rating_raw
    place_tag_raw
    recording_rating_raw
    recording_tag_raw
    release_group_rating_raw
    release_group_tag_raw
    release_tag_raw
    series_tag_raw
    work_rating_raw
    work_tag_raw
);

Readonly our @CDSTUBS_TABLE_LIST => qw(
    cdtoc_raw
    release_raw
    track_raw
);

Readonly our @CAA_TABLE_LIST => qw(
    cover_art_archive.art_type
    cover_art_archive.cover_art
    cover_art_archive.cover_art_type
    cover_art_archive.image_type
    cover_art_archive.release_group_cover_art
);

Readonly our @EAA_TABLE_LIST => qw(
    event_art_archive.art_type
    event_art_archive.event_art
    event_art_archive.event_art_type
);

Readonly our @WIKIDOCS_TABLE_LIST => qw(
    wikidocs.wikidocs_index
);

Readonly our @DOCUMENTATION_TABLE_LIST => qw(
    documentation.l_area_area_example
    documentation.l_area_artist_example
    documentation.l_area_event_example
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
    documentation.l_artist_event_example
    documentation.l_artist_instrument_example
    documentation.l_artist_label_example
    documentation.l_artist_place_example
    documentation.l_artist_recording_example
    documentation.l_artist_release_example
    documentation.l_artist_release_group_example
    documentation.l_artist_series_example
    documentation.l_artist_url_example
    documentation.l_artist_work_example
    documentation.l_event_event_example
    documentation.l_event_instrument_example
    documentation.l_event_label_example
    documentation.l_event_place_example
    documentation.l_event_recording_example
    documentation.l_event_release_example
    documentation.l_event_release_group_example
    documentation.l_event_series_example
    documentation.l_event_url_example
    documentation.l_event_work_example
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
    documentation.l_label_place_example
    documentation.l_label_recording_example
    documentation.l_label_release_example
    documentation.l_label_release_group_example
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
);

Readonly our @SITEMAPS_TABLE_LIST => qw(
    sitemaps.artist_lastmod
    sitemaps.control
    sitemaps.label_lastmod
    sitemaps.place_lastmod
    sitemaps.recording_lastmod
    sitemaps.release_group_lastmod
    sitemaps.release_lastmod
    sitemaps.work_lastmod
);

Readonly our @FULL_TABLE_LIST => (
    @CORE_TABLE_LIST,
    @DERIVED_TABLE_LIST,
    @STATS_TABLE_LIST,
    @EDITOR_TABLE_LIST,
    @EDIT_TABLE_LIST,
    @PRIVATE_TABLE_LIST,
    @CDSTUBS_TABLE_LIST,
    @CAA_TABLE_LIST,
    @EAA_TABLE_LIST,
    @WIKIDOCS_TABLE_LIST,
    @DOCUMENTATION_TABLE_LIST,
    @SITEMAPS_TABLE_LIST,
);

Readonly our $EDITOR_SANITISED_COLUMNS => join(', ',
    'editor.id',
    'editor.name',
    '0 AS privs',
    q('' AS email),
    'NULL AS website',
    'NULL AS bio',
    'editor.member_since',
    'editor.email_confirm_date',
    'now() AS last_login_date',
    'editor.last_updated',
    'NULL AS birth_date',
    'NULL AS gender',
    'NULL as area',
    q('{CLEARTEXT}mb' AS password),
    q{md5(editor.name || ':musicbrainz.org:mb') AS ha1},
    'editor.deleted',
);

Readonly our $PASSPHRASE_BCRYPT_COST => 12;

Readonly our $OAUTH_INSTALLED_APP_REDIRECT_URI_RE => qr/^(?![_-])[\w-]+(?:\.(?![_-])[\w-]+)+:/;
Readonly our $OAUTH_WEB_APP_REDIRECT_URI_RE => qr/^https?:\/\//;

=item %ALIAS_LOCALES

Historically, alias locales have been stored in the database and
returned in the web service using underscores instead of dashes, e.g.
zh_Hant_HK instead of zh-Hant-HK. Presumably this was simply because
that was how DateTime::Locale returned them prior to version 1.00.
The primary reason to continue doing this is to maintain compatibility
for data users.

Thus, we define these locale codes as Unicode CLDR locale identifiers
[1], but they can be converted to and from BCP 47 language tags quite
easily still [2].

[1] https://www.unicode.org/reports/tr35/tr35.html#BCP_47_Conformance
[2] https://www.unicode.org/reports/tr35/tr35.html
    #Unicode_Locale_Identifier_CLDR_to_BCP_47

=cut

Readonly our %ALIAS_LOCALES => map {
    my $id = ($_ =~ s/-/_/gr);
    $id => DateTime::Locale->load($_);
} DateTime::Locale->codes;

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

=item $NOLABEL_ID, $NOLABEL_GID

Row ID and GID for the special label "[no label]"

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
