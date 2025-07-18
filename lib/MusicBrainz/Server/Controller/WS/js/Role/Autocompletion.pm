package MusicBrainz::Server::Controller::WS::js::Role::Autocompletion;
use Moose::Role;
use namespace::autoclean;

use Encode;
use JSON;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use Text::Trim;

requires 'type';

sub model {
    my ($self, $c) = @_;
    return $c->model(type_to_model($self->type));
}

sub dispatch_search {
    my ($self, $c) = @_;

    my $args = $c->stash->{args};
    my $query = trim $args->{q};
    my $limit = $args->{limit} || 10;
    my $page = $args->{page} || 1;
    my $direct = $args->{direct} || '';
    my $advanced = $args->{advanced} || '';

    unless ($query) {
        $c->detach('bad_req');
    }

    my ($output, $pager) =
        $direct eq 'true' ? $self->_direct_search($c, $query, $page, $limit)
                          : $self->_indexed_search($c, $query, $page, $limit,
                                                   $advanced eq 'true');
    my $serialization_routine = 'autocomplete_' . $self->type;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize($serialization_routine, $output, $pager));
}

sub _load_entities {
    my ($self, $c, @entities) = @_;

    if ($c->stash->{inc}->{rels}) {
        $c->model('Relationship')->load_cardinal(@entities);
    }

    my $entity_properties = $ENTITIES{$self->type};

    if ($entity_properties->{aliases}) {
        $self->model($c)->load_aliases(@entities);
    }
}

sub _do_direct_search {
    my ($self, $c, $query, $offset, $limit) = @_;
    return $c->model('Search')->search(
        $self->type, $query, $limit, $offset);
}

sub _direct_search {
    my ($self, $c, $query, $page, $limit) = @_;

    my $offset = ($page - 1) * $limit;  # page is not zero based.
    my ($search_results, $hits) = $self->_do_direct_search($c, $query, $offset, $limit);

    my @entities = map { $_->entity } @$search_results;
    $self->_load_entities($c, @entities);

    my @output = $self->_format_output($c, @entities);

    my $pager = Data::Page->new();
    $pager->entries_per_page($limit);
    $pager->current_page($page);
    $pager->total_entries($hits);

    return (\@output, $pager);
}

sub _format_output {
    my ($self, $c, @entities) = @_;
    return @entities;
}

sub _indexed_search {
    my ($self, $c, $query, $page, $limit, $advanced) = @_;

    my $model = $self->model($c);

    my $response = $c->model('Search')->external_search(
        $self->type,
        $query,
        $limit,
        $page,
        $advanced,
    );
    my (@output, $pager);

    if ($response->{error}) {
        my $json = JSON->new;
        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($json->encode($response));
        $c->res->status($response->{code});
        $c->detach;
    } else {
        $pager = $response->{pager};
        my @gids = map {
            my $gid = $_->entity->{gid};
            $gid ? $gid : ()
        } @{ $response->{results} };
        my $entity_map = $model->get_by_gids(@gids);
        @output = map { $entity_map->{$_} } @gids;
        $self->_load_entities($c, @output);
    }

    return ([ $self->_format_output($c, @output) ], $pager);
}

1;
