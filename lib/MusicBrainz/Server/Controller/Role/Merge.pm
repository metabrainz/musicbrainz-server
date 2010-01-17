package MusicBrainz::Server::Controller::Role::Merge;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

parameter 'edit_arguments' => (
    isa => 'CodeRef',
    default => sub { sub { } }
);

parameter 'confirmation_template' => (
    isa => 'Str',
    required => 1
);

parameter 'search_template' => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            merge => { Chained => 'load', RequireAuth => undef }
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
                $c->stash( message => 'You cannot merge an entity into itself' );
                $c->detach('/error_500');
            }

            $c->stash(
                template => $params->confirmation_template,
                old => $old,
                new => $new
            );

            $self->edit_action($c,
                form => 'Confirm',
                type => $params->edit_type,
                edit_args => {
                    old_entity_id => $old->id,
                    new_entity_id => $new->id
                },
                on_creation => sub {
                    $c->response->redirect(
                        $c->uri_for_action($self->action_for('show'), [ $new->gid ]));
                }
            );
        }
        else {
            my $query = $c->form( query_form => 'Search::Query', name => 'filter' );
            if ($query->submitted_and_valid($c->req->params)) {
                my $results = $self->_load_paged($c, sub {
                    $c->model('DirectSearch')->search(model_to_type($self->{model}),
                                                      $query->field('query')->value, shift, shift)
                });

                $results = [ grep { $_->entity->id != $old->id } @$results ];
                $c->stash( search_results => $results );
            }
            $c->stash( template => $params->search_template );
        }
    };
};

1;
