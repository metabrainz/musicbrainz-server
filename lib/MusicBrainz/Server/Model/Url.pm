package MusicBrainz::Server::Model::Url;

use strict;
use warnings;

use base 'Catalyst::Model';

use Carp;
use MusicBrainz::Server::Facade::Url;
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::URL;

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

sub load
{
    my ($self, $id) = @_;

    my $url = MusicBrainz::Server::URL->new($self->{_dbh});

    if (MusicBrainz::Server::Validation::IsGUID($id))
    {
        $url->SetMBId($id);
    }
    else
    {
        if (MusicBrainz::Server::Validation::IsNonNegInteger($id))
        {
            $url->SetId($id);
        }
        else
        {
            croak "$id is not a valid GUID or database row ID";
        }
    }

    $url->LoadFromId
        or croak "Could not load URL at $id";

    return MusicBrainz::Server::Facade::Url->new_from_url($url);
}

1;
