package MusicBrainz::Server::Form::OtherLookup;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'other-lookup' );

has_field 'catno' => (
    type => 'Text'
);

has_field 'barcode'  => (
    type => '+MusicBrainz::Server::Form::Field::Barcode',
);

has_field 'mbid'     => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'isrc' => (
    type => '+MusicBrainz::Server::Form::Field::ISRC',
);

has_field 'iswc'     => (
    type => '+MusicBrainz::Server::Form::Field::ISWC',
);

has_field 'artist-ipi'     => (
    type => '+MusicBrainz::Server::Form::Field::IPI',
);

has_field 'artist-isni'     => (
    type => '+MusicBrainz::Server::Form::Field::ISNI',
);

has_field 'label-ipi'     => (
    type => '+MusicBrainz::Server::Form::Field::IPI',
);

has_field 'label-isni'     => (
    type => '+MusicBrainz::Server::Form::Field::ISNI',
);

has_field 'puid' => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'discid' => (
    type => '+MusicBrainz::Server::Form::Field::DiscID',
);

has_field 'freedbid' => (
    type => '+MusicBrainz::Server::Form::Field::FreeDBID',
);

1;
