package MusicBrainz::Server::Data::Label;

use Moose;
use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Data::Utils qw( partial_date_from_row load_subobjects );

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::AnnotationRole';
with 'MusicBrainz::Server::Data::AliasRole';

sub _annotation_type
{
    return 'label';
}

sub _alias_type
{
    return 'label';
}

sub _table
{
    return 'label ' .
           'JOIN label_name name ON label.name=name.id ' .
           'JOIN label_name sortname ON label.sortname=sortname.id';
}

sub _columns
{
    return 'label.id, gid, name.name, sortname.name AS sortname, ' .
           'type, country, editpending, labelcode, ' .
           'begindate_year, begindate_month, begindate_day, ' .
           'enddate_year, enddate_month, enddate_day, comment';
}

sub _id_column
{
    return 'label.id';
}

sub _gid_redirect_table
{
    return 'label_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        sort_name => 'sortname',
        type_id => 'type',
        country_id => 'country',
        label_code => 'labelcode',
        begin_date => sub { partial_date_from_row(shift, shift() . 'begindate_') },
        end_date => sub { partial_date_from_row(shift, shift() . 'enddate_') },
        edits_pending => 'editpending',
        comment => 'comment',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Label';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'label', @objs);
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
