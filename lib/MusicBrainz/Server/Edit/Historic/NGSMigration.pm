package MusicBrainz::Server::Edit::Historic::NGSMigration;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Historic::Base;
use Class::Load qw( load_class );

sub ngs_class {  }
sub edit_type {
    my $self = shift;
    return unless $self->ngs_class;
    $self->ngs_class->edit_type
}

sub _create_edit
{
    my ($self, $data) = @_;
    my $class = $self->ngs_class;
    load_class($class);

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
    my $data = $self->do_upgrade;
    $self->data($data);
    return $self;
}

sub extra_parameters { return (); }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
