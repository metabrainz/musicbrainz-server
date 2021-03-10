package MusicBrainz::Server::Controller::Role::Cleanup;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( entities_with );

my %model_to_edit_type = entities_with('add_edit_type', take => sub {
    my ($type, $properties) = @_;
    return ($properties->{model} => $properties->{add_edit_type});
});

after show => sub {
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};
    my $model = $self->config->{model};
    my $creation_edit = $c->model('Edit')->find_creation_edit(
        $model_to_edit_type{$model},
        $entity->id);
    # If the creation edit is the only pending edit
    # and the entity is otherwise empty,
    # it will be removed as soon as the creation edit passes
    my $in_cleanup_danger = $entity->edits_pending == 1 &&
        $creation_edit && $creation_edit->is_open &&
        $c->model($model)->is_empty($entity->id, ignore_edits => 1);
    my $eligible_for_cleanup = $c->model($model)->is_empty($entity->id);
    
    $c->stash->{component_props}{eligibleForCleanup} = $eligible_for_cleanup;
    $c->stash->{component_props}{inCleanupDanger} = $in_cleanup_danger;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
