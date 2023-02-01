package MusicBrainz::Server::Edit::Instrument::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_MERGE );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Instrument';

sub edit_type { $EDIT_INSTRUMENT_MERGE }
sub edit_name { N_l('Merge instruments') }
sub instrument_ids { @{ shift->_entity_ids } }

sub _merge_model { 'Instrument' }

sub foreign_keys {
    my $self = shift;
    return {
        Instrument => {
            map {
                $_ => [ 'InstrumentType' ]
            } (
                $self->data->{new_entity}{id},
                map { $_->{id} } @{ $self->data->{old_entities} },
            )
        }
    }
}

before build_display_data => sub {
    my ($self, $loaded) = @_;

    my @instruments = grep defined, map { $loaded->{Instrument}{$_} } $self->instrument_ids;
    $self->c->model('InstrumentType')->load(@instruments);
};

sub edit_template { 'MergeInstruments' };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
