package MusicBrainz::Server::Entity::Language;

use Moose;
use MusicBrainz::Server::Translation::Languages qw( l );

extends 'MusicBrainz::Server::Entity';

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

sub l_name {
    my $self = shift;
    return l($self->name);
}

has 'iso_code_2t' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has 'iso_code_2b' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has 'iso_code_1' => (
    is => 'rw',
    isa => 'Maybe[Str]'
);

has 'iso_code_3' => (
    is => 'rw',
    isa => 'Str'
);

has 'frequency' => (
    is => 'rw',
    isa => 'Int'
);

sub bcp47 {
    my ($self) = @_;
    return $self->iso_code_1 if $self->iso_code_1;
    return $self->iso_code_3;
}

=attribute alpha_3_code

Three-letter code returned in the web service. Uses ISO 639-3, or falls back
to ISO 639-2/T (mostly for collective languages).

=cut

sub alpha_3_code {
    my ($self) = @_;
    return $self->iso_code_3 // $self->iso_code_2t;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{name} = $self->name;
    $json->{iso_code_1} = $self->iso_code_1;
    $json->{iso_code_2b} = $self->iso_code_2b;
    $json->{iso_code_2t} = $self->iso_code_2t;
    $json->{iso_code_3} = $self->iso_code_3;
    $json->{frequency} = $self->frequency;
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
