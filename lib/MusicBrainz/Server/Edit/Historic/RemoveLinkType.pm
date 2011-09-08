package MusicBrainz::Server::Edit::Historic::RemoveLinkType;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_LINK_TYPE );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_name     { l('Remove link type') }
sub edit_type     { $EDIT_HISTORIC_REMOVE_LINK_TYPE }
sub historic_type { 38 }
sub ngs_class     { 'MusicBrainz::Server::Edit::Relationship::RemoveLinkType' }

sub do_upgrade
{
    my $self = shift;

    my @attributes = split / /, $self->new_value->{attribute} || '';

    my %types = (
        album => 'release',
        track => 'recording',
    );

    return {
        types               => [ map { $types{$_} || $_ } split /-/, $self->new_value->{types} ],
        description         => $self->new_value->{old_description},
        link_phrase         => $self->new_value->{old_linkphrase},
        reverse_link_phrase => $self->new_value->{old_rlinkphrase},
        name                => $self->new_value->{old_name},
        attributes          => [
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
}

1;
