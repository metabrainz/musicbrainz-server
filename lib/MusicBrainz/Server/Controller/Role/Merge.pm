package MusicBrainz::Server::Controller::Role::Merge;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

use MusicBrainz::Server::Translation qw ( l ln );

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

parameter 'form' => (
    isa => 'Str',
    default => 'Merge',
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

        $c->session->{merger} ||= MusicBrainz::Server::MergeQueue->new(
            type => $self->{model},
        );

        my $merger = $c->session->{merger};
        $merger->add_entities(@add);

        if ($merger->ready_to_merge) {
            $c->response->redirect(
                $c->uri_for_action(
                    $self->action_for('merge')));
        }
        else {
            $c->response->redirect(
                $c->uri_for_action(
                    $self->action_for('show'), [ $add[0] ]));
        }
    };

    method 'merge' => sub {
        my ($self, $c) = @_;
        $c->stash( template => $c->namespace . '/merge.tt' );

        my $merger = $c->session->{merger}
            or die 'No merge in process';

        die 'Not yet ready to merge'
            unless $merger->ready_to_merge;

        my @entities = values %{
            $c->model($merger->type)->get_by_ids($merger->all_entities)
        };

        my $form = $c->form(form => $params->form);
        if ($form->submitted_and_valid($c->req->params)) {
            my $new_id = $form->field('target')->value;
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
