package MusicBrainz::Server::Data::Utils;

use base 'Exporter';

use Class::MOP;
use Data::Compare;
use List::MoreUtils qw( natatime zip );
use MusicBrainz::Server::Entity::PartialDate;
use OSSP::uuid;
use Sql;
use Readonly;
use Storable;

our @EXPORT_OK = qw(
    artist_credit_to_ref
    check_data
    copy_escape
    defined_hash
    hash_to_row
    add_partial_date_to_row
    remove_equal
    generate_gid
    insert_and_create
    generate_gid
    load_meta
    load_subobjects
    partial_date_from_row
    partial_date_to_hash
    placeholders
    query_to_list
    query_to_list_limited
    type_to_model
    model_to_type
    object_to_ids
    order_by
    check_in_use
    map_query
    ref_to_type
);

Readonly my %TYPE_TO_MODEL => (
    'annotation'    => 'Annotation',
    'artist'        => 'Artist',
    'cdstub'        => 'CDStub',
    'editor'        => 'Editor',
    'freedb'        => 'FreeDB',
    'label'         => 'Label',
    'recording'     => 'Recording',
    'release'       => 'Release',
    'release_group' => 'ReleaseGroup',
    'url'           => 'URL',
    'work'          => 'Work',
);

sub copy_escape {
    my $str = shift;
    $str =~ s/\n/\\n/g;
    $str =~ s/\t/\\t/g;
    $str =~ s/\r/\\r/g;
    $str =~ s/\\/\\\\/g;
    return $str;
}

sub ref_to_type
{
    my $ref = shift;
    my %map = reverse %TYPE_TO_MODEL;
    for (keys %map) {
        return $map{$_}
            if ($ref->isa("MusicBrainz::Server::Entity::$_"))
    }
    warn "Could not resolve the type of $ref";
    return;
}

sub artist_credit_to_ref
{
    my ($artist_credit) = @_;

    return $artist_credit unless UNIVERSAL::can ($artist_credit, 'isa');

    my $ac = [ map {
        my @credit = ( { name => $_->name, artist => $_->artist_id } );
        push @credit, $_->join_phrase if $_->join_phrase;

        @credit;
    } @{ $artist_credit->names } ];
    return $ac;
}

sub load_subobjects
{
    my ($data_access, $attr_obj, @objs) = @_;

    @objs = grep { defined } @objs;
    return unless @objs;

    my $attr_id = $attr_obj . "_id";
    @objs = grep { $_->meta->find_attribute_by_name($attr_id) } grep { defined } @objs;
    my %ids = map { ($_->meta->find_attribute_by_name($attr_id)->get_value($_) || "") => 1 } @objs;
    my @ids = grep { $_ } keys %ids;
    my $data;
    if (@ids) {
        $data = $data_access->get_by_ids(@ids);
        foreach my $obj (@objs) {
            my $id = $obj->meta->find_attribute_by_name($attr_id)->get_value($obj);
            if (defined $id && exists $data->{$id}) {
                $obj->meta->find_attribute_by_name($attr_obj)->set_value($obj, $data->{$id});
            }
        }
    }
    return defined $data ? values %{$data} : ();
}

sub load_meta
{
    my ($c, $table, $builder, @objs) = @_;
    return unless @objs;
    my %id_to_obj = map { $_->id => $_ } @objs;
    my @ids = keys %id_to_obj;
    my $sql = Sql->new($c->dbh);
    $c->sql->select("SELECT * FROM $table
                  WHERE id IN (" . placeholders(@ids) . ")", @ids);
    while (1) {
        my $row = $c->sql->next_row_hash_ref or last;
        my $obj = $id_to_obj{$row->{id}};
        $builder->($obj, $row);
    }
    $c->sql->finish;
}

sub check_in_use
{
    my ($sql, %queries) = @_;

    my @queries = keys %queries;
    my $query = join ' UNION ', map { "SELECT 1 FROM $_" } @queries;
    return 1 if $sql->select_single_value($query, map { @{$queries{$_}} } @queries );
    return;
}

sub partial_date_from_row
{
    my ($row, $prefix) = @_;
    my %info;
    $info{year} = $row->{$prefix . 'year'} if defined $row->{$prefix . 'year'};
    $info{month} = $row->{$prefix . 'month'} if defined $row->{$prefix . 'month'};
    $info{day} = $row->{$prefix . 'day'} if defined $row->{$prefix . 'day'};
    return MusicBrainz::Server::Entity::PartialDate->new(%info);
}

sub partial_date_to_hash
{
    my ($date) = @_;
    return {
        year => $date->year,
        month => $date->month,
        day => $date->day
    };
}

sub placeholders
{
    return join ",", ("?") x scalar(@_);
}

sub query_to_list
{
    my ($sql, $builder, $query, @args) = @_;
    $sql->select($query, @args);
    my @result;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    $sql->finish;
    return @result;
}

sub query_to_list_limited
{
    my ($sql, $offset, $limit, $builder, $query, @args) = @_;
    $sql->select($query, @args);
    my @result;
    while (!defined($limit) || $limit--) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $builder->($row);
        push @result, $obj;
    }
    my $hits = $sql->row_count + $offset;
    $sql->finish;
    return (\@result, $hits);
}

