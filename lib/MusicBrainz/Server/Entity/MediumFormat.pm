package MusicBrainz::Server::Entity::MediumFormat;

use Moose;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'MediumFormat',
};

sub entity_type { 'medium_format' }

sub l_name {
    my $self = shift;
    return lp($self->name, 'medium_format')
}

has 'year' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'has_discids' => (
    is => 'rw',
    isa => 'Bool'
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{year} = $self->year;
    $json->{has_discids} = boolean_to_json($self->has_discids);
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
