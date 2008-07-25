package MusicBrainz::Server::Model::CdToc;

use strict;
use warnings;

use base 'Catalyst::Model';

use MusicBrainz::Server::Facade::CdToc;

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { dbh => $c->mb->{DBH} }, ref $self;
}

sub load_for_release
{
    my ($self, $release) = @_;

    my $disc_ids = $release->get_release->GetDiscIDs;

    [ map {
        MusicBrainz::Server::Facade::CdToc->new_from_cdtoc($_->GetCDTOC)
    } @$disc_ids ];
}

1;
