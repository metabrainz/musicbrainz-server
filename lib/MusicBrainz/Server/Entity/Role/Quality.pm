package MusicBrainz::Server::Entity::Role::Quality;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Types qw( Quality );

has 'quality' => (
    isa => Quality,
    is  => 'rw',
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{quality} = $self->quality;
    return $json;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
