package MusicBrainz::Server::Controller::RelationshipEditor::CreateWorks;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use JSON;
use MusicBrainz::Server::Constants qw( $EDIT_WORK_CREATE );

has works => (
    is => 'rw',
    isa => 'HashRef',
);

sub create_works : Path("/create-works") Edit RequireAuth
{
    my ($self, $c) = @_;

    $self->works({});
    $c->res->content_type('application/json; charset=utf-8');
    my $json = JSON::Any->new;
    my $form = $c->form(form => 'RelationshipEditor::CreateWorks');

    if ($c->form_posted && $form->submitted_and_valid($c->req->body_parameters)) {
        $self->works->{works} = [];

        for my $field ($form->field('works')->fields) {
            $self->create_new_work($c, $form, $field);
        }
        $c->res->body($json->encode($self->works));
    } else {
        $c->res->status(400);
        $c->res->body($json->encode({error => 'Invalid submission.'}));
    }
}

sub create_new_work {
    my ($self, $c, $form, $field) = @_;

    my $edit;
    $c->model('MB')->with_transaction(sub {
        $edit = $self->_insert_edit(
            $c, $form,
            edit_type => $EDIT_WORK_CREATE,
            name => $field->field('name')->value,
            comment => $field->field('comment')->value,
            type_id => $field->field('type_id')->value,
            language_id => $field->field('language_id')->value
        );
    });

    my $work = $c->model('Work')->get_by_id($edit->entity_id);

    push @{ $self->works->{works} }, {
        name => $work->name,
        id   => $work->id,
        gid  => $work->gid,
        $work->comment ? ( comment => $work->comment ) : (),
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
