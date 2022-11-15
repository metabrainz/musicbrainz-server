package t::Mechanize;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::WWW::Mechanize;

has mech => (
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => 'make_mech',
    clearer => '_clear_mech'
);

before run_test => sub {
    shift->_clear_mech;
};

sub make_mech {
    MusicBrainz::WWW::Mechanize->new( catalyst_app => 'MusicBrainz::Server', quiet => 1 )
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
