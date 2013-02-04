package MusicBrainz::Server::Controller::Role::Merge;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

use List::MoreUtils qw( part );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Log qw( log_assertion );
use MusicBrainz::Server::MergeQueue;
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

    method 'merge_queue' => sub {
        my ($self, $c) = @_;
        my $model = $c->model( $self->{model} );

        my $add = exists $c->req->params->{'add-to-merge'} ? $c->req->params->{'add-to-merge'} : [];
        my @add = ref($add) ? @$add : ($add);

        if (@add) {
            my @loaded = $c->model('MB')->with_nes_transaction(sub {
                values %{ $model->get_by_gids(@add) };
            });

            if (!$c->session->{merger} ||
                 $c->session->{merger}->type ne $self->{model}) {
                $c->session->{merger} = MusicBrainz::Server::MergeQueue->new(
                    type => $self->{model},
                );
            }

            my $merger = $c->session->{merger};
            $merger->add_entities(map { $_->gid } @loaded);

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

    method _merge_confirm => sub {
        my ($self, $c) = @_;
        $c->stash(
            template => $c->namespace . '/merge.tt',
            hide_merge_helper => 1
        );

        my $merger = $c->session->{merger}
            or $c->res->redirect('/'), $c->detach;

        $c->detach
            unless $merger->ready_to_merge;

        $c->model('MB')->with_nes_transaction(sub {
            my @entities = values %{
                $c->model($merger->type)->get_by_gids($merger->all_entities)
            };

            my $form = $c->form(
                form => $params->merge_form,
                $self->_merge_form_arguments($c, @entities)
            );
            if ($self->_validate_merge($c, $form, $merger)) {
                $self->_merge_submit($c, $form, \@entities);
            }
        });
    };

    method _validate_merge => sub {
        my ($self, $c, $form) = @_;
        return $form->submitted_and_valid($c->req->params);
    };

    method _merge_submit => sub {
        my ($self, $c, $form, $entities) = @_;

        my %entity_gid = map { $_->gid => $_ } @$entities;

        my $new_gid = $form->field('target')->value or die 'Couldnt figure out new_gid';
        my $new = $entity_gid{$new_gid};
        my @old_gids = grep { $_ ne $new_gid } @{ $form->field('merging')->value };

        log_assertion { @old_gids >= 1 } 'Got at least 1 entity to merge';

        my $edit = $c->model('NES::Edit')->open;
        $c->model($self->{model})->merge(
            $edit, $c->user,
            source => [ map { $entity_gid{$_} } @old_gids ],
            target => $new
        );

        $c->session->{merger} = undef;
        $c->response->redirect(
            $c->uri_for_action($self->action_for('show'), [ $new->gid ]));
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

