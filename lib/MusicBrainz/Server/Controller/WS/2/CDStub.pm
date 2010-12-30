package MusicBrainz::Server::Controller::WS::2::CDStub;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use Readonly;
use Try::Tiny;

my $ws_defs = Data::OptList::mkopt([
     cdstub => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(limit offset) ],
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

    my $client = $c->req->query_params->{client}
        or $self->_error($c, 'You must provide information about your client, by the client query parameter');

    my $xp = XML::XPath->new( xml => $c->request->body );
    for my $release ($xp->find('/metadata/release')->get_nodelist)
    {
        my %data = (
            title => $release->find('title')->string_value,
            discid => $release->find('discid')->string_value,
            toc => $release->find('toc')->string_value,
        );

        if (my $barcode = $release->find('barcode')->string_value) {
            $data{barcode} = $barcode;
        }

        if (my $comment = $release->find('comment')->string_value) {
            $data{comment} = $comment;
        }

        my $has_track_artists;
        my @tracks = map {
            my %track = (
                title => $_->find('title')->string_value || undef
            );
            if (my $artist = $_->find('artist')->string_value) {
                $track{artist} = $artist;
                $has_track_artists = 1;
            }
            \%track;
        } $release->find('track-list/track')->get_nodelist;

        $data{artist} = $release->find('artist')->string_value
            unless $has_track_artists;

        try {
            use Devel::Dwarn;
            Dwarn { %data, tracks => \@tracks };
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
