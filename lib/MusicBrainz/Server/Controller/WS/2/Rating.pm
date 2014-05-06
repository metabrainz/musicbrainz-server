package MusicBrainz::Server::Controller::WS::2::Rating;
use Moose;
BEGIN { extends 'MusicBrainz::Server::ControllerBase::WS::2' }

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::WebService::XML::XPath;
use MusicBrainz::Server::Validation qw( is_guid );
use Readonly;
use Scalar::Util qw( looks_like_number );

my $ws_defs = Data::OptList::mkopt([
     rating => {
                         method   => 'GET',
                         required => [ qw(id entity) ],
     },
     rating => {
                         method   => 'POST',
                         optional => [ qw(client) ],
     },
]);

with 'MusicBrainz::Server::WebService::Validator' =>
{
     defs => $ws_defs,
};

sub rating_submit : Private
{
    my ($self, $c) = @_;

    $self->deny_readonly($c);
    $self->_validate_post($c);

    my $xp = MusicBrainz::Server::WebService::XML::XPath->new( xml => $c->request->body );

    my %ratable = (
        artist          => 1,
        label           => 1,
        recording       => 1,
        'release-group' => 1,
        work            => 1,
    );

    my @submit;
    for my $node ($xp->find('/mb:metadata/*/*')->get_nodelist)
    {
        my $type = $node->getLocalName;
        $self->_error($c, "Entity type '$type' cannot have ratings. " .
                           "Supported types are: " . join(', ', keys %ratable))
            unless $ratable{$type};

        $type =~ s/-/_/;

        my $model = type_to_model($type);
        $self->_error($c, "Unrecognized entity $type.") unless $model;

        my $gid = $xp->find('@mb:id', $node)->string_value;
        $self->_error($c, "Cannot parse MBID: $gid.")
            unless is_guid($gid);

        my $entity = $c->model($model)->get_by_gid($gid);
        $self->_error($c, "Cannot find $type $gid.") unless $entity;

        my $rating = $xp->find('mb:user-rating', $node)->string_value;
        $self->_error($c, "Rating should be an integer between 0 and 100")
            unless looks_like_number ($rating) && $rating >= 0 && $rating <= 100;

        # postpone any updates until we've made some effort to parse the whole
        # body and report possible errors in it.
        push @submit, { model => $model,  entity => $entity,  rating => $rating }
    }

    for (@submit)
    {
        $c->model($_->{model})->rating->update(
            $c->user->id, $_->{entity}->id, $_->{rating});
    }

    $c->detach('success');
}

sub rating_lookup : Chained('root') PathPart('rating') Args(0)
{
    my ($self, $c) = @_;

    $c->detach('rating_submit') if $c->request->method eq 'POST';

    my ($entity, $model) = $self->_validate_entity($c);

    $c->model($model)->rating->load_user_ratings($c->user->id, $entity);

    my $stash = WebServiceStash->new;
    $stash->store($entity)->{user_ratings} = $entity->user_rating;

    $c->res->content_type($c->stash->{serializer}->mime_type . '; charset=utf-8');
    $c->res->body($c->stash->{serializer}->serialize('rating', $entity, $c->stash->{inc}, $stash));
}

__PACKAGE__->meta->make_immutable;
1;

