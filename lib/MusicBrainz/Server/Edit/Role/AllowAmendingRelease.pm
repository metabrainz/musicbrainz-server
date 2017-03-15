package MusicBrainz::Server::Edit::Role::AllowAmendingRelease;

use Moose::Role;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CREATE );

requires 'release_id';

sub can_amend {
    my ($self) = @_;

    # Allow being an auto-edit if the release-add edit was opened by the same
    # editor less than an hour ago.

    my @args = ($self->release_id, $self->editor_id, $EDIT_RELEASE_CREATE);
    my $add_release_edit = $self->c->sql->select_single_value(<<'EOSQL', @args);
        SELECT id FROM edit
          JOIN edit_release ON edit.id = edit_release.edit
         WHERE edit_release.release = ?
           AND edit.editor = ?
           AND edit.type = ?
           AND (now() - edit.open_time) < interval '1 hour'
EOSQL

    return defined $add_release_edit;
};

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2014-2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
