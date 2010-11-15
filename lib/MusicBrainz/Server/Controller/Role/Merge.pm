package MusicBrainz::Server::Controller::Role::Merge;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

use MusicBrainz::Server::Translation qw ( l ln );

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

parameter 'confirmation_template' => (
    isa => 'Str',
    required => 1
);

parameter 'search_template' => (
    isa => 'Str',
    required => 1
);

parameter 'merge_form' => (
    isa => 'Str',
    default => 'Confirm'
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            merge => { Chained => 'load', RequireAuth => undef, Edit => undef }
        }
    );

    use MusicBrainz::Server::Data::Utils qw( model_to_type );

    method 'merge' => sub {
        my ($self, $c) = @_;
        my $entity_name = $self->{entity_name};
        my $old         = $c->stash->{ $entity_name };

        if ($c->req->query_params->{dest}) {
            my $new = $c->model($self->{model})->get_by_gid($c->req->query_params->{dest});
            if ($new->id eq $old->id) {
                $c->stash( message => l('You cannot merge an entity into itself.') );
                $c->detach('/error_500');
            }

            $c->stash(
                template => $params->confirmation_template,
                old => $old,
                new => $new
            );

            $self->edit_action($c,
                form => $params->merge_form,
                type => $params->edit_type,
                edit_args => {
                    old_entities  => [ { id => $old->id, name => $old->name } ],
                    new_entity    => { id => $new->id, name => $new->name },
                },
                on_creation => sub {
                    $c->response->redirect(
                        $c->uri_for_action($self->action_for('show'), [ $new->gid ]));
                }
            );
        }
        else {
            my $query = $c->form( query_form => 'Search::Query', name => 'filter' );
            $query->field('query')->input($old->name);
            if ($query->submitted_and_valid($c->req->params)) {
                my $results = $self->_merge_search($c, $query->field('query')->value);
                $results = [ grep { $_->entity->id != $old->id } @$results ];
                $c->stash( search_results => $results );
            }
            $c->stash( template => $params->search_template );
        }
    };
};

sub _merge_search {
    my ($self, $c, $query) = @_;
    return $self->_load_paged($c, sub {
        $c->model('Search')->search(model_to_type($self->{model}),
                                    $query, shift, shift)
    });
}


1;
