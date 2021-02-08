package MusicBrainz::Server::Data::Role::Rating;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Rating;

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

role
{
    my $params = shift;

    requires 'c', '_entity_class';

    has 'rating' => (
        is => 'ro',
        builder => '_build_rating',
        lazy => 1
    );

    method '_build_rating' => sub
    {
        my $self = shift;
        return MusicBrainz::Server::Data::Rating->new(
            c => $self->c,
            type => $params->type,
            parent => $self
        );
    }
};


no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

