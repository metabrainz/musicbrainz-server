package MusicBrainz::Server::Edit::Series::Merge;
use Moose;
use MusicBrainz::Server::Constants qw( $EDIT_SERIES_MERGE );
use MusicBrainz::Server::Translation qw ( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Role::MergeSubscription';
with 'MusicBrainz::Server::Edit::Series';

sub edit_type { $EDIT_SERIES_MERGE }
sub edit_name { N_l('Merge series') }

sub _merge_model { 'Series' }
sub subscription_model { shift->c->model('Series')->subscription }

sub series_ids { @{ shift->_entity_ids } }

sub foreign_keys {
    my $self = shift;
    return {
        Series => {
            map {
                $_ => ['SeriesType', 'SeriesOrderingType']
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

sub edit_template { 'MergeSeries' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
