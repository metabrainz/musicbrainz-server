package MusicBrainz::Server::Controller::WS::2::Role::Editable;
use MooseX::Role::Parameterized -metaclass => 'MusicBrainz::Server::Controller::Role::Meta::Parameterizable';

use Carp;
use JSON::Any;
use Try::Tiny;

parameter 'model' => (
    isa => 'Str',
    required => 1
);

parameter 'edit_type' => (
    isa => 'Int',
    required => 1
);

role
{
    my $params = shift;
    my %extra = @_;

    my $model = $params->model;
    my $edit_type = $params->edit_type;

    method entity_edit => sub
    {
        my ($self, $c) = @_;

        my $entity = $c->stash->{entity};

        my $json = JSON::Any->new;
        my $fh = $c->request->body;
        my $body = $json->decode (do { local $/ = undef; <$fh> });

        my $result = $c->model($model)->validate ($body);
        if (!$result->valid) {
            $c->response->status(400); # hm, is there a more specific code which is appropriate here?
            $c->response->body($c->stash->{serializer}->serialize_validation_errors ($result));
            $c->response->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
            $c->detach;
        }

        my %options = $c->model($model)->edit_mapping ($result->clean);

        my $edit;
        try {
            $edit = $c->model('Edit')->create(
                edit_type => $edit_type,
                editor_id => $c->user->id,
                privileges => $c->user->privileges,
                to_edit => $entity,
                %options
                );
        }
        catch {
            if (ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges')
            {
                $c->detach('no_changes');
            }
            else
            {
                use Data::Dumper;
                croak "The edit could not be created.\n" .
                    "Submitted document: " . Dumper($body) . "\n" .
                    "Exception (".ref($_)."):" . Dumper($_);
            }
        };

        $c->response->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->response->body ("");
        $c->response->redirect($c->uri_for_action('/edit/show', [ $edit->id ]), 201);
    };

    method no_changes => sub
    {
        my ($self, $c) = @_;

        $c->response->status(409);
        $c->response->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->response->body(
            $c->stash->{serializer}->output_error(
                "The document you submitted is identical to the entity in the database."));
        $c->detach;
    };
};

1;
