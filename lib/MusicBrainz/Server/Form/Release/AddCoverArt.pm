package MusicBrainz::Server::Form::Release::AddCoverArt;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form::CoverArt';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'add-cover-art' );

sub edit_field_names { qw( id ) }

has_field 'id' => (
    type      => '+MusicBrainz::Server::Form::Field::Integer',
    required  => 1,
);

has_field 'nonce' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required  => 1,
);

has_field 'position' => (
    type      => '+MusicBrainz::Server::Form::Field::Integer',
    required  => 1,
    default => 1,
);

has_field 'mime_type' => (
    type      => 'Select',
    required  => 1,
);

sub options_mime_type {
    my @types = map {
        {
            'value' => $_->{mime_type},
            'label' => $_->{suffix},
        }
    } @{ shift->ctx->model('CoverArtArchive')->mime_types };

    return \@types;
}

sub validate_nonce {
    my ($self, $field) = @_;

    my $nonce = $field->value;
    my $cover_art_id = $self->field('id')->value;

    my $store = $self->ctx->model('MB')->context->store;
    my $nonce_key = 'cover_art_upload_nonce:' . $cover_art_id;
    my $stored_nonce = $store->get($nonce_key);

    if (!defined $stored_nonce || $stored_nonce ne $nonce) {
        return $field->push_errors(l(
            'The form you’ve submitted has expired. ' .
            'Please resubmit your request.'
        ));
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
