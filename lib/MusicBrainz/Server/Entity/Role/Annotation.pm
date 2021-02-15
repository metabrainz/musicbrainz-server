package MusicBrainz::Server::Entity::Role::Annotation;
use Moose::Role;

use MusicBrainz::Server::Entity::Types;

has 'latest_annotation' => (
    isa => 'Annotation',
    is  => 'rw',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    my $annotation = $self->latest_annotation;

    if (defined $annotation) {
        $json->{latest_annotation} = $annotation->TO_JSON;
    }

    return $json;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

