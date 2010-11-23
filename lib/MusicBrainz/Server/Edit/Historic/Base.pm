package MusicBrainz::Server::Edit::Historic::Base;

use strict;
use warnings;
use Moose::Exporter;
use Moose::Util qw( find_meta );

sub USE_MOOSE { 1 }

my ($import) = Moose::Exporter->build_import_methods( also => 'Moose' );
sub import {
    my $class = shift;
    if(USE_MOOSE) {
        goto $import;
    }
    else {
        no strict 'refs';
        push @{"$class\::ISA"}, 'MusicBrainz::Server::Edit::Historic::Fast';
    }
}

sub init_meta {
    my $class = shift;
    return Moose->init_meta( @_, base_class => 'MusicBrainz::Server::Edit::Historic' );
}

1;
