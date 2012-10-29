package MusicBrainz::Server::Form::ReleaseEditor::Tracklist;
use HTML::FormHandler::Moose;
use JSON::Any;
use Text::Trim qw( trim );
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Track qw( format_track_length unformat_track_length );
use Try::Tiny;

extends 'MusicBrainz::Server::Form::Step';

has_field 'seeded' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'mediums.id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.toc' => ( type => 'Text' );
has_field 'mediums.name' => ( type => 'Text' );
has_field 'mediums.deleted' => ( type => 'Checkbox' );
has_field 'mediums.format_id' => ( type => 'Select' );
has_field 'mediums.position' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.tracklist_id' => ( type => '+MusicBrainz::Server::Form::Field::Integer' );
has_field 'mediums.edits' => ( type => 'Text' );

sub options_mediums_format_id {
    my ($self) = @_;

    my $root_format = $self->ctx->model('MediumFormat')->get_tree;

    return [
        map {
            $self->_build_medium_format_options($_, 'l_name', '')
        } $root_format->all_children ];
};

sub _build_medium_format_options
{
    my ($self, $root, $attr, $indent) = @_;

    my @options;
    push @options, $root->id, $indent . trim($root->$attr) if $root->id;
    $indent .= '&nbsp;&nbsp;&nbsp;';

    foreach my $child ($root->all_children) {
        push @options, $self->_build_medium_format_options($child, $attr, $indent);
    }
    return @options;
}

sub _track_errors {
    my ($self, $track, $tracknumbers, $cdtoc, $medium) = @_;

    return 0 if $track->{deleted};

    my $name = trim ($track->{name} // "");
    my $pos = trim $track->{position};

    if ($name eq '' && $pos eq '')
    {
        # position should never be empty unless someone messes with
        # the javascript.
        return l('New tracklisting contains an empty track');
    }

    if ($name eq '')
    {
        return l('A track name is required on track {pos}', { pos => $pos });
    }

    if ($pos eq '')
    {
        return l('A position is required for "{name}"', { name => $name });
    }

    if ($tracknumbers->[$pos])
    {
        return l('"{name1}" and "{name2}" have the same position',
                 {
                     name1 => $tracknumbers->[$pos],
                     name2 => $name,
                 });
    }

    $tracknumbers->[$pos] = $name;

    if (! $track->{artist_credit}->{names} ||
        scalar @{ $track->{artist_credit}->{names} } < 1 ||
        trim $track->{artist_credit}->{names}->[0]->{name} eq '')
    {
        return l('An artist is required on track {pos}', { pos => $pos });
    }

    if ($cdtoc)
    {
        # cdtoc present, so do not allow the user to change track lengths.
        # There could be multiple cdtocs though, we do not know from which
        # of those the track lengths were set, so we'll have to take the
        # track length currently set for the track.

        my $details = $medium->tracklist->tracks->[$pos - 1];

        # if $details is undef the track doesn't exist, presumably the user
        # is trying to add tracks despite a discid present, this will be
        # caught later on... here in _track_errors we just ignore it.
        if ($details)
        {
            my $distance = $track->{length}
                ? abs ($details->length - $track->{length})
                : 0;

            # always reset the track length.
            $track->{length} = $details->length;

            # only warn the user about this if the edited value differs more than 2 seconds.
            if ($distance > 2000)
            {
                return l('The length of track {pos} cannot be changed since this release has a Disc ID attached to it.',
                         { pos => $pos });
            }
        }
    }

    return 0;
};

sub _validate_edits {
    my $self = shift;
    my $medium = shift;
    my $json = JSON::Any->new( utf8 => 1 );
    my $edits = $json->decode ($medium->field('edits')->value);
    my $entity;
    my $cdtoc;
    my $medium_id = $medium->field('id')->value;
    my @errors;

    if ($medium_id)
    {
        $entity = $self->ctx->model('Medium')->get_by_id ($medium_id);
        $self->ctx->model('Tracklist')->load ($entity);
        $self->ctx->model('Track')->load_for_tracklists ($entity->tracklist);

        my @medium_cdtocs = $self->ctx->model('MediumCDTOC')->load_for_mediums($entity);
        $self->ctx->model('CDTOC')->load(@medium_cdtocs);

        $cdtoc = $medium_cdtocs[0]->cdtoc if scalar @medium_cdtocs;
    }

    my $tracknumbers = [];
    for (@$edits)
    {
        my $msg = $self->_track_errors ($_, $tracknumbers, $cdtoc, $entity);

        push @errors, $msg if $msg;
    }

    unless (scalar @$tracknumbers)
    {
        push @errors, l('A tracklist is required');
        return @errors;
    }

    shift @$tracknumbers; # there is no track 0, this shifts off an undef.

    if ($cdtoc && $cdtoc->track_count != scalar @$tracknumbers)
    {
        push @errors,
            ln('This medium has a Disc ID, it should have exactly {n} track.',
               'This medium has a Disc ID, it should have exactly {n} tracks.',
               $cdtoc->track_count, { n => $cdtoc->track_count });
    }

    my $count = 1;
    for (@$tracknumbers)
    {
        push @errors, l('Track {pos} is missing.', { pos => $count })
            unless defined $_;

        $count++;
    }

    $medium->field('edits')->value ($json->encode ($edits));

    return @errors;
};

sub validate {
    my $self = shift;

    my $medium_count = 0;
    for my $medium ($self->field('mediums')->fields)
    {
        next if $medium->field('deleted')->value;

        $medium_count++;

        my $edits = $medium->field('edits')->value;

        unless ($edits || $medium->field('tracklist_id')->value)
        {
            $medium->add_error (l('A tracklist is required'));
            next;
        }

        my @errors = $self->_validate_edits ($medium) if $edits;
        map { $medium->add_error ($_) } @errors;

        if (my $medium_id = $medium->field('id')->value) {
            $self->ctx->model('MediumCDTOC')->find_by_medium($medium_id)
                or next;

            if (my $format_id = $medium->field('format_id')->value) {
                my $format = $self->ctx->model('MediumFormat')->get_by_id($format_id);

                $medium->field('format_id')->add_error(
                    l('This medium already has disc IDs so you may only change the format
                       to a format that can have disc IDs')
                ) unless $format->has_discids;
            }
        }
    }

    # FIXME: is there a way to set an error on the entire form,
    # instead of specific to a field?
    $self->add_form_error (l('A release must have at least one medium.'))
        unless $medium_count;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
