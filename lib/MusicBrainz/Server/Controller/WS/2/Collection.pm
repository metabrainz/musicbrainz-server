package MusicBrainz::Server::Controller::WS::2::Collection;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use List::MoreUtils qw( uniq all );
use MusicBrainz::Server::Constants qw( $ACCESS_SCOPE_COLLECTION %ENTITIES entities_with );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::WebService::XML::XPath;
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;

use Moose::Util qw( find_meta );

my $ws_defs = Data::OptList::mkopt([
    collection => {
        method => 'GET',
        linked => [ entities_with('collections', take => 'url'), qw(editor) ],
        inc => [ qw(user-collections) ],
        optional => [ qw(fmt limit offset) ],
    },
     collection => {
                         method   => 'GET',
                         inc      => [ entities_with('collections', take => 'plural_url'), qw( tags ) ],
                         optional => [ qw(fmt limit offset) ],
     },
     collection => {
         method => 'PUT',
     },
     collection => {
         method => 'DELETE',
     }
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

with 'MusicBrainz::Server::Controller::WS::2::Role::Lookup' => {
    model => 'Collection',
};

Readonly our $MAX_ITEMS => 25;

sub get_collection_from_stash {
    my ($self, $c) = @_;

    my $collection = $c->stash->{entity} // $c->detach('not_found');
    if (!$collection->public) {
        $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);
        unless ($c->user_exists &&
                    $c->model('Collection')->is_collection_collaborator($c->user->id, $collection->id)) {
            $self->_error($c, 'You do not have permission to view this collection');
        }
    }
    return $collection;
}

sub base : Chained('root') PathPart('collection') CaptureArgs(0) { }

before lookup => sub {
    my ($self, $c) = @_;

    $c->detach('method_not_allowed')
        unless $c->req->method eq 'GET';

    $self->get_collection_from_stash($c);
};

sub collection_toplevel {
    my ($self, $c, $stash, $collections) = @_;

    my @collections = @{$collections};

    $c->model('Collection')->load_entity_count(@collections);
    $c->model('CollectionType')->load(@collections);
    $c->model('Editor')->load(@collections);
}

map {
    my $type = $_;
    my $entity_properties = $ENTITIES{$type};
    my $url = $entity_properties->{url};
    my $plural = $entity_properties->{plural};
    my $plural_url = $entity_properties->{plural_url};

    my $method = sub {
        my ($self, $c) = @_;

        $c->detach('method_not_allowed')
            unless $c->req->method eq 'GET';

        my $collection = $self->get_collection_from_stash($c);
        my $stash = WebServiceStash->new;
        my $opts = $stash->store($collection);

        $self->linked_collections($c, $stash, [ $collection ]);

        $c->model('Collection')->load_entity_count($collection);
        $c->model('CollectionType')->load($collection);

        $self->_error($c, "This is not a collection for entity type $url."),
            unless ($collection->type->item_entity_type eq $type);

        $c->model('Editor')->load($collection);

        my ($limit, $offset) = $self->_limit_and_offset($c);
        my @results = $c->model($entity_properties->{model})->find_by_collection($collection->id, $limit, $offset);

        $opts->{$plural} = $self->make_list(@results);

        my $linked = "linked_$plural";
        $self->$linked($c, $stash, $opts->{$plural}->{items});

        $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->serialize('collection', $collection, $c->stash->{inc}, $stash));
    };

    my $submission_method = sub {
        my ($self, $c, $entities) = @_;

        $c->detach('method_not_allowed')
            unless $c->req->method eq 'PUT' || $c->req->method eq 'DELETE';

        $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);

        my $collection = $c->stash->{entity} // $c->detach('not_found');
        $c->model('CollectionType')->load($collection);

        $self->_error($c, 'You do not have permission to modify this collection')
            unless ($c->model('Collection')->is_collection_collaborator($c->user->id, $collection->id));

        $self->_error($c, "This is not a collection for entity type $url.")
            unless ($collection->type->item_entity_type eq $type);

        my $client = $c->req->query_params->{client}
            or $self->_error($c, 'You must provide information about your client, by the client query parameter');
        $self->bad_req($c, 'Invalid argument "client"') if ref($client);

        my @gids = split /;/, $entities;

        $self->_error($c, "All $plural_url must have an MBID present")
            unless all { defined } (@gids);

        for my $gid (@gids) {
            $self->_error($c, "$gid is not a valid MBID") unless is_guid($gid);
        }

        my %entities = %{ $c->model($entity_properties->{model})->get_by_gids(@gids) };

        if ($c->req->method eq 'PUT') {
            $self->deny_readonly($c);
            $c->model('Collection')->add_entities_to_collection(
                $type,
                $collection->id,
                map { $_->id } grep { defined } map { $entities{$_} } @gids
            );
            $c->detach('success');
        } elsif ($c->req->method eq 'DELETE') {
            $self->deny_readonly($c);
            $c->model('Collection')->remove_entities_from_collection(
                $type,
                $collection->id,
                map { $_->id } grep { defined } map { $entities{$_} } @gids
            );
            $c->detach('success');
        } else {
            $self->_error($c, 'You can only PUT or DELETE this resource');
        }
    };

    my $method_name = $plural . '_get';
    find_meta(__PACKAGE__)->add_method($method_name => $method);
    find_meta(__PACKAGE__)->register_method_attributes($method, [q{Chained('load')}, "PathPart('$plural_url')", 'Args(0)']);

    find_meta(__PACKAGE__)->add_method($plural => $submission_method);
    find_meta(__PACKAGE__)->register_method_attributes(
        $submission_method,
        [q{Chained('load')}, "PathPart('$plural_url')", 'Args(1)'],
    );
} entities_with('collections');

