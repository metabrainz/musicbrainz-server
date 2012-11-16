package t::Mechanize;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::WWW::Mechanize;

has mech => (
    is => 'ro',
    required => 1,
    lazy => 1,
    default => sub {
        MusicBrainz::WWW::Mechanize->new( catalyst_app => 'MusicBrainz::Server', quiet => 1 );
    },
    clearer => '_clear_mech'
);

before run_test => sub {
    shift->_clear_mech;
};

1;
