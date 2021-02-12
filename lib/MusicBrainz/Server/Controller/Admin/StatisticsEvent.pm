package MusicBrainz::Server::Controller::Admin::StatisticsEvent;
use Moose;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub _form_to_hash {
    my ($self, $form) = @_;
    return map { $form->field($_)->name => $form->field($_)->value } $form->edit_field_names;
}

sub index : Path('/admin/statistics-events') Args(0) RequireAuth(account_admin) {
    my ($self, $c) = @_;

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/statistics-events/StatisticsEventIndex',
        component_props => {
            events => to_json_array($c->model('Statistics')->all_events),
        },
    );
}

sub create : Path('/admin/statistics-events/create') RequireAuth(account_admin) SecureForm {
    my ($self, $c) = @_;

    my $form = $c->form( form => 'Admin::StatisticsEvent' );

    if ($c->form_posted_and_valid($form)) {
        my %insert = $self->_form_to_hash($form);
        $c->model('MB')->with_transaction(sub {
            $c->model('StatisticsEvent')->insert(\%insert);
        });

        $c->response->redirect($c->uri_for('/admin/statistics-events'));
    }

    $c->stash(
        component_path => 'admin/statistics-events/CreateStatisticsEvent',
        component_props => {form => $form->TO_JSON},
        current_view => 'Node',
    );
}

sub edit : Path('/admin/statistics-events/edit') Args(1) RequireAuth(account_admin) SecureForm {
    my ($self, $c, $date) = @_;

    my $event = $c->model('StatisticsEvent')->get_by_date($date);

    my $form = $c->form( form => 'Admin::StatisticsEvent', init_object => $event);

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model('StatisticsEvent')->update($date, { map { $_->name => $_->value } $form->edit_fields });
        });

        $c->response->redirect($c->uri_for('/admin/statistics-events'));
        $c->detach;
    }

    $c->stash(
        component_path => 'admin/statistics-events/EditStatisticsEvent',
        component_props => {form => $form->TO_JSON},
        current_view => 'Node',
    );
}

sub delete : Path('/admin/statistics-events/delete') Args(1) RequireAuth(account_admin) SecureForm {
    my ($self, $c, $date) = @_;

    my $event = $c->model('StatisticsEvent')->get_by_date($date);

    if ($c->form_posted) {
        $c->model('MB')->with_transaction(sub {
            $c->model('StatisticsEvent')->delete($date);
        });

        $c->response->redirect($c->uri_for('/admin/statistics-events'));
    }

    $c->stash(
        component_path => 'admin/statistics-events/DeleteStatisticsEvent',
        component_props => {event => $event->TO_JSON},
        current_view => 'Node',
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