sub insert_and_create
{
    my ($data, @objs) = @_;
    my $class = $data->_entity_class;
    Class::MOP::load_class($class);
    my $sql = Sql->new($data->c->dbh);
    my %map = $data->_attribute_mapping;
    my @ret;
    for my $obj (@objs)
    {
        my %row = map { ($map{$_} || $_) => $obj->{$_} } keys %$obj;
        my $id = $data->sql->insert_row($data->_table, \%row, 'id');
        push @ret, $class->new( id => $id, %$obj);
    }

    return wantarray ? @ret : $ret[0];
}

sub generate_gid
{
    my $uuid = new OSSP::uuid;
    $uuid->make("v4");
    return $uuid->export("str");
}

sub defined_hash
{
    my %hash = @_;
    return map { $_ => $hash{$_} } grep { defined $hash{$_} } keys %hash;
}

sub hash_to_row
{
    my ($hash, $mapping) = @_;

    my %row;
    foreach my $db_key (keys %$mapping) {
        my $key = $mapping->{$db_key};
        if (exists $hash->{$key}) {
            $row{$db_key} = $hash->{$key};
        }
    }
    return \%row;
}

sub add_partial_date_to_row
{
    my ($row, $date, $prefix) = @_;

    if (defined $date) {
        foreach my $key (qw(year month day)) {
            if (exists $date->{$key}) {
                $row->{$prefix . '_' . $key} = $date->{$key};
            }
        }
    }
}

sub type_to_model
{
    return $TYPE_TO_MODEL{$_[0]} || undef;
}

sub model_to_type
{
    my %map = reverse %TYPE_TO_MODEL;
    return $map{$_[0]} || undef;
}

sub object_to_ids
{
    my %ret;
    foreach (@_)
    {
        $ret{$_->id} = [] unless $ret{$_->id};
        push @{ $ret{$_->id} }, $_;
    }

    return %ret;
}

sub order_by
{
    my ($order, $default, $map) = @_;

    my $order_by = $map->{$default};
    if ($order) {
        my $desc = 0;
        if ($order =~ /-(.*)/) {
            $desc = 1;
            $order = $1;
        }
        if (exists $map->{$order}) {
            $order_by = $map->{$order};
            if (ref($order_by) eq 'CODE') {
                $order_by = $order_by->();
            }
            if ($desc) {
                my @list = map { "$_ DESC" } split ',', $order_by;
                $order_by = join ',', @list;
            }
        }
    }
    return $order_by;
}

sub remove_equal
{
    my ($old, $new) = @_;

    for my $key (keys %$old) {
        my $n = $new->{$key};
        my $o = $old->{$key};

        if (Compare($n, $o)) {
            delete $old->{$key};
            delete $new->{$key};
        }
    }
}

sub map_query
{
    my ($sql, $key, $value, $query, @bind_params) = @_;
    return {
        map { $_->{$key} => $_->{$value} }
            @{ $sql->select_list_of_hashes($query, @bind_params) }
    }
}

sub check_data
{
    my ($data, @checks) = @_;

    my $it = natatime 2, @checks;
    while (my ($error, $check) = $it->()) {
        MusicBrainz::Server::Exceptions::BadData->throw($error)
            unless $check->($data);
    }
}

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
