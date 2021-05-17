package MusicBrainz::Server::Entity::MediumCDTOC;

use List::AllUtils qw( all pairs zip );
use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

sub entity_type { 'medium_cdtoc' }

has 'cdtoc_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'cdtoc' => (
    is => 'rw',
    isa => 'CDTOC'
);

has 'medium_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'medium' => (
    is => 'rw',
    isa => 'Medium'
);

sub is_perfect_match {
    my ($self) = @_;

    my @cdtoc_info = @{ $self->cdtoc->track_details };
    my @medium_track_lengths = @{ $self->medium->cdtoc_track_lengths // [] };

    return (@cdtoc_info == @medium_track_lengths) && all {
      defined $_->[1] && $_->[0]{length_time} == $_->[1]
    } (pairs (zip @cdtoc_info, @medium_track_lengths));
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{cdtoc} = $self->cdtoc->TO_JSON;
    return $json;
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
