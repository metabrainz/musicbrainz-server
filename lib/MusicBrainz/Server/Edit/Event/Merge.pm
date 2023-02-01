package MusicBrainz::Server::Edit::Event::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_EVENT_MERGE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Event';

sub edit_type { $EDIT_EVENT_MERGE }
sub edit_name { N_l('Merge events') }
sub event_ids { @{ shift->_entity_ids } }

sub _merge_model { 'Event' }

sub foreign_keys
{
    my $self = shift;
    return {
        Event => {
            map {
                $_ => [ 'EventType' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    my @events = grep defined, map { $loaded->{Event}{$_} } $self->event_ids;
    $self->c->model('Event')->load_related_info(@events);
    $self->c->model('Event')->load_areas(@events);
};

sub edit_template { 'MergeEvents' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
