package MusicBrainz::Server::Edit::Release::ChangeQuality;
use Moose;
use Method::Signatures::Simple;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CHANGE_QUALITY );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Change release quality' }
sub edit_type { $EDIT_RELEASE_CHANGE_QUALITY }

method alter_edit_pending
{
    return {
        Release => [ $self->_release_id ],
    }
}

method related_entities
{
    return {
        release => [ $self->_release_id ]
    }
}

sub change_fields
{
    return Dict[
        quality => Int,
    ]
}

has '+data' => (
    isa => Dict[
        release_id => Int,
        old        => change_fields(),
        new        => change_fields()
    ]
);

method foreign_keys
{
    return {
        Release => { $self->_release_id => ['ArtistCredit'] },
    }
}

method build_display_data ($loaded)
{
    return {
        release => $loaded->{Release}{ $self->_release_id },
        quality => {
            old => $self->data->{old}{quality},
            new => $self->data->{new}{quality},
        }
    }
}

method _release_id { return $self->data->{release_id} }

method initialize (%opts)
{
    my $release = $opts{to_edit} or die 'Need a release to change quality';
    $self->data({
        release_id => $release->id,
        old => { quality => $release->quality },
        new => { quality => $opts{quality} },
    });
}


method accept
{
    $self->c->model('Release')->update(
        $self->_release_id,
        { quality => $self->data->{new}{quality} }
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;
