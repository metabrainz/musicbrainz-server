package MusicBrainz::Server::Form::User::Preferences;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Model::UserPreference';

use MusicBrainz::Server::Country;
use UserPreference;

sub name { 'user_preferences' };

# profile {{{
sub profile
{
    return {
        # The keys used here *MUST* exist in UserPreference::prefs
        optional => {
            # Voting/edit review pages {{{
            mod_add_album_inline => 'Checkbox',
            mod_add_album_link => 'Checkbox',
            navbar_mod_show_select_page => 'Checkbox',
            mods_per_page => 'PosInteger',
            vote_abs_default => 'Checkbox',
            vote_show_novote => 'Checkbox',
            mail_notes_if_i_noted => 'Checkbox',
            mail_notes_if_i_voted => 'Checkbox',
            mail_on_first_no_vote => 'Checkbox',
            show_inline_mods => 'Checkbox',
            show_inline_mods_random => 'Checkbox',
            remove_recent_link_on_add => 'Checkbox',
            auto_subscribe => 'Checkbox',
            # }}}

            # E-Mailing other editors {{{
            reveal_address_when_mailing => 'Checkbox',
            sendcopy_when_mailing => 'Checkbox',
            # }}}

            # Show artist {{{
            releases_show_compact => 'Integer',
            # }}}

            # Show release {{{
            release_show_relationshipslinks => 'Checkbox',
            release_show_annotationlinks => 'Checkbox',
            show_amazon_coverart => 'Checkbox',
            use_amazon_store => 'Select',
            # }}}

            # Country {{{
            default_country => 'Select',
            google_domain => 'Select',
            # }}}

            # Date/time display {{{
            datetimeformat => 'Select',
            timezone => 'Select',
            # }}}

            # Topmenu Configuration {{{
            topmenu_submenu_types => 'Select',
            topmenu_dropdown_trigger => 'Select',
            # }}}

            # Use of javascript {{{
            autofix_open => 'Select',
            JSMoveFocus => 'Checkbox',
            JSDiff => 'Checkbox',
            JSCollapse => 'Checkbox',
            JSDebug => 'Checkbox',
            # }}}

            # Display {{{
            sidebar_panel_sites => 'Checkbox',
            sidebar_panel_search => 'Checkbox',
            sidebar_panel_stats => 'Checkbox',
            sidebar_panel_topmods => 'Checkbox',
            sidebar_panel_user => 'Checkbox',
            nosidebar => 'Checkbox',
            css_noentityicons => 'Checkbox',
            css_nosmallfonts => 'Checkbox',
            # }}}
        },
    };
}
# }}}

# 'Select' options {{{
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
    $mb->Login();

    my $countries = MusicBrainz::Server::Country->new($mb->{DBH});

    my @countries_menu = map {
        $_->GetId => $_->GetName
    } $countries->All;

    return \@countries_menu;   
}
# }}}

# validation {{{
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
# }}}

1;
