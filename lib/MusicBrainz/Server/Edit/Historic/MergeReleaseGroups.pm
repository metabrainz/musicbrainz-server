package MusicBrainz::Server::Edit::Historic::MergeReleaseGroups;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

sub edit_type { 67 }
sub edit_name { 'Merge artists' }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Merge' }

sub old_entities
{
    my $self = shift;

    my @ents;
    for (my $i = 1; 1; $i++) {
        my $id   = $self->new_value->{"ReleaseGroupId$i"} or last;
        my $name = $self->new_value->{"ReleaseGroupName$i"} or last;

        push @ents, { id => $id, name => $name };
    }

    return [ @ents ];
}

sub do_upgrade
{
    my $self = shift;
    return {
        new_entity   => {
            id   => $self->new_value->{ReleaseGroupId0},
            name => $self->new_value->{ReleaseGroupName0},
        },
        old_entities => $self->old_entities,
    };
}

1;
