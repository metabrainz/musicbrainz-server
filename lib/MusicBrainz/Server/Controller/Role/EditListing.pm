package MusicBrainz::Server::Controller::Role::EditListing;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Constants qw( :edit_status );

requires '_load_paged';

sub edits : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;
    $self->_list($c, sub {
        my ($type, $entity) = @_;
        return sub {
            my ($offset, $limit) = @_;
            $c->model('Edit')->find({ $type => $entity->id }, $offset, $limit);
        }
    });
}

sub open_edits : Chained('load') PathPart RequireAuth
{
    my ($self, $c) = @_;
    $self->_list($c, sub {
        my ($type, $entity) = @_;
        return sub {
            my ($offset, $limit) = @_;
            $c->model('Edit')->find({ $type => $entity->id, status => $STATUS_OPEN }, $offset, $limit);
        }
    });

    $c->stash( template => model_to_type( $self->{model} ) . '/edits.tt' );
}

sub _list {
    my ($self, $c, $find) = @_;

    my $type   = model_to_type( $self->{model} );
    my $entity = $c->stash->{ $self->{entity_name} };
    my $edits  = $self->_load_paged($c, $find->($type, $entity));

    $c->model('Edit')->load_all(@$edits);
    $c->model('Vote')->load_for_edits(@$edits);
    $c->model('EditNote')->load_for_edits(@$edits);
    $c->model('Editor')->load(map { ($_, @{ $_->votes, $_->edit_notes }) } @$edits);

    $c->stash(
        edits => $edits,
    );
}

no Moose::Role;
1;
