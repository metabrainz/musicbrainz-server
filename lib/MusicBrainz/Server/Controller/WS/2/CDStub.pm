package MusicBrainz::Server::Controller::WS::2::CDStub;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use MusicBrainz::Server::WebService::XML::XPath;
use Readonly;
use Try::Tiny;

my $ws_defs = Data::OptList::mkopt([
     cdstub => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     cdstub => {
         method => 'POST'
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub cdstub_search : Chained('root') PathPart('cdstub') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('cdstub_submit') if $c->req->method eq 'POST';
    $self->_search ($c, 'cdstub');
}

sub cdstub_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    my $client = $c->req->query_params->{client}
        or $self->_error($c, 'You must provide information about your client, by the client query parameter');
    $self->bad_req($c, 'Invalid argument "client"') if ref($client);

    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );
    for my $release ($xp->find('/mb:metadata/mb:release')->get_nodelist)
    {
        my %data = (
            title  => $xp->find('mb:title', $release)->string_value,
            discid => $xp->find('mb:discid', $release)->string_value,
            toc    => $xp->find('mb:toc', $release)->string_value,
        );

        if (my $barcode = $xp->find('mb:barcode', $release)->string_value) {
            $data{barcode} = $barcode;
        }

        if (my $comment = $xp->find('mb:comment', $release)->string_value) {
            $data{comment} = $comment;
        }

        my $has_track_artists;
        my @tracks = map {
            my %track = (
                title => $xp->find('mb:title', $_)->string_value || undef
            );
            if (my $artist = $xp->find('mb:artist', $_)->string_value) {
                $track{artist} = $artist;
                $has_track_artists = 1;
            }
            \%track;
        } $xp->find('mb:track-list/mb:track', $release)->get_nodelist;

        $data{artist} = $xp->find('mb:artist', $release)->string_value
            unless $has_track_artists;

        try {
            $c->model('CDStub')->insert({
                %data,
                tracks => \@tracks
            });
        }
        catch {
            if (ref($_)) {
                $self->_error($c, $_->message)
            }
            else {
                die $_;
            }

            $c->detach;
        }
    }

    $c->detach('success');
}

__PACKAGE__->meta->make_immutable;
1;
