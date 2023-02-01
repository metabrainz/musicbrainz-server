package MusicBrainz::Server::Edit::Historic::Base;

use Moose;
use Moose::Exporter;
use Class::Load qw( load_class );

sub USE_MOOSE { 1 }

my ($import) = Moose::Exporter->build_import_methods( also => 'Moose' );
sub import {
    my $class = caller(0);
    if (USE_MOOSE) {
        goto $import;
    }
    else {
        no strict 'refs';
        load_class('MusicBrainz::Server::Edit::Historic::Fast');
        push @{"$class\::ISA"}, 'MusicBrainz::Server::Edit::Historic::Fast';
    }
}

sub init_meta {
    my $class = shift;
    return Moose->init_meta( @_, base_class => 'MusicBrainz::Server::Edit::Historic' );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
