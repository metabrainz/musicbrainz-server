package MusicBrainz::Server::Edit::Historic::MergeReleaseGroups;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub edit_name { l('Merge artists') }
sub edit_type { 67 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Merge' }

sub related_entities {
    my $self = shift;
    return {
        artist => [ $self->artist_id ],
        release_group => [
            $self->data->{new_entity}{id},
            map { $_->{id} } @{ $self->data->{old_entities} }
        ]
    }
}

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
