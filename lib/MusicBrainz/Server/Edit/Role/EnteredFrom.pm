package MusicBrainz::Server::Edit::Role::EnteredFrom;
use Moose::Role;

use MusicBrainz::Server::Constants qw( %ENTITIES );

around build_display_data => sub {
    my ($orig, $self, @args) = @_;

    my $data = $self->$orig(@args);

    my $entered_from_data = $self->data->{entered_from};

    if ($entered_from_data) {
        my $entity_properties = $ENTITIES{ $entered_from_data->{entity_type} };
        my $model = $entity_properties->{model};

        my $entity_class = "MusicBrainz::Server::Entity::$model";

        my $entity = $self->c->model($model)->get_by_gid($entered_from_data->{gid}) ||
                     $entity_class->new(
                        name => $entered_from_data->{name},
                     );

        $self->c->model('ArtistCredit')->load($entity)
            if $entity_properties->{artist_credits};

        $data->{entered_from} = $entity->TO_JSON;
    }

    return $data;
};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2025 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

