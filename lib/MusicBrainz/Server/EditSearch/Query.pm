package MusicBrainz::Server::EditSearch::Query;
use Moose;

use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MooseX::Types::Moose qw( Any ArrayRef Bool Maybe Str );
use MooseX::Types::Structured qw( Tuple );
use Moose::Util::TypeConstraints qw( enum role_type );
use MusicBrainz::Server::Constants qw( $LIMIT_FOR_EDIT_LISTING entities_with );
use MusicBrainz::Server::EditSearch::Predicate::Date;
use MusicBrainz::Server::EditSearch::Predicate::ID;
use MusicBrainz::Server::EditSearch::Predicate::Set;
use MusicBrainz::Server::EditSearch::Predicate::Entity;
use MusicBrainz::Server::EditSearch::Predicate::Editor;
use MusicBrainz::Server::EditSearch::Predicate::EditorFlag;
use MusicBrainz::Server::EditSearch::Predicate::VoteCount;
use MusicBrainz::Server::EditSearch::Predicate::AppliedEdits;
use MusicBrainz::Server::EditSearch::Predicate::Voter;
use MusicBrainz::Server::EditSearch::Predicate::ReleaseLanguage;
use MusicBrainz::Server::EditSearch::Predicate::ReleaseQuality;
use MusicBrainz::Server::EditSearch::Predicate::ArtistArea;
use MusicBrainz::Server::EditSearch::Predicate::LabelArea;
use MusicBrainz::Server::EditSearch::Predicate::ReleaseCountry;
use MusicBrainz::Server::EditSearch::Predicate::RelationshipType;
use MusicBrainz::Server::EditSearch::Predicate::EditNoteAuthor;
use MusicBrainz::Server::EditSearch::Predicate::EditNoteContent;
use MusicBrainz::Server::EditSearch::Predicate::EditSubscription;
use MusicBrainz::Server::Log qw( log_warning );
use Try::Tiny;

my %field_map = (
    id => 'MusicBrainz::Server::EditSearch::Predicate::ID',
    open_time => 'MusicBrainz::Server::EditSearch::Predicate::Date',
    close_time => 'MusicBrainz::Server::EditSearch::Predicate::Date',
    expire_time => 'MusicBrainz::Server::EditSearch::Predicate::Date',
    type => 'MusicBrainz::Server::EditSearch::Predicate::Set',
    status => 'MusicBrainz::Server::EditSearch::Predicate::Set',
    vote_count => 'MusicBrainz::Server::EditSearch::Predicate::VoteCount',
    editor => 'MusicBrainz::Server::EditSearch::Predicate::Editor',
    voter => 'MusicBrainz::Server::EditSearch::Predicate::Voter',
    release_language => 'MusicBrainz::Server::EditSearch::Predicate::ReleaseLanguage',
    release_quality => 'MusicBrainz::Server::EditSearch::Predicate::ReleaseQuality',
    artist_area => 'MusicBrainz::Server::EditSearch::Predicate::ArtistArea',
    label_area => 'MusicBrainz::Server::EditSearch::Predicate::LabelArea',
    release_country => 'MusicBrainz::Server::EditSearch::Predicate::ReleaseCountry',
    link_type => 'MusicBrainz::Server::EditSearch::Predicate::RelationshipType',
    editor_flag => 'MusicBrainz::Server::EditSearch::Predicate::EditorFlag',
    applied_edits => 'MusicBrainz::Server::EditSearch::Predicate::AppliedEdits',
    edit_note_author => 'MusicBrainz::Server::EditSearch::Predicate::EditNoteAuthor',
    edit_note_content => 'MusicBrainz::Server::EditSearch::Predicate::EditNoteContent',
    edit_subscription => 'MusicBrainz::Server::EditSearch::Predicate::EditSubscription',

    entities_with(['mbid', 'relatable'],
        take => sub {
            my ($type, $info) = @_;
            ($type => 'MusicBrainz::Server::EditSearch::Predicate::' . $info->{model})
        },
    ),
);

has negate => (
    isa => Bool,
    is => 'ro',
    default => 0
);

has combinator => (
    isa => enum([qw( or and )]),
    is => 'ro',
    required => 1,
    default => 'and'
);

