package MusicBrainz::Server::Data::Language;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::Language;

use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache',
     'MusicBrainz::Server::Data::Role::SelectAll' => {
        order_by => ['name'],
     },
     'MusicBrainz::Server::Data::Role::InsertUpdateDelete';

sub _type { 'language' }

sub _table
{
    return 'language';
}

sub _build_columns
{
    return join q(, ), qw(
        id
        iso_code_3
        iso_code_2t
        iso_code_2b
        iso_code_1
        name
        frequency
    );
}

has '_columns' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    builder => '_build_columns',
);

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

    @objs = grep { defined $_ && !scalar($_->all_languages) } @objs;

    $self->c->model('Work')->language->load_for(@objs);

    load_subobjects($self, 'language', map { $_->all_languages } @objs);

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
        'SELECT 1 FROM release WHERE language = ? UNION SELECT 1 FROM work_language WHERE language = ? UNION SELECT 1 FROM editor_language WHERE language = ? LIMIT 1',
        $id, $id, $id);
}

sub has_children { 0 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
