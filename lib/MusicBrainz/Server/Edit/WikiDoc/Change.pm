package MusicBrainz::Server::Edit::WikiDoc::Change;
use Moose;

use DBDefs;
use MusicBrainz::Server::Constants qw( $EDIT_WIKIDOC_CHANGE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use URI::Escape qw( uri_escape );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::WikiDoc';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

sub edit_type { $EDIT_WIKIDOC_CHANGE }
sub edit_name { N_l("Change WikiDoc") }
sub edit_kind { 'other' }

has '+data' => (
    isa => Dict[
        page => Str,
        old_version => Nullable[Int],
        new_version => Nullable[Int]
    ]
);

sub initialize
{
    my ($self, %opts) = @_;

    $self->data({
        page => $opts{page},
        old_version => $opts{old_version},
        new_version => $opts{new_version}
    });
}

sub accept
{
    my $self = shift;

    $self->c->model('WikiDocIndex')->set_page_version(
        $self->data->{page}, $self->data->{new_version});
}

sub build_display_data {
    my ($self) = @_;

    my ($host, $page, $old_id, $new_id) = (
        DBDefs->WIKITRANS_SERVER,
        map { uri_escape($_) } @{$self->data}{qw(page old_version new_version)}
    );

    return {
        old_version_link => sprintf('//%s/index.php?title=%s&oldid=%d', $host, $page, $old_id),
        new_version_link => sprintf('//%s/index.php?title=%s&oldid=%d', $host, $page, $new_id),
        diff_link => sprintf('//%s/index.php?title=%s&diff=%d&oldid=%d', $host, $page, $new_id, $old_id),
    };
}

__PACKAGE__->meta->make_immutable;

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
