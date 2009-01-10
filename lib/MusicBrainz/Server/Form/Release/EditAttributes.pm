package MusicBrainz::Server::Form::Release::EditAttributes;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use Moderation;
use ModDefs;
use MusicBrainz::Server::Script;
use MusicBrainz::Server::Language;

use Rose::Object::MakeMethods::Generic(
    boolean => [ 'show_everything' ],
);

sub profile
{
    shift->with_mod_fields({
        required => {
            type     => 'Select',
            status   => 'Select',
            language => 'Select',
            script   => 'Select',
        },
    });
}

sub options_type
{
    my @values = MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START ..
                 MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END;

    my $options = [ map { $_ => MusicBrainz::Server::Release::attribute_name($_); } @values ];

    unshift @$options, ( -1 => "I don't know");

    return $options;
}

sub options_status
{
    my @values = MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START ..
                 MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END;

    my $options = [ map { $_ => MusicBrainz::Server::Release::attribute_name($_); } @values ];

    unshift @$options, ( -1 => "I don't know");

    return $options;
}

sub options_language
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $lang = MusicBrainz::Server::Language->new($mb->{dbh});
    my @languages = $lang->All(minimum_frequency => $self->show_everything ? 0 : 2);

    my @options = map { $_->id => $_->name } @languages;

    unshift @options, ( -1 => "I don't know");

    return \@options;
}

sub options_script
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $script = MusicBrainz::Server::Script->new($mb->{dbh});
    my @scripts = $script->All(minimum_frequency => $self->show_everything ? 0 : 4);

    my @options = map { $_->id => $_->name } @scripts;

    unshift @options, ( -1 => "I don't know");

    return \@options;
}

sub init_value
{
    my ($self, $field) = @_;

    my ($type, $status) = $self->item->release_type_and_status;

    use Switch;
    switch ($field->name)
    {
        case ('type')     { return $type; }
        case ('status')   { return $status; }
        case ('language') { return $self->item->language->id; }
        case ('script')   { return $self->item->script->id; }
    }
}

sub update_model
{
    my $self = shift;
    my $release = $self->item;

    $self->context->model('Release')->update_language(
        $release,
        $self->value('language'),
        $self->value('script'),
        $self->value('edit_note'),
    );

    $self->context->model('Release')->update_attributes(
        $release,
        $self->value('type'),
        $self->value('status'),
        $self->value('edit_note'),
    );
}

1;
