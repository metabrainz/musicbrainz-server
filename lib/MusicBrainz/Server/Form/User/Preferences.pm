package MusicBrainz::Server::Form::User::Preferences;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz;
use MusicBrainz::Server::Country;
use UserPreference;
use MusicBrainz::Server::Editor;

=head1 NAME

MusicBrainz::Server::Form::User::Preferences

=head1 DESCRIPTION

Provides a form for the user to set their user preferences as to how
they interact with the website.

=head1 METHODS

=head2 name

Returns a name for this form

=cut

sub name { 'user-preferences' };

=head2 profile

Gets all the fields used to set user preferences. The names of the fields
must exist in UserPreference::prefs.

=cut

sub profile
{
    return {
        optional => {
            # Voting/edit review pages
            mod_add_album_inline        => 'Checkbox',
            mod_add_album_link          => 'Checkbox',
            navbar_mod_show_select_page => 'Checkbox',
            mods_per_page               => 'PosInteger',
            vote_abs_default            => 'Checkbox',
            vote_show_novote            => 'Checkbox',
            mail_notes_if_i_noted       => 'Checkbox',
            mail_notes_if_i_voted       => 'Checkbox',
            mail_on_first_no_vote       => 'Checkbox',
            show_inline_mods            => 'Checkbox',
            show_inline_mods_random     => 'Checkbox',
            remove_recent_link_on_add   => 'Checkbox',
            auto_subscribe              => 'Checkbox',

            # E-Mailing other editors
            reveal_address_when_mailing => 'Checkbox',
            sendcopy_when_mailing       => 'Checkbox',

            # Show artist
            releases_show_compact => 'Integer',

            # Show release
            release_show_relationshipslinks => 'Checkbox',
            release_show_annotationlinks    => 'Checkbox',
            show_amazon_coverart            => 'Checkbox',
            use_amazon_store                => 'Select',

            # Country
            default_country => 'Select',
            google_domain   => 'Select',

            # Date/time display
            datetimeformat => 'Select',
            timezone       => 'Select',

            # Topmenu Configuration
            topmenu_submenu_types    => 'Select',
            topmenu_dropdown_trigger => 'Select',

            # Edit Suite options
            JS_es   => 'Checkbox',
            JS_es_Icons   => 'Checkbox',
            JS_es_InlineMode => 'Checkbox',
            JS_es_Start   => 'Checkbox',
            JS_es_Tooltips   => 'Checkbox',

            # Edit Suite modules
            JS_es_guessCase   => 'Checkbox',
            JS_es_searchReplace   => 'Checkbox',
            JS_es_styleGuidelines   => 'Checkbox',
            JS_es_trackParser   => 'Checkbox',
            JS_es_userPreferences   => 'Checkbox',
            JS_es_undoRevert   => 'Checkbox',

            # JavaScript presets
            JS_attr_preset1  => 'Text',
            JS_attr_preset2  => 'Text',
            JS_attr_preset3  => 'Text',
            JS_attr_preset4  => 'Text',

            # Use of JavaScript
            JSMoveFocus  => 'Checkbox',

            # Display
            sidebar_panel_sites   => 'Checkbox',
            sidebar_panel_search  => 'Checkbox',
            sidebar_panel_stats   => 'Checkbox',
            sidebar_panel_topmods => 'Checkbox',
            sidebar_panel_user    => 'Checkbox',
            nosidebar             => 'Checkbox',
            css_noentityicons     => 'Checkbox',
            show_ratings          => 'Checkbox',
            css_nosmallfonts      => 'Checkbox',

	    # Privacy
	    subscriptions_public => 'Checkbox',
           tags_public          => 'Checkbox',
           ratings_public       => 'Checkbox',
        },
    };
}

=head2 Combo box options

=cut

sub options_autofix_open {
    [
        "remember", "how I last left it",
        1, "open",
        0, "closed",
    ];
}

sub options_topmenu_dropdown_trigger {
    [
        "mouseover" => "When I move the mouse over the item",
        "click" => "When I click the open submenu icon",
    ];
}

sub options_topmenu_submenu_types {
    [
        "both" => "Both",
        "dropdownonly" => "Dropdown menus only (vertical)",
        "staticonly" => "Static submenus only (horizontal)",
    ];
}

sub options_datetimeformat {    
}

sub options_timezone {
    my @zones = UserPreference::allowed_timezones();
    return (map { $_->[0] => $_->[1] } @zones);
}

sub options_use_amazon_store {
    my @stores = UserPreference::allowed_amazon_stores();
    return (map { $_ => $_ } @stores);
}

sub options_google_domain {
    my @domains = UserPreference::allowed_google_domains();
    return (map { $_ => $_ } @domains);
}

sub options_default_country {
    my $mb = new MusicBrainz;
    $mb->Login;

    my $countries = MusicBrainz::Server::Country->new($mb->{dbh});

    my @countries_menu = map {
        $_->id => $_->name
    } $countries->All;

    return \@countries_menu;   
}

=head2 Validation methods

The following subroutines validate on a per field basis.

=cut

sub validate_mods_per_page {
    my ($self, $field) = @_;

    return $field->add_error("You can only display a maximum of 25 moderations per page")
        unless $field->value <= 25;
}

sub validate_releases_show_compact {
    my ($self, $field) = @_;

    return $field->add_error("The amount of releases to trigger compact listing must be in the range 1 to 100")
        unless $field->value >= 1 && $field->value <= 100
}

=head2 init_value

Initialize the value of a form field from the user preference setting,
or fall back to a default value.

=cut

sub init_value {
    my ($self, $field, $item) = @_;

    $item ||= $self->item;

    return $item->get($field->name);
}

=head2 update_model

Save the updated user preferences to the database.

=cut

sub update_model {
    my $self = shift;
    my $item = $self->item;

    my $mb = MusicBrainz->new;
    $mb->Login;
    $self->item->dbh($mb->dbh);

    for my $field ($self->fields)
    {
        $self->item->set($field->name, $field->value);
    }

    $self->item->save;
}

=head2 update_from_form

Helper method to save the preferences if the form validates

=cut

sub update_from_form {
    my ($self, $data) = @_;

    return unless $self->validate($data);
    $self->update_model;
}

=head1 LICENSE 

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
