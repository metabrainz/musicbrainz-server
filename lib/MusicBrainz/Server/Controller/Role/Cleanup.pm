package MusicBrainz::Server::Controller::Role::Cleanup;
use Moose::Role;
use MusicBrainz::Server::Constants qw( entities_with );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use namespace::autoclean;

my %model_to_edit_type = entities_with('add_edit_type', take => sub {
    my ($type, $properties) = @_;
    return ($properties->{model} => $properties->{add_edit_type});
});

after show => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};

    my $model = $self->config->{model};

    my $edits_pending = $entity->edits_pending;

    if ($edits_pending == 1) {
        my $creation_edit = $c->model('Edit')->find_creation_edit(
            $model_to_edit_type{$model},
            $entity->id,
        );

        # If the creation edit is the only pending edit and the entity
        # is otherwise empty, it will be removed as soon as the edit passes,
        # so we want to treat it as having no pending edits
        # for the purpose of displaying the cleanup banner

        if ($creation_edit && $creation_edit->is_open) {
            $edits_pending = 0;
        }
    }

    my $eligible_for_cleanup =
        $edits_pending == 0 &&
        $c->model($model)->is_empty($entity->id);

    $c->stash->{component_props}{eligibleForCleanup} =
        boolean_to_json($eligible_for_cleanup);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
