package MusicBrainz::Server::Entity::Track;

use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Track qw( format_track_length );

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';
with 'MusicBrainz::Server::Entity::Role::ArtistCredit';
with 'MusicBrainz::Server::Entity::Role::GID';
with 'MusicBrainz::Server::Entity::Role::Name';

has 'recording_id' => (
    is => 'rw',
    isa => 'Int',
    clearer => 'clear_recording_id'
);

has 'recording' => (
    is => 'rw',
    isa => 'Recording',
    clearer => 'clear_recording'
);

has 'medium_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'medium' => (
    is => 'rw',
    isa => 'Medium'
);

has 'position' => (
    is => 'rw',
    isa => 'Int'
);

has 'number' => (
    is => 'rw',
    isa => 'Str'
);

has 'length' => (
    is => 'rw',
    isa => 'Maybe[Int]',
    clearer => 'clear_length'
);

sub formatted_length {
    format_track_length(shift->length);
}

has 'is_data_track' => (
    is => 'rw',
    isa => 'Bool',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $output = {
        %{ $self->$orig },
        isDataTrack     => boolean_to_json($self->is_data_track),
        length          => $self->length,
        medium          => $self->medium ? $self->medium->TO_JSON : undef,
        medium_id       => 0 + $self->medium_id,
        number          => $self->number,
        position        => $self->position,
    };

    if ($self->recording) {
        $output->{recording} = $self->recording->TO_JSON;

        delete $output->{recording}->{artistCredit} unless (
            MusicBrainz::Server::Entity::ArtistCredit::is_different(
                $self->artist_credit,
                $self->recording->artist_credit,
            ));
    }

    return $output;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
