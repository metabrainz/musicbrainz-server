package MusicBrainz::Server::Data::EditorLanguage;

use Moose;
use namespace::autoclean;
use List::UtilsBy qw( rev_nsort_by uniq_by );
use MusicBrainz::Server::Entity::EditorLanguage;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    query_to_list
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'editor_language JOIN language ON language.id = editor_language.language';
}

sub _columns
{
    return 'language.*, editor, fluency, language AS language_id';
}

sub _new_from_row {
    my ($self, $row) = @_;

    return MusicBrainz::Server::Entity::EditorLanguage->new(
        editor_id => $row->{editor},
        fluency => $row->{fluency},
        language => $self->c->model('Language')->_new_from_row($row),
        language_id => $row->{language_id}
    );
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditorLanguage';
}

sub load_for_editor {
    my ($self, $editor) = @_;

    my @languages = query_to_list(
        $self->sql, sub { $self->_new_from_row(@_) },
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table .
        ' WHERE editor = ?' .
        ' ORDER BY musicbrainz_collate(language.name)',  $editor->id
    );

    $editor->add_language($_) for @languages;
}

sub set_languages {
    my ($self, $editor_id, $languages) = @_;

    my %fluency_order = (
        'basic' => 1,
        'intermediate' => 2,
        'advanced' => 3,
        'native' => 4,
    );

    # The $languages map might have a language multiple times (ie, English-basic
    # and English-advanced), which does make sense and violates the unique
    # constraint in the database.
    #
    # For each language, we find all possible fluencys a user has specified, and
    # take the highest fluency, where the ordering of fluencys is given by the
    # %fluency_order mapping.

    my %language_fluencys;
    for my $language (@$languages) {
        $language_fluencys{$language->{language_id}} ||= [];
        push @{ $language_fluencys{$language->{language_id}} }, $language->{fluency}
    }

    for my $language_id (keys %language_fluencys) {
        my @fluencys = @{ $language_fluencys{$language_id} };
        ($language_fluencys{ $language_id }) = rev_nsort_by { $fluency_order{$_} } @fluencys;
    }

    $self->c->sql->begin;
    $self->c->sql->do('DELETE FROM editor_language WHERE editor = ?', $editor_id);
    $self->c->sql->do(
        'DELETE FROM editor_language WHERE editor = ?', $editor_id
    );
    $self->c->sql->do(
        'INSERT INTO editor_language (editor, language, fluency)
         VALUES ' . join(', ', ('(?, ?, ?)') x scalar(keys %language_fluencys)),
        map { $editor_id, $_, $language_fluencys{$_} } keys %language_fluencys
    );
    $self->c->sql->commit;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

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
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
