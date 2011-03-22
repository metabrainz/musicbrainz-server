package MusicBrainz::Server::Controller::Role::Merge;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

use MusicBrainz::Server::Translation qw ( l ln );

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

parameter 'merge_form' => (
    isa => 'Str',
    default => 'Merge'
);

role {
    my $params = shift;
    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            merge => { Local => undef, RequireAuth => undef, Edit => undef },
            merge_queue => { Local => undef, RequireAuth => undef, Edit => undef }
        }
    );

    use List::MoreUtils qw( part );
    use MusicBrainz::Server::Data::Utils qw( model_to_type );
    use MusicBrainz::Server::MergeQueue;

    method 'merge_queue' => sub {
        my ($self, $c) = @_;
        my $model = $c->model( $self->{model} );

        my $add = $c->req->params->{'add-to-merge'};
        my @add = ref($add) ? @$add : ($add);
        my @loaded = values %{ $model->get_by_ids(@add) };

        if (!$c->session->{merger} ||
            $c->session->{merger}->type ne $self->{model}) {
            $c->session->{merger} = MusicBrainz::Server::MergeQueue->new(
                type => $self->{model},
            );
        }

        my $merger = $c->session->{merger};
        $merger->add_entities(map { $_->id } @loaded);

        if ($merger->ready_to_merge) {
            $c->response->redirect(
                $c->uri_for_action(
                    $self->action_for('merge')));
        }
        else {
            $c->response->redirect(
                $loaded[0]
                    ? $c->uri_for_action(
                        $self->action_for('show'), [ $loaded[0]->gid ])
                    : $c->uri_for_action('/search/search'));
        }
    };

    method 'merge' => sub {
        my ($self, $c) = @_;

        my $action = $c->req->params->{submit} || '';
        if ($action eq 'remove') {
            $self->_merge_remove($c);
        }
        elsif ($action eq 'cancel') {
            $self->_merge_cancel($c);
        }
        else {
            $self->_merge_confirm($c);
        }
    };

    method _merge_cancel => sub {
        my ($self, $c) = @_;
        delete $c->session->{merger};
        $c->res->redirect($c->req->referer);
        $c->detach;
    };

    method _merge_remove => sub {
        my ($self, $c) = @_;

        my $merger = $c->session->{merger}
            or $c->res->redirect('/'), $c->detach;

        my $submitted = $c->req->params->{remove};
        my @remove = ref($submitted) ? @$submitted : ($submitted);
        $merger->remove_entities(@remove);

        $self->_merge_cancel($c)
            if $merger->entity_count == 0;

        $c->res->redirect($c->req->referer);
        $c->detach;
    };

    method _merge_form_arguments => sub { };

    method _merge_confirm => sub {
        my ($self, $c) = @_;
        $c->stash(
            template => $c->namespace . '/merge.tt',
            hide_merge_helper => 1
        );

        my $merger = $c->session->{merger}
            or $c->res->redirect('/'), $c->detach;

        my @entities = values %{
            $c->model($merger->type)->get_by_ids($merger->all_entities)
        };

        $c->detach
            unless $merger->ready_to_merge;

        my $form = $c->form(
            form => $params->merge_form,
            $self->_merge_form_arguments($c, @entities)
        );
        if ($form->submitted_and_valid($c->req->params)) {
            my $new_id = $form->field('target')->value or die 'Coludnt figure out new_id';
            my ($new, $old) = part { $_->id == $new_id ? 0 : 1 } @entities;
            $self->_insert_edit($c, $form,
                edit_type => $params->edit_type,
                new_entity => {
                    id => $new->[0]->id,
                    name => $new->[0]->name,
                },
                old_entities => [ map +{
                    id => $_->id,
                    name => $_->name
                }, @$old ],
                map { $_->name => $_->value } $form->edit_fields
            );

            $c->session->{merger} = undef;

            $c->response->redirect(
                $c->uri_for_action($self->action_for('show'), [ $new->[0]->gid ])
            );
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
      
