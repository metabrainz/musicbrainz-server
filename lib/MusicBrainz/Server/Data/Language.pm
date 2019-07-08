package MusicBrainz::Server::Data::Language;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Language;

use MusicBrainz::Server::Data::Utils qw( load_subobjects hash_to_row );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll' => { order_by => [ 'name'] };
with 'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _type { 'language' }

sub _table
{
    return 'language';
}

sub _columns
{
    return 'id, iso_code_3, iso_code_2t, iso_code_2b, ' .
           'iso_code_1, name, frequency';
}

sub _column_mapping {
    return {
        id              => 'id',
        name            => 'name',
        iso_code_1      => 'iso_code_1',
        iso_code_2b     => 'iso_code_2b',
        iso_code_2t     => 'iso_code_2t',
        iso_code_3      => 'iso_code_3',
        frequency       => 'frequency',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Language';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'language', @objs);
}

sub load_for_works {
    my ($self, @objs) = @_;

    @objs = grep { defined $_ } @objs;

    $self->c->model('Work')->language->load_for(@objs);

    load_subobjects($self, 'language', map { $_->all_languages } @objs);

    for my $work (@objs) {
        for my $wl ($work->all_languages) {
            if ($wl->language && $wl->language->iso_code_3 eq "zxx") {
                $wl->language->name(l("[No lyrics]"));
            }
        }
    }

    return;
}

sub find_by_code
{
    my ($self, $code) = @_;
    return $self->_get_by_key('iso_code_3' => $code, transform => 'lower');
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM release WHERE language = ? UNION SELECT 1 FROM work WHERE language = ? UNION SELECT 1 FROM editor_language WHERE language = ? LIMIT 1',
        $id, $id, $id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
