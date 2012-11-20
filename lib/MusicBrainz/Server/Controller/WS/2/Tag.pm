package MusicBrainz::Server::Controller::WS::2::Tag;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Validation qw( is_guid );
use MusicBrainz::Server::WebService::XML::XPath;
use Readonly;

my $ws_defs = Data::OptList::mkopt([
     tag => {
                         method   => 'GET',
                         required => [ qw(query) ],
                         optional => [ qw(fmt limit offset) ],
     },
     tag => {
                         method   => 'GET',
                         required => [ qw(id entity) ],
     },
     tag => {
                         method   => 'POST',
                         optional => [ qw(client) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub tag_lookup : Private
{
    my ($self, $c) = @_;

    my ($entity, $model) = $self->_validate_entity ($c);

    my @tags = $c->model($model)->tags->find_user_tags($c->user->id, $entity->id);

    my $stash = WebServiceStash->new;
    $stash->store ($entity)->{user_tags} = \@tags;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('tag-list', $entity, $c->stash->{inc}, $stash));
}


sub tag_search : Chained('root') PathPart('tag') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('tag_submit') if $c->request->method eq 'POST';
    $c->detach('tag_lookup') if exists $c->stash->{args}->{id};

    $self->_search ($c, 'tag');
}

sub tag_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    $self->_validate_post ($c);

    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );

    my @submit;
    for my $node ($xp->find('/mb:metadata/*/*')->get_nodelist)
    {
        my $type = $node->getLocalName;
        $type =~ s/-/_/;

        my $model = type_to_model ($type);
        $self->_error ($c, "Unrecognized entity $type.") unless $model;

        my $gid = $xp->find('@mb:id', $node)->string_value;
        $self->_error ($c, "Cannot parse MBID: $gid.")
            unless is_guid($gid);

        my $entity = $c->model($model)->get_by_gid($gid);
        $self->_error ($c, "Cannot find $type $gid.") unless $entity;

        # postpone any updates until we've made some effort to parse the whole
        # body and report possible errors in it.
        push @submit, { model => $model,  entity => $entity, tags => [ map {
                $_->string_value
            } $xp->find('mb:user-tag-list/mb:user-tag/mb:name', $node)->get_nodelist ], };
    }

    for (@submit)
    {
        $c->model($_->{model})->tags->update(
            $c->user->id, $_->{entity}->id, join (", ", @{ $_->{tags} }));
    }

    $c->detach('success');
}

__PACKAGE__->meta->make_immutable;
1;

