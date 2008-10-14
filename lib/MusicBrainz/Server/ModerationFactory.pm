package MusicBrainz::Server::ModerationFactory;

use strict;
use warnings;

use base 'Class::Factory';

use File::Find::Rule;
use UNIVERSAL::require;

my @moderations = File::Find::Rule->file->name('MOD_*.pm')->in(@INC);

my $next_id;

for my $mod (@moderations)
{
    $mod =~ s/\//::/g;
    $mod =~ s/\.pm$//;

    my $mod_name = $mod;
    $mod_name =~ s/.*::(.*)$/$1/;

    __PACKAGE__->register_factory_type($mod_name => $mod);
}

1;

my $test = MusicBrainz::Server::ModerationFactory->new('MOD_ADD_ARTIST');
