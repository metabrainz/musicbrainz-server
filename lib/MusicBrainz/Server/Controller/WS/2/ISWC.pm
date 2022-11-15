package MusicBrainz::Server::Controller::WS::2::ISWC;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Validation qw( is_valid_iswc );

my $ws_defs = Data::OptList::mkopt([
     iswc => {
                         method   => 'GET',
                         inc      => [ qw(artists aliases artist-credits
                                          _relations tags user-tags ratings user-ratings) ],
                         optional => [ qw( fmt ) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub iswc : Chained('root') PathPart('iswc') Args(1)
{
    my ($self, $c, $iswc) = @_;

    if (!is_valid_iswc($iswc))
    {
        $c->stash->{error} = 'Invalid iswc.';
        $c->detach('bad_req');
    }

    my @works = $c->model('Work')->find_by_iswc($iswc);
    unless (@works) {
        $c->detach('not_found');
    }

    my $stash = WebServiceStash->new;

    $c->controller('WS::2::Work')->work_toplevel($c, $stash, \@works);

    my $work_list = $self->make_list(\@works);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('work-list', $work_list, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
