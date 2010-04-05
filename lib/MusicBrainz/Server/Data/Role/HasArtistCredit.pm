package MusicBrainz::Server::Data::Role::HasArtistCredit;
use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( query_to_list_limited );
use MusicBrainz::Schema qw( schema );

method find_by_artist ($artist_id, $limit, $offset)
{
    my $acn = schema->table('artist_credit_name');

    # XXX Fey should be able to cope with this
    my $work_acn = Fey::FK->new(
        source_columns => [ $self->table->column('artist_credit') ],
        target_columns => [ $acn->column('artist_credit') ]);

    my $query = $self->_select
        ->from($self->table, $acn, $work_acn)
        ->where($acn->column('artist'), '=', $artist_id)
        ->order_by($self->name_columns->{name})
        ->limit(undef, $offset || 0);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query->sql($self->c->dbh), $query->bind_params);
}

1;
