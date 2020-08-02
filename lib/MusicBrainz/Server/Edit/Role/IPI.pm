package MusicBrainz::Server::Edit::Role::IPI;
use 5.10.0;
use Moose::Role;
use utf8;

use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT );
use MusicBrainz::Server::Data::Utils qw( localized_note type_to_model );
use MusicBrainz::Server::Translation qw( N_l );
use Set::Scalar;

has 'reused_ipis' => (
    isa => 'HashRef',
    is  => 'rw'
);

with 'MusicBrainz::Server::Edit::Role::ValueSet' => {
    prop_name => 'ipi_codes',
    get_current => sub {
        my $self = shift;
        $self->c->model($self->_edit_model)
            ->ipi->find_by_entity_id($self->entity_id);
    },
    extract_value => sub { shift->ipi }
};

after initialize => sub {
    my ($self, %opts) = @_;

    my $old_ipis = $self->data->{old}{ipi_codes} // [];
    my $new_ipis = $self->data->{new}{ipi_codes} // [];
    my $added_ipis_set = Set::Scalar->new(@$new_ipis) - Set::Scalar->new(@$old_ipis);
    my @added_ipis = $added_ipis_set->members;
    $self->reused_ipis($self->c->model($self->_edit_model)->find_reused_ipis(@added_ipis));
};

after post_insert => sub {
    my $self = shift;

    for my $ipi (keys %{ $self->reused_ipis }) {
        my $artist_dupe_count = $self->reused_ipis->{$ipi}->{artist};
        my $label_dupe_count = $self->reused_ipis->{$ipi}->{label};
        my $edit_note;

        if ($artist_dupe_count) {
            $edit_note = localized_note(
                'The IPI {ipi} is already in use on {artist_count} artist. Please check {artist_search|all uses of this IPI}.',
                function => 'ln',
                args => ['The IPI {ipi} is already in use on {artist_count} artists. Please check {artist_search|all uses of this IPI}.', $artist_dupe_count],
                vars => {
                    artist_count => $artist_dupe_count,
                    artist_search => "/search?query=ipi%3A$ipi&advanced=1&type=artist",
                    ipi => $ipi,
                }
            );

            $self->c->model('EditNote')->add_note(
                $self->{id},
                {
                    editor_id => $EDITOR_MODBOT,
                    text => $edit_note
                }
            );            
        }

        if ($label_dupe_count) {
            $edit_note = localized_note(
                'The IPI {ipi} is already in use on {label_count} label. Please check {label_search|all uses of this IPI}.',
                function => 'ln',
                args => ['The IPI {ipi} is already in use on {label_count} labels. Please check {label_search|all uses of this IPI}.', $label_dupe_count],
                vars => {
                    ipi => $ipi,
                    label_search => "/search?query=ipi%3A$ipi&advanced=1&type=label",
                    label_count => $label_dupe_count,
                }
            );

            $self->c->model('EditNote')->add_note(
                $self->{id},
                {
                    editor_id => $EDITOR_MODBOT,
                    text => $edit_note
                }
            );
        }
    }
};

no Moose;
1;

=head1 LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut
