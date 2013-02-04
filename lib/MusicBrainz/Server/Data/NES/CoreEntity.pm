package MusicBrainz::Server::Data::NES::CoreEntity;
use MooseX::Role::Parameterized;

parameter 'root' => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;

    requires 'tree_to_json', 'map_core_entity';

    method create => sub {
        my ($self, $edit, $editor, $tree) = @_;

        my $response = $self->request($params->root . '/create', {
            edit => $edit->id,
            editor => $editor->id,
            $self->tree_to_json($tree)
        });

        return $self->get_revision($response->{ref})
    };

    method update => sub {
        my ($self, $edit, $editor, $base_revision, $tree) = @_;

        die 'Need a base revision' unless $base_revision;

        my $final_tree = $tree->complete
            ? $tree
            : $self->view_tree($base_revision)->merge($tree);

        my $response = $self->request($params->root . '/update', {
            edit => $edit->id,
            editor => $editor->id,
            revision => $base_revision->revision_id,
            $self->tree_to_json($final_tree)
        });

        return undef;
    };

    method get_revision => sub {
        my ($self, $revision_id) = @_;
        return $self->_new_from_core_entity(
            $self->request($params->root . '/view-revision', { revision => $revision_id }));
    };

    method get_by_gid => sub {
        my ($self, $gid) = @_;
        return $self->_new_from_core_entity(
            $self->request($params->root . '/find-latest', { mbid => $gid }))
    };

    method get_by_gids => sub {
        my ($self, @gids) = @_;
        return {
            map {
                my $e = $self->get_by_gid($_);
                $e->gid => $e
            } @gids
        };
    };

    method _new_from_core_entity => sub {
        my ($self, $response) = @_;
        return keys %$response == 0
            ? undef
            : $self->map_core_entity($response);
    };
};

1;
