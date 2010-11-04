package MusicBrainz::Server::Edit::Historic::AddLinkType;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name { 'Add relationship type' }
sub edit_type { 36 }
sub ngs_class { 'MusicBrainz::Server::Edit::Relationship::AddLinkType' }

sub do_upgrade
{
    my ($self) = @_;

    my @attributes = split / /, $self->new_value->{attribute};

    my %types = (
        track => 'recording',
        album => 'release',
    );

    my $data = {
        types               => [ map { $types{$_} || $_ } split /-/, $self->new_value->{types} ],
        name                => $self->new_value->{name},
        parent              => $self->new_value->{parent},
        gid                 => $self->new_value->{gid},
        link_phrase         => $self->new_value->{linkphrase},
        reverse_link_phrase => $self->new_value->{rlinkphrase},
        description         => $self->new_value->{description},
        attributes => [
            map {
                my ($name, $min_max) = split /=/, $_;
                my ($min, $max) = split /-/, $min_max;
                +{
                    name => $name,
                    min  => $min || 0,
                    max  => $max || 0
                }
            } @attributes
        ]
    };

    $data->{short_link_phrase} = $self->new_value->{shortlinkphrase}
        if exists $self->new_value->{shortlinkphrase};

    $data->{priority} = $self->new_value->{priority}
        if exists $self->new_value->{priority};

    $data->{child_order} = $self->new_value->{childorder}
        if exists $self->new_value->{childorder};

    return $data;
};

1;
