package MusicBrainz::Server::Data::Role::Annotation;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::EntityAnnotation;

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

parameter 'table' => (
    isa => 'Str',
    default => sub { shift->type . '_annotation' },
    lazy => 1
);

role
{
    my $params = shift;

    requires 'c';

    has 'annotation' => (
        is => 'ro',
        lazy => 1,
        builder => '_build_annotation_data',
    );

    method '_build_annotation_data' => sub
    {
        my $self = shift;
        return MusicBrainz::Server::Data::EntityAnnotation->new(
            c => $self->c,
            type => $params->type,
            table => $params->table,
        );
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

