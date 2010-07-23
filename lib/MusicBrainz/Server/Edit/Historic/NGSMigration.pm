package MusicBrainz::Server::Edit::Historic::NGSMigration;
use Moose;
use MooseX::ABC;

use Class::MOP;

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_type { undef }

sub _create_edit
{
    my ($self, $data) = @_;
    my $class = $self->ngs_class;
    Class::MOP::load_class($class);

    return $class->new(
        c            => $self->c,
        id           => $self->id,
        editor_id    => $self->editor_id,
        status       => $self->status,
        yes_votes    => $self->yes_votes,
        no_votes     => $self->no_votes,
        auto_edit    => $self->auto_edit,
        created_time => $self->created_time,
        expires_time => $self->expires_time,
        close_time   => $self->close_time,
        data         => $data,
        $self->extra_parameters,
    )
}

sub upgrade
{
    my $self = shift;
    my $data = inner();
    return ( $self->_create_edit($data) );
}

sub extra_parameters { return (); }

no Moose;
__PACKAGE__->meta->make_immutable;
1;