sub collection_list : Chained('base') PathPart('') {
    my ($self, $c) = @_;

    $c->detach('method_not_allowed')
        unless $c->req->method eq 'GET';

    $c->detach('collection_browse')
        if $c->stash->{linked};

    $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);

    my $stash = WebServiceStash->new;
    my @result = $c->model('Collection')->find_by({
        editor_id => $c->user->id,
        show_private => $c->user->id,
        with_collaborations => 1,
    });
    my @collections = @{ $result[0] };
    $c->model('Editor')->load(@collections);
    $c->model('Collection')->load_entity_count(@collections);
    $c->model('CollectionType')->load(@collections);

    my $collections = $self->make_list(@result);
    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection-list', $collections,
                                                     $c->stash->{inc}, $stash));
}

sub collection_browse : Private {
    my ($self, $c) = @_;

    my ($resource, $id) = @{ $c->stash->{linked} };
    my ($limit, $offset) = $self->_limit_and_offset($c);

    my $collections;
    my $stash = WebServiceStash->new;
    my @result;
    my $show_private;

    if ($c->stash->{inc}->user_collections) {
        $self->authenticate($c, $ACCESS_SCOPE_COLLECTION);
        $show_private = $c->user->id;
    }

    if ($resource eq 'editor') {
        my $editor = $c->model('Editor')->get_by_name($id);
        $c->detach('not_found') unless $editor;

        if ($show_private) {
            $self->unauthorized($c) unless $c->user->id == $editor->id;
        }

        @result = $c->model('Collection')->find_by({
            editor_id => $editor->id,
            show_private => $show_private,
            with_collaborations => 1,
        }, $limit, $offset);
    } else {
        my $entity_type = $resource =~ tr/-/_/r;
        my $entity = $c->model(type_to_model($entity_type))->get_by_gid($id);
        $c->detach('not_found') unless $entity;

        @result = $c->model('Collection')->find_by({
            entity_type => $entity_type,
            entity_id => $entity->id,
            show_private => $show_private,
            with_collaborations => 1,
        }, $limit, $offset);
    }

    $collections = $self->make_list(@result, $offset);
    my @collections = @{ $result[0] };
    $self->collection_toplevel($c, $stash, \@collections);

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('collection-list', $collections, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;
