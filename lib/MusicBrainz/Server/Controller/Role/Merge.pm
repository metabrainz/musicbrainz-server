package MusicBrainz::Server::Controller::Role::Merge;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

use MusicBrainz::Server::Log qw( log_assertion );
use MusicBrainz::Server::Translation qw ( l ln );
use MusicBrainz::Server::Validation qw( is_positive_integer );

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
            merge => { Local => undef, Edit => undef },
            merge_queue => { Local => undef, Edit => undef }
        }
    );

    use List::MoreUtils qw( part );
    use MusicBrainz::Server::Data::Utils qw( model_to_type );
    use MusicBrainz::Server::MergeQueue;

    method 'merge_queue' => sub {
        my ($self, $c) = @_;
        my $model = $c->model( $self->{model} );

        my $add = exists $c->req->params->{'add-to-merge'} ? $c->req->params->{'add-to-merge'} : [];
        my @add = ref($add) ? @$add : ($add);
        @add = grep { is_positive_integer($_) } @add;

        if (@add) {
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
                $c->detach;
            }
        }

        $c->response->redirect(
            $c->req->referer ||
                $c->uri_for_action('/search/search'));
        $c->detach;
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
        $c->res->redirect(
            $c->req->referer || $c->uri_for('/'));
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

        $c->res->redirect(
            $c->req->referer || $c->uri_for('/'));
        $c->detach;
    };

    method _merge_form_arguments => sub { };

    method _merge_load_entities => sub { };

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

        my $check_form = $c->form(form => 'Merge');
        if ($check_form->submitted_and_valid($c->req->params)) {
            # Ensure that we use the entities that appeared on the page and the right type,
            # in case the merger has changed since that page loaded (MBS-7057)
            @entities = values %{
                $c->model($self->{model})->get_by_ids(map { $_->value } $check_form->field('merging')->fields)
            };
        }

        $self->_merge_load_entities($c, @entities);
        $c->stash->{to_merge} = \@entities;

        my $form = $c->form(
            form => $params->merge_form,
            $self->_merge_form_arguments($c, @entities)
        );
        if ($self->_validate_merge($c, $form)) {
            $self->_merge_submit($c, $form, \@entities);
        }
    };

    method _validate_merge => sub {
        my ($self, $c, $form) = @_;
        return $form->submitted_and_valid($c->req->params);
    };

    method _merge_submit => sub {
        my ($self, $c, $form, $entities) = @_;

        my %entity_id = map { $_->id => $_ } @$entities;

        my $new_id = $form->field('target')->value or die 'Coludnt figure out new_id';
        my $new = $entity_id{$new_id};
        my @old_ids = grep { $_ != $new_id } @{ $form->field('merging')->value };

        log_assertion { @old_ids >= 1 } 'Got at least 1 entity to merge';

        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $params->edit_type,
                new_entity => {
                    id => $new->id,
                    name => $new->name,
                    $self->_extra_entity_data($c, $form, $new)
                },
                old_entities => [ map +{
                    id => $entity_id{$_}->id,
                    name => $entity_id{$_}->name,
                    $self->_extra_entity_data($c, $form, $entity_id{$_})
                }, @old_ids ],
                (map { $_->name => $_->value } $form->edit_fields),
                $self->_merge_parameters($c, $form, $entities)
            );
        });

        $c->session->{merger} = undef;

        $c->response->redirect(
            $c->uri_for_action($self->action_for('show'), [ $new->gid ])
        );
    };

    method _merge_parameters => sub {
        return ()
    };

    method _extra_entity_data => sub {
        return ()
    };
};

1;
      
