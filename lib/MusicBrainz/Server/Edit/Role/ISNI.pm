package MusicBrainz::Server::Edit::Role::ISNI;
use 5.10.0;
use Moose::Role;
use utf8;

use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT );
use MusicBrainz::Server::Data::Utils qw( localized_note type_to_model );
use MusicBrainz::Server::Translation qw( N_l );
use Set::Scalar;

has 'reused_isnis' => (
    isa => 'HashRef',
    is  => 'rw'
);

with 'MusicBrainz::Server::Edit::Role::ValueSet' => {
    prop_name => 'isni_codes',
    get_current => sub {
        my $self = shift;
        $self->c->model($self->_edit_model)
            ->isni->find_by_entity_id($self->entity_id);
    },
    extract_value => sub { shift->isni }
};

after initialize => sub {
    my ($self, %opts) = @_;

    my $old_isnis = $self->data->{old}{isni_codes} // [];
    my $new_isnis = $self->data->{new}{isni_codes} // [];
    my $added_isnis_set = Set::Scalar->new(@$new_isnis) - Set::Scalar->new(@$old_isnis);
    my @added_isnis = $added_isnis_set->members;
    $self->reused_isnis($self->c->model($self->_edit_model)->find_reused_isnis(@added_isnis));
};

after post_insert => sub {
    my $self = shift;

    for my $isni (keys %{ $self->reused_isnis }) {
        my $artist_dupe_count = $self->reused_isnis->{$isni}->{artist};
        my $label_dupe_count = $self->reused_isnis->{$isni}->{label};
        my $edit_note;

        if ($artist_dupe_count) {
            $edit_note = localized_note(
                'The ISNI {isni} is already in use on {artist_count} artist. Please check {artist_search|all uses of this ISNI}.',
                function => 'ln',
                args => ['The ISNI {isni} is already in use on {artist_count} artists. Please check {artist_search|all uses of this ISNI}.', $artist_dupe_count],
                vars => {
                    artist_count => $artist_dupe_count,
                    artist_search => "/search?query=isni%3A$isni&advanced=1&type=artist",
                    isni => $isni,
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
                'The ISNI {isni} is already in use on {label_count} label. Please check {label_search|all uses of this ISNI}.',
                function => 'ln',
                args => ['The ISNI {isni} is already in use on {label_count} labels. Please check {label_search|all uses of this ISNI}.', $label_dupe_count],
                vars => {
                    isni => $isni,
                    label_search => "/search?query=isni%3A$isni&advanced=1&type=label",
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
