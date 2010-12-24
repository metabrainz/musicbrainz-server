package MusicBrainz::Server::Form::ReleaseEditor::Tracklist;
use HTML::FormHandler::Moose;
use JSON::Any;
use Text::Trim qw( trim );
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Track qw( format_track_length );

extends 'MusicBrainz::Server::Form::Step';

has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'mediums.id' => ( type => 'Integer' );
has_field 'mediums.name' => ( type => 'Text' );
has_field 'mediums.deleted' => ( type => 'Checkbox' );
has_field 'mediums.format_id' => ( type => 'Select' );
has_field 'mediums.position' => ( type => 'Integer' );
has_field 'mediums.tracklist_id' => ( type => 'Integer' );
has_field 'mediums.edits' => ( type => 'Text', fif_from_value => 1 );

# keep track of advanced or basic view, useful when navigating away from
# this page and coming back, or when validation failed.
has_field 'advanced' => ( type => 'Integer' );

sub options_mediums_format_id { shift->_select_all('MediumFormat') }

sub _track_errors {
    my ($self, $track, $tracknumbers, $cdtoc) = @_;

    return 0 if $track->{deleted};

    my $name = trim $track->{name};
    my $pos = trim $track->{position};

    if ($name eq '' && $pos eq '')
    {
        # position should never be empty unless someone messes with
        # the javascript.
        return l('New tracklisting contains an empty track.');
    }

    if ($name eq '')
    {
        return l('A track name is required on track {pos}.', { pos => $pos });
    }

    if ($pos eq '')
    {
        return l('A position is required for "{name}".', { name => $name });
    }

    if ($tracknumbers->[$pos])
    {
        return l('"{name1}" and "{name2}" have the same position.',
                 {
                     name1 => $tracknumbers->[$pos],
                     name2 => $name,
                 });
    }

    $tracknumbers->[$pos] = $name;

    if (! $track->{artist_credit}->{names} ||
        scalar @{ $track->{artist_credit}->{names} } < 1 ||
        trim $track->{artist_credit}->{names}->[0]->{gid} eq '' ||
        trim $track->{artist_credit}->{names}->[0]->{name} eq '' ||
        trim $track->{artist_credit}->{names}->[0]->{artist_name} eq '')
    {
        return l('An artist is required on track {pos}.', { pos => $pos });
    }

    if ($cdtoc)
    {
        my $details = $cdtoc->track_details->[$pos - 1];
        next unless $details;

        my $cdtoc_duration = format_track_length ($details->{length_time});
        if ($track->{length} ne $cdtoc_duration)
        {
            $track->{length} = $cdtoc_duration;
            return l('The length of track {pos} cannot be changed since this release has a Disc ID attached to it.',
                     { pos => $pos, length => $cdtoc_duration });
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
        my @medium_cdtocs = $self->ctx->model('MediumCDTOC')->load_for_mediums($entity);
        $self->ctx->model('CDTOC')->load(@medium_cdtocs);

        $cdtoc = $medium_cdtocs[0]->cdtoc if scalar @medium_cdtocs;
    }

    my $tracknumbers = [];
    for (@$edits)
    {
        my $msg = $self->_track_errors ($_, $tracknumbers, $cdtoc);

        push @errors, $msg if $msg;
    }

    unless (scalar @$tracknumbers)
    {
        push @errors, l('A tracklist is required');
        return @errors;
    }

    shift @$tracknumbers; # there is no track 0, this shifts off an undef.

    if ($cdtoc->track_count != scalar @$tracknumbers)
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

    $json = JSON::Any->new;
    $medium->field('edits')->value ($json->encode ($edits));

    return @errors;
};

sub validate {
    my $self = shift;

    for my $medium ($self->field('mediums')->fields)
    {
        my $edits = $medium->field('edits')->value;

        unless ($edits || $medium->field('tracklist_id')->value)
        {
            $medium->add_error (l('A tracklist is required'));
            next;
        }

        my @errors = $self->_validate_edits ($medium) if $edits;
        map { $medium->add_error ($_) } @errors;
    }
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
