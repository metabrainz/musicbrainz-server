package MusicBrainz::Server::NES::Controller::Utils;
use strict;
use warnings;

use Scalar::Util qw( blessed );
use Sub::Exporter -setup => {
    exports => [qw( create_edit create_update run_edit_form run_update_form )]
};

sub run_edit_form {
    my ($c, $form, %opts) = @_;

    return $c->model('MB')->with_nes_transaction(sub {
        my $values = $form->values;
        my $edit = $c->model('NES::Edit')->open;

        my $work = $opts{on_post}->($values, $edit);

        if ($values->{edit_note}) {
            $c->model('EditNote')->add_note(
                $edit->id,
                {
                    editor_id => $c->user->id,
                    text => $values->{edit_note}
                }
            );
        }

        # NES:
        # my $privs = $c->user->privileges;
        # if ($c->user->is_auto_editor &&
        #     $form->field('as_auto_editor') &&
        #     !$form->field('as_auto_editor')->value) {
        # }

        return $work;
    });
}

sub run_update_form {
    my ($model, $c, $form, %opts) = @_;

    run_edit_form(
        $c, $form,
        on_post => sub {
            my ($values, $edit) = @_;

            my $revision = $c->model( $model )->get_revision(
                $values->{revision_id});

            $c->model( $model )->update(
                $edit, $c->user, $revision,
                $opts{build_tree}->($values, $revision)
            );

            return $revision
        }
    );
}

sub _run_form {
    my ($controller, $c, %opts) = @_;

    my $form = $opts{form};
    $form = do {
        my %args = (
            ctx => $c,
        );

        $args{init_object} = $opts{subject}
            if defined $opts{subject};

        $c->form(form => $form, %args);
    } unless blessed($form);

    if ($c->form_posted && $form->submitted_and_valid($c->req->body_params)) {
        my $work = $opts{callback}->($form);

        $c->response->redirect(
            $c->uri_for_action($controller->action_for('show'), [ $work->gid ]));
    }
    elsif (!$c->form_posted && %{ $c->req->query_params }) {
        $form->process( params => $c->req->query_params );
        $form->clear_errors;
    }
}

sub create_edit {
    my ($controller, $c, %opts) = @_;
    _run_form(
        $controller, $c,
        %opts,
        callback => sub {
            my $form = shift;
            run_edit_form($c, $form, %opts);
        }
    );
}

sub create_update {
    my ($controller, $c, %opts) = @_;
    _run_form(
        $controller, $c,
        %opts,
        callback => sub {
            my $form = shift;
            run_update_form($controller->{model}, $c, $form, %opts);
        }
    );
}

1;
