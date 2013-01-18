package MusicBrainz::Server::Controller::Role::Alias;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

requires 'load';

use MusicBrainz::Server::Entity::Alias;
use MusicBrainz::Server::NES::Controller::Utils qw( create_update );

my %model_to_search_hint_type_id = (
    Artist => 3,
    Label => 2,
    'NES::Work' => 2
);

sub alias_type_model {
    my ($c, $parent) = @_;
    my %type_model = (
        'NES::Work' => 'Work'
    );
    return $c->model($type_model{$parent})->alias_type;
}

sub aliases : Chained('load') PathPart('aliases')
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    my $m = $self->{model};

    my $aliases = $c->model($m)->get_aliases($entity);
    alias_type_model($c, $m)->load(@$aliases);

    $c->stash(
        aliases => $aliases,
    );
}

sub alias : Chained('load') PathPart('alias') CaptureArgs(0)
{
    my ($self, $c) = @_;

    my $qp = $c->req->query_params;

    my $all_aliases = $c->model( $self->{model} )->get_aliases($c->stash->{entity});
    my ($alias) = grep {
        $_->name eq $qp->{name}
    } @$all_aliases or $c->detach('/error_404');

    $c->stash(
        alias => $alias,
        all_aliases => $all_aliases
    );
}

sub add_alias : Chained('load') PathPart('add-alias') RequireAuth Edit
{
    my ($self, $c) = @_;
    my $entity = $c->stash->{entity};

    create_update(
        $self, $c,
        form => $self->_build_alias_form($c),
        build_tree => sub {
            my ($values, $revision) = @_;

            my $aliases = $c->model($self->{model})->get_aliases($revision);
            $self->{tree_entity}->new(
                aliases => [
                    @$aliases,
                    MusicBrainz::Server::Entity::Alias->new($values)
                ]
            );
        }
    );
}

sub delete_alias : Chained('alias') PathPart('delete') RequireAuth Edit
{
    my ($self, $c) = @_;

    my $entity = $c->stash->{entity};
    my $alias = $c->stash->{alias};

    create_update(
        $self, $c,
        form => $c->form(
            form => 'Confirm',
            init_object => { revision_id => $entity->revision_id }
        ),
        build_tree => sub {
            my ($values, $revision) = @_;

            return $self->{tree_entity}->new(
                aliases => [ _aliases_without($c->stash->{all_aliases}, $alias) ]
            );
        }
    );

        # on_creation => sub { $self->_redir_to_aliases($c) }
}

sub edit_alias : Chained('alias') PathPart('edit') RequireAuth Edit
{
    my ($self, $c) = @_;

    my $alias = $c->stash->{alias};
    my $entity = $c->stash->{entity};

    create_update(
        $self, $c,
        form => $self->_build_alias_form($c, $alias),
        build_tree => sub {
            my ($values, $revision) = @_;

            return $self->{tree_entity}->new(
                aliases => [
                    _aliases_without($c->stash->{all_aliases}, $alias),
                    MusicBrainz::Server::Entity::Alias->new($values),
                ]
            );
        }
    );

        # on_creation => sub { $self->_redir_to_aliases($c) }
}

sub _aliases_without {
    my ($aliases, $alias) = @_;
    return grep { $_ != $alias } @$aliases;
}

sub _redir_to_aliases
{
    my ($self, $c) = @_;
    my $action = $c->controller->action_for('aliases');
    my $entity = $c->stash->{ $self->{entity_name} };
    $c->response->redirect($c->uri_for($action, [ $entity->gid ]));
}

sub _build_alias_form {
    my ($self, $c, $alias) = @_;
    my $model_name = $self->{model};

    $c->form(
        form => 'Alias',
        search_hint_type_id => $model_to_search_hint_type_id{ $model_name },
        type_model => alias_type_model($c, $model_name),
        init_object => {
            %{ $alias // {} },
            revision_id => $c->stash->{entity}->revision_id
        }
    )
}

no Moose::Role;
1;
