package MusicBrainz::Server::Edit::ReleaseGroup::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_MERGE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::ReleaseGroup::RelatedEntities' => {
    -excludes => 'release_group_ids',
};
with 'MusicBrainz::Server::Edit::ReleaseGroup';

sub edit_name { N_l('Merge release groups') }
sub edit_type { $EDIT_RELEASEGROUP_MERGE }
sub _merge_model { 'ReleaseGroup' }
sub release_group_ids { @{ shift->_entity_ids } }

override 'foreign_keys' => sub {
    my $self = shift;
    my $data = super();

    $data->{ReleaseGroup} = {
        map { $_ => [ 'ArtistCredit', 'ReleaseGroupType', 'ReleaseGroupMeta' ] }
            $self->release_group_ids
    };

    return $data;
};

sub edit_template_react { 'MergeReleaseGroups' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;
