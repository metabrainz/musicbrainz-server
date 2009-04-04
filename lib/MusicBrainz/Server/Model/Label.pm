package MusicBrainz::Server::Model::Label;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

use Carp;
use MusicBrainz::Server::Adapter 'LoadEntity';
use MusicBrainz::Server::Validation 'encode_entities';
use SearchEngine;

sub load
{
    my ($self, $id) = @_;

    my $label = MusicBrainz::Server::Label->new($self->dbh);
    $label = LoadEntity($label, $id);

    return $label;
}

=head2 search_by_name $name

Search for all labels with the exact name C<$name>.

=cut

sub search_by_name
{
    my ($self, $name) = @_;

    my $artist = MusicBrainz::Server::Label->new($self->dbh);
    return $artist->find_labels_by_name($name);
}

sub direct_search
{
    my ($self, $query) = @_;

    my $engine = new SearchEngine($self->context->mb->{dbh}, 'label');
    $engine->Search(query => $query, limit => 0);

    return undef
        unless $engine->Result != &SearchEngine::SEARCHRESULT_NOQUERY;

    my @labels;

    while(my $row = $engine->NextRow)
    {
        my $label = new MusicBrainz::Server::Label($self->context->mb->{dbh});

        $label->id($row->{labelid});
        $label->mbid($row->{labelgid});
        $label->label_code($row->{labelcode});
        $label->name($row->{labelname});
        $label->resolution($row->{labelresolution});

        push @labels, $label;
    }

    return \@labels;
}

sub merge
{
    my ($self, $source, $target, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_MERGE_LABEL,

        source => $source,
        target => $target
    );
}

sub edit
{
    my ($self, $label, $edit_note, %opts) = @_;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $opts{begin_date} || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $opts{end_date}   || '') ],
        );

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_EDIT_LABEL,

        label      => $label,
        name       => $opts{name}        || $label->name,
        sortname   => $opts{sort_name}   || $label->sort_name,
        labeltype  => exists $opts{type} ? $opts{type} : undef,
        resolution => $opts{resolution}  || '',
        country    => $opts{country}     || '',
        labelcode  => $opts{label_code}  || '',

        begindate => $begin,
        enddate   => $end,
    );
}

sub create
{
    my ($self, $edit_note, %opts) = @_;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $opts{begin_date} || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $opts{end_date}   || '') ],
        );

    my @mods = $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_ADD_LABEL,

        name       => $opts{name},
        sortname   => $opts{sort_name},
        labeltype  => $opts{type},
        resolution => $opts{resolution} || '',
        country    => $opts{country},
        labelcode  => $opts{label_code} || '',

        begindate => $begin,
        enddate   => $end,
    );

    my @created_mods = grep { $_->type eq ModDefs::MOD_ADD_LABEL } @mods;
    my $created_mod = $created_mods[0];

    return unless $created_mod;

    my $label = new MusicBrainz::Server::Label($self->context->mb->{dbh});
    $label->id($created_mod->row_id);
    $label->name($opts{name});
    $label->sort_name($opts{sort_name});
    $label->resolution($opts{resolution});

    return $label;
}

sub add_alias
{
     my ($self, $label, $alias, $edit_note) = @_;

     $self->context->model('Moderation')->insert(
          $edit_note,

          type => ModDefs::MOD_ADD_LABELALIAS,

          label    => $label,
          newalias => $alias,
     );
}

sub edit_alias
{
     my ($self, $label, $alias, $new_name, $edit_note) = @_;

     $self->context->model('Moderation')->insert(
         $edit_note,

         type => ModDefs::MOD_EDIT_LABELALIAS,

         label   => $label,
         alias   => $alias,
         newname => $new_name,
     );
}

sub remove_alias
{
    my ($self, $label, $alias, $edit_note) = @_;

    $self->context->model('Moderation')->insert(
        $edit_note,

        type => ModDefs::MOD_REMOVE_LABELALIAS,

        label => $label,
        alias => $alias,
    );
}

sub get_browse_selection
{
    my ($self, $index, $offset) = @_;
    
    my $la = MusicBrainz::Server::Label->new($self->dbh);
    my ($count, $labels) = $la->label_browse_selection($index, $offset);
    
    return ($count, $labels);
}

1;
