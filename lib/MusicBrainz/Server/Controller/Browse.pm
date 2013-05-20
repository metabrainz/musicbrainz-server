package MusicBrainz::Server::Controller::Browse;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

__PACKAGE__->config( paging_limit => 100 );

sub _browse
{
    my ($self, $c, $model_name) = @_;

    my $index = $c->req->query_params->{index};
    my $entities;
    if ($index) {
        $entities = $self->_load_paged($c, sub {
            $c->model($model_name)->find_by_name_prefix($index, shift, shift);
        });
    }

    $c->stash(
        entities => $entities,
        index    => $index,
    );
}

sub index : Path Args(0)
{
    my ($self, $c) = @_;

    $c->stash( template => 'browse/index.tt' );

}

sub area : Local
{
    my ($self, $c) = @_;

    $self->_browse($c, 'Area');
}

sub artist : Local
{
    my ($self, $c) = @_;

    $self->_browse($c, 'Artist');
}

sub label : Local
{
    my ($self, $c) = @_;

    $self->_browse($c, 'Label');
}

sub release : Local
{
    my ($self, $c) = @_;

    $self->_browse($c, 'Release');
}

sub release_group : Path('release-group')
{
    my ($self, $c) = @_;

    $self->_browse($c, 'ReleaseGroup');
}

sub work : Local
{
    my ($self, $c) = @_;

    $self->_browse($c, 'Work');
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