has order => (
    isa => enum([qw( asc desc closed_asc closed_desc vote_closing_asc vote_closing_desc latest_note rand )]),
    is => 'ro',
    required => 1,
    default => 'desc'
);

has auto_edit_filter => (
    isa => Maybe[Bool],
    is => 'ro',
    default => undef
);

has where => (
    isa => ArrayRef[ Tuple[ Str, ArrayRef[Any] ] ],
    is => 'bare',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        where => 'elements',
        'add_where' => 'push',
    }
);

has fields => (
    isa => ArrayRef[ role_type('MusicBrainz::Server::EditSearch::Predicate') ],
    is => 'bare',
    required => 1,
    traits => [ 'Array' ],
    handles => {
        fields => 'elements',
    }
);

sub new_from_user_input {
    my ($class, $user_input, $user) = @_;
    my $input = expand_hash($user_input);
    my $ae = $input->{auto_edit_filter};
    $ae = undef if defined $ae && $ae =~ /^\s*$/;
    return $class->new(
        exists $input->{negation}   ? (negate => $input->{negation}) : (),
        exists $input->{combinator} ? (combinator => $input->{combinator}) : (),
        exists $input->{order}      ? (order => $input->{order}) : (),
        auto_edit_filter => $ae,
        fields => [
            map {
                $class->_construct_predicate($_, $user)
            } grep { defined } @{ $input->{conditions} }
        ]
    );
}

sub _construct_predicate {
    my ($class, $input, $user) = @_;
    return try {
        my $predicate_class = $field_map{$input->{field}} or die 'No predicate for field ' . $input->{field};
        $predicate_class->new_from_input(
            $input->{field},
            $input,
            $user,
        )
    } catch {
        my $err = $_;
        log_warning { "Unable to construct predicate from input ($err): $_" } $input;
        return ()
    };
}

sub valid {
    my $self = shift;
    my $valid = $self->fields > 0;
    $valid &&= $_->valid for $self->fields;
    return $valid
}

sub as_string {
    my $self = shift;
    $_->combine_with_query($self) for $self->fields;
    my $comb = $self->combinator;
    my $ae_predicate = defined $self->auto_edit_filter ?
        'autoedit = ? AND ' : '';

    my $order = '';
    my $extra_conditions = '';
    my $extra_joins = '';
    if ($self->order eq 'asc') {
        $order = 'ORDER BY edit.id ASC';
    } elsif ($self->order eq 'desc') {
        $order = 'ORDER BY edit.id DESC';
    } elsif ($self->order eq 'closed_asc') {
        $order = 'ORDER BY edit.close_time ASC';
        $extra_conditions = ' AND edit.close_time IS NOT NULL';
    } elsif ($self->order eq 'closed_desc') {
        $order = 'ORDER BY edit.close_time DESC';
        $extra_conditions = ' AND edit.close_time IS NOT NULL';
    } elsif ($self->order eq 'vote_closing_asc') {
        $order = 'ORDER BY edit.expire_time ASC';
        $extra_conditions = ' AND edit.close_time IS NULL';
    } elsif ($self->order eq 'vote_closing_desc') {
        $order = 'ORDER BY edit.expire_time DESC';
        $extra_conditions = ' AND edit.close_time IS NULL';
    } elsif ($self->order eq 'latest_note') {
        $order = 'ORDER BY s.latest_note DESC';
        $extra_conditions = ' AND s.latest_note IS NOT NULL';
        $extra_joins = 'JOIN (
            SELECT edit, MAX(post_time) AS latest_note
            FROM edit_note
            GROUP BY edit
            ) s ON s.edit = edit.id '
    }

    return 'SELECT edit.*, edit_data.data ' .
        'FROM edit JOIN edit_data ON edit.id = edit_data.edit ' .
        $extra_joins .
        'WHERE ' . $ae_predicate . ($self->negate ? 'NOT ' : '') . '(' .
            join(" $comb ", map { '(' . $_->[0] . ')' } $self->where) .
        ")
         $extra_conditions
         $order
         LIMIT $LIMIT_FOR_EDIT_LISTING";
}

sub arguments {
    my $self = shift;
    return (
        $self->auto_edit_filter // (),
        map { @{$_->[1]} } $self->where
    );
}

1;
