package MusicBrainz::Server::Controller::Partners;
use Moose;
BEGIN { extends 'MusicBrainz::Server::Controller' }

sub amazon : Local Args(2)
{
    my ($self, $c, $store, $asin) = @_;

    my $ass_id = DBDefs->AWS_ASSOCIATE_ID($store)
    or die "Invalid store";

    $c->response->redirect(
    sprintf("http://%s/exec/obidos/ASIN/%s/%s?v=glance&s=music",
        $store, $asin, $ass_id));
}

1;
