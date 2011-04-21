package MusicBrainz::Server::Controller::ReleaseEditor::Import;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config( namespace => 'release/import' );

__PACKAGE__->config(
    namespace => 'release_editor/import'
);

sub freedb : Path('/release/import/freedb') RequireAuth {
    my ($self, $c) = @_;
    my $import_form = $c->form( freedb => 'Search::FreeDB' );

    if ($import_form->submitted_and_valid($c->req->query_params)) {
        $c->response->redirect(
            $c->uri_for_action('/freedb/show', [
                $import_form->field('category')->value,
                $import_form->field('discid')->value
            ])
        );
    }
}

1;
