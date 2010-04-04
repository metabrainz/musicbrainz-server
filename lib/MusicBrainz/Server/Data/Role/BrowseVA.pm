package MusicBrainz::Server::Data::Role::BrowseVA;
use Moose::Role;
use Method::Signatures::Simple;
use namespace::autoclean;

with 'MusicBrainz::Server::Data::Role::Browse';

use MusicBrainz::Server::Constants '$VARTIST_ID';

method find_by_name_prefix_va ($prefix, $limit, $offset)
{
    my $acn = schema->table('artist_credit_name');

    my $subq = Fey::SQL->new_select
        ->select($acn->column('artist_credit'))
        ->from($acn)
        ->where($acn->column('artist'), '=', $VARTIST_ID);

    my $query = $self->_find_by_name_prefix_sql($prefix, $offset)
        ->where($self->table->column('artist_credit'), 'IN',
                $subq);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query->sql($self->c->dbh), $query->bind_params);
}

no Moose::Role;
1;
