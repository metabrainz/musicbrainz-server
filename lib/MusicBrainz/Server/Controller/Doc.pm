package MusicBrainz::Server::Controller::Doc;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use HTTP::Status qw( HTTP_MOVED_PERMANENTLY );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

sub show : Path('')
{
    my ($self, $c, @args) = @_;

    my $id = join '/', @args;
    $id =~ tr/ /_/;

    my $version = $c->model('WikiDocIndex')->get_page_version($id);
    my $page = $c->model('WikiDoc')->get_page($id, $version);

    if ($page && $page->canonical)
    {
        my ($path, $fragment) = split /\#/, $page->{canonical}, 2;
        $fragment = $fragment ? '#'.$fragment : '';

        $c->response->redirect($c->uri_for('/doc', $path).$fragment, HTTP_MOVED_PERMANENTLY);
        return;
    }

    if ($id =~ /^[^:]+:/i && $id !~ /^Category:/i) {
        $c->response->redirect(sprintf('http://%s/%s', DBDefs->WIKITRANS_SERVER, $id));
        $c->detach;
    }

    my %props = (
        id      => $id,
        page    => to_json_object($page),
    );

    if ($page) {
        $c->stash(
            component_path  => 'doc/DocPage',
            component_props => \%props,
            current_view    => 'Node',
        );
    }    else {
        $c->response->status(404);
        $c->stash(
            component_path  => 'doc/DocError',
            component_props => \%props,
            current_view    => 'Node',
        );
    }
}

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
