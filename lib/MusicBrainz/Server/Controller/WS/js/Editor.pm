package MusicBrainz::Server::Controller::WS::js::Editor;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

use Text::Trim 'trim';

my $ws_defs = Data::OptList::mkopt([
    'editor' => {
        method   => 'GET',
        required => [ qw(q) ],
        optional => [ qw(direct limit page timestamp) ]
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub search : Chained('root') PathPart('editor')
{
    my ($self, $c) = @_;

    my $query = trim $c->stash->{args}->{q};
    my $limit = $c->stash->{args}->{limit} || 10;
    my $page = $c->stash->{args}->{page} || 1;

    my $offset = ($page - 1) * $limit;  # page is not zero based.
    my ($editors, $hits) = $c->model('Search')->search('editor', $query, $limit, $offset);

    my $pager = Data::Page->new();
    $pager->entries_per_page($limit);
    $pager->current_page($page);
    $pager->total_entries($hits);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize(
        'autocomplete_editor', [ map { $_->entity } @$editors ], $pager));
}

1;

