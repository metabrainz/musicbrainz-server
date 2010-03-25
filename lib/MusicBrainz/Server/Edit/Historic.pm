package MusicBrainz::Server::Edit::Historic;
use Moose;
use MooseX::ABC;
use MooseX::Types::Moose qw( Int HashRef Maybe Object Str );

extends 'MusicBrainz::Server::Edit';

has 'migration' => (
    isa     => Object,
    is      => 'ro',
    handles => [qw(
        find_release_group_id
        resolve_album_id
        resolve_release_id
        resolve_recording_id
        artist_name
    )]
);

has [qw( artist_id row_id )] => (
    isa => Int,
    is  => 'ro',
);

has [qw( table column )] => (
    isa => Str,
    is  => 'ro'
);

has [qw( new_value previous_value )] => (
    isa => Maybe[HashRef | Str],
    is  => 'ro',
);

sub deserialize_previous_value { 1 }
sub deserialize_new_value      { 1 }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
