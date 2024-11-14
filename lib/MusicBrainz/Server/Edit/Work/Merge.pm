package MusicBrainz::Server::Edit::Work::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_MERGE );
use MusicBrainz::Server::Translation qw( N_lp );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities',
     'MusicBrainz::Server::Edit::Work';

sub edit_type { $EDIT_WORK_MERGE }
sub edit_name { N_lp('Merge works', 'edit type') }
sub work_ids { @{ shift->_entity_ids } }

sub _merge_model { 'Work' }

sub foreign_keys
{
    my $self = shift;
    return {
        Work => {
            map {
                $_ => [ 'WorkType', 'Language' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            ),
        },
    };
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    my @works = grep { defined } map { $loaded->{Work}{$_} } $self->work_ids;
    $self->c->model('Work')->load_writers(@works);
    $self->c->model('Work')->load_recording_artists(@works);
    $self->c->model('WorkAttribute')->load_for_works(@works);
    $self->c->model('ISWC')->load_for_works(grep { $_->all_iswcs == 0 } @works);
    $self->c->model('Language')->load_for_works(@works);
};

sub edit_template { 'MergeWorks' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
