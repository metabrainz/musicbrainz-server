package MusicBrainz::Server::Controller::WS::js::Plurals;
use Moose;
use JSON;
use MusicBrainz::Server::Translation qw ( ln );
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::js' }

my $ws_defs = Data::OptList::mkopt([
    "plurals" => {
        method   => 'GET',
        required => [ qw(singular plural max) ],
    }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
     version => 'js',
     default_serialization_type => 'json',
};

sub translate : Chained('root') PathPart('plurals')
{
    my ($self, $c) = @_;

    my @strings;
    my $singular = $c->stash->{args}->{singular};
    my $plural = $c->stash->{args}->{plural};
    my $max = $c->stash->{args}->{max};

    for (my $i = 0; $i <= $max; $i++) {
        push @strings, ln($singular, $plural, $i, {n => $i});
    }

    my $json = JSON::Any->new;
    $c->res->body($json->encode({strings => \@strings}));
}

1;
