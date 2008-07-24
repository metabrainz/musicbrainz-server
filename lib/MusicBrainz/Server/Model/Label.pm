package MusicBrainz::Server::Model::Label;

use strict;
use warnings;

use base 'Catalyst::Model';

use Carp;
use MusicBrainz::Server::Facade::Label;

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

sub load
{
    my ($self, $id) = @_;

    my $label = MusicBrainz::Server::Label->new($self->{_dbh});

    if (MusicBrainz::Server::Validation::IsGUID($id))
    {
        $label->SetMBId($id);
    }
    else
    {
        if (MusicBrainz::Server::Validation::IsNonNegInteger($id))
        {
            $label->SetId($id);
        }
        else
        {
            croak "$id is not a valid MBID or row ID";
        }
    }

    $label->LoadFromId
        or croak "Could not load label with id $id";

    MusicBrainz::Server::Facade::Label->new_from_label($label);
}

1;
