package MusicBrainz::Server::Entity::Instrument;

use Moose;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation::Instruments;
use MusicBrainz::Server::Translation::InstrumentDescriptions;

extends 'MusicBrainz::Server::Entity::CentralEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'InstrumentType' };

sub entity_type { 'instrument' }

sub l_name {
    my $self = shift;
    if ($self->comment) {
        return MusicBrainz::Server::Translation::Instruments::lp($self->name, $self->comment);
    } else {
        return MusicBrainz::Server::Translation::Instruments::l($self->name);
    }
}

has 'description' => (
    is => 'rw',
    isa => 'Str'
);

sub l_description {
    my $self = shift;
    return $self->description ? MusicBrainz::Server::Translation::InstrumentDescriptions::l($self->description) : undef;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    return {
        %{ $self->$orig },
        description => $self->description,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
