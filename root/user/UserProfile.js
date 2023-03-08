/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout, {
  sanitizedAccountLayoutUser,
} from '../components/UserAccountLayout.js';
import {CatalystContext, SanitizedCatalystContext} from '../context.mjs';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink.js';
import Warning from '../static/scripts/common/components/Warning.js';
import {FLUENCY_NAMES} from '../static/scripts/common/constants.js';
import * as TYPES from '../static/scripts/common/constants/editTypes.js';
import {compare} from '../static/scripts/common/i18n.js';
import commaList, {commaListText}
  from '../static/scripts/common/i18n/commaList.js';
import commaOnlyList from '../static/scripts/common/i18n/commaOnlyList.js';
import expand2react from '../static/scripts/common/i18n/expand2react.js';
import bracketed, {bracketedText}
  from '../static/scripts/common/utility/bracketed.js';
import escapeRegExp from '../static/scripts/common/utility/escapeRegExp.mjs';
import nonEmpty from '../static/scripts/common/utility/nonEmpty.js';
import {
  isAccountAdmin,
  isAddingNotesDisabled,
  isAutoEditor,
  isBot,
  isEditingDisabled,
  isLocationEditor,
  isRelationshipEditor,
  isSpammer,
  isUntrusted,
  isWikiTranscluder,
} from '../static/scripts/common/utility/privileges.js';
import {formatCount, formatPercentage} from '../statistics/utilities.js';
import formatUserDate from '../utility/formatUserDate.js';
import {returnToCurrentPage} from '../utility/returnUri.js';
import {canNominate} from '../utility/voting.js';

const ADDED_ENTITIES_TYPES = {
  area:         N_l('Area'),
  artist:       N_l('Artist'),
  cover_art:    N_l('Cover Art'),
  event:        N_l('Event'),
  instrument:   N_l('Instrument'),
  label:        N_l('Label'),
  place:        N_l('Place'),
  recording:    N_l('Recording'),
  release:      N_l('Release'),
  releasegroup: N_l('Release group'),
  series:       N_lp('Series', 'singular'),
  work:         N_l('Work'),
};

function generateUserTypesList(
  user: UnsanitizedEditorT,
): $ReadOnlyArray<VarSubstArg> {
  const typesList: Array<VarSubstArg> = [];
  if (user.deleted) {
    typesList.push(l('Deleted User'));
  }
  if (isAutoEditor(user)) {
    typesList.push(exp.l(
      '{doc|Auto-Editor}',
      {doc: '/doc/Editor#Auto-editors'},
    ));
  }
  if (isBot(user)) {
    typesList.push(l('Internal/Bot'));
  }
  if (isRelationshipEditor(user)) {
    typesList.push(exp.l(
      '{doc|Relationship Editor}',
      {doc: '/doc/Editor#Relationship_editors'},
    ));
  }
  if (isWikiTranscluder(user)) {
    typesList.push(exp.l(
      '{doc|Transclusion Editor}',
      {doc: '/doc/Editor#Transclusion_editors'},
    ));
  }
  if (isLocationEditor(user)) {
    typesList.push(exp.l(
      '{doc|Location Editor}',
      {doc: '/doc/Editor#Location_editors'},
    ));
  }
  if (user.is_limited) {
    typesList.push(
      <span
        className="tooltip"
        title={l('This user is new to MusicBrainz.')}
      >
        {l('Beginner')}
      </span>,
    );
  }
  // If no other types apply, then this is a normal user
  if (typesList.length === 0) {
    typesList.push(l('Normal User'));
  }

  return typesList;
}

type UserProfilePropertyProps = {
  +children: React.Node,
  +className?: string,
  +name: string,
};

const UserProfileProperty = ({
  children,
  className,
  name,
}: UserProfilePropertyProps) => (
  <tr className={nonEmpty(className) ? className : null}>
    <th>{name}</th>
    <td>{children}</td>
  </tr>
);

type UserProfileInformationProps = {
  +applicationCount: number,
  +ipHashes: $ReadOnlyArray<string>,
  +subscribed: boolean,
  +subscriberCount: number,
  +tokenCount: number,
  +user: UnsanitizedEditorT,
  +viewingOwnProfile: boolean,
};

const UserProfileInformation = ({
  applicationCount,
  ipHashes,
  subscribed,
  subscriberCount,
  tokenCount,
  user,
  viewingOwnProfile,
}: UserProfileInformationProps) => {
  const $c = React.useContext(CatalystContext);
  const showBioAndURL = !!(!user.is_limited || $c.user);
  let memberSince;
  if (user.name === 'rob') {
    memberSince = l('The Dawn of the Project');
  } else if (user.is_charter) {
    memberSince = l('The early days of the project');
  } else {
    memberSince = formatUserDate($c, user.registration_date);
  }

  const noEmailWarning = (viewingOwnProfile &&
    $c.user && !$c.user.has_confirmed_email_address) ? (
      <strong>
        {l(`Your homepage and biography will not show
            until you have completed the email verification process.`)}
      </strong>
    ) : null;

  const encodedName = encodeURIComponent(user.name);

  const {
    area,
    biography,
    email,
    gender,
    languages,
  } = user;

  const viewingUser = $c.user;

  return (
    <>
      <h2>{l('General Information')}</h2>

      <table className="profileinfo" role="presentation">
        <UserProfileProperty name={l('Email:')}>
          {user.has_email_address ? (
            <>
              {viewingOwnProfile ? email : l('(hidden)')}
              {' '}
              {nonEmpty(user.email_confirmation_date) ? (
                texp.l('(verified at {date})', {
                  date: formatUserDate($c, user.email_confirmation_date),
                })
              ) : (
                <>
                  {exp.l('(<strong>unverified!</strong>)')}
                  {' '}
                  {noEmailWarning}
                </>
              )}
              {' '}
              {viewingOwnProfile ? (
                bracketed(
                  <a href="/account/resend-verification">
                    {l('resend verification email')}
                  </a>,
                )
              ) : (
                $c.user && !isAddingNotesDisabled($c.user) ? (
                  <>
                    {bracketed(
                      <a href={`/user/${encodedName}/contact`}>
                        {l('send email')}
                      </a>,
                    )}
                    {(nonEmpty(email) && isAccountAdmin(viewingUser)) ? (
                      <form action="/admin/email-search" method="post">
                        <input
                          name="emailsearch.email"
                          type="hidden"
                          value={escapeRegExp(email)}
                        />
                        <button
                          name="emailsearch.submit"
                          type="submit"
                          value="1"
                        >
                          {l('find all users of this email')}
                        </button>
                      </form>
                    ) : null}
                  </>
                ) : null
              )}
            </>
          ) : (
            <>
              {lp('(none)', 'email')}
              {' '}
              {noEmailWarning}
            </>
          )}
        </UserProfileProperty>

        <UserProfileProperty name={l('User type:')}>
          {commaList(generateUserTypesList(user))}
          {' '}
          {canNominate($c.user, user) ? (
            bracketed(
              <a href={`/elections/nominate/${encodedName}`}>
                {l('nominate for auto-editor')}
              </a>,
            )
          ) : null}
        </UserProfileProperty>

        {nonEmpty(user.age) ? (
          <UserProfileProperty name={l('Age:')}>
            {user.age}
          </UserProfileProperty>
        ) : null}

        {gender ? (
          <UserProfileProperty name={l('Gender:')}>
            {lp_attributes(gender.name, 'gender')}
          </UserProfileProperty>
        ) : null}

        {area ? (
          <UserProfileProperty name={l('Location:')}>
            <DescriptiveLink entity={area} />
          </UserProfileProperty>
        ) : null}

        <UserProfileProperty name={l('Member since:')}>
          {memberSince}
        </UserProfileProperty>

        {(viewingOwnProfile || isAccountAdmin(viewingUser)) ? (
          <>
            <UserProfileProperty name={l('Last login:')}>
              {nonEmpty(user.last_login_date)
                ? formatUserDate($c, user.last_login_date)
                : l("Hasn't logged in yet")}
            </UserProfileProperty>

            {tokenCount ? (
              <UserProfileProperty
                name={addColonText(l('Authorized applications'))}
              >
                {tokenCount}
                {viewingOwnProfile ? (
                  <>
                    {' '}
                    <a href="/account/applications" rel="nofollow">
                      {bracketedText(l('see list'))}
                    </a>
                  </>
                ) : null}
              </UserProfileProperty>
            ) : null}

            {applicationCount ? (
              <UserProfileProperty
                name={addColonText(l('Developer applications'))}
              >
                {applicationCount}
                {viewingOwnProfile ? (
                  <>
                    {' '}
                    <a href="/account/applications" rel="nofollow">
                      {bracketedText(l('see list'))}
                    </a>
                  </>
                ) : null}
              </UserProfileProperty>
            ) : null}
          </>
        ) : null}

        {nonEmpty(user.website) ? (
          <UserProfileProperty name={l('Homepage:')}>
            {showBioAndURL ? (
              <a href={user.website} rel="nofollow">
                {user.website}
              </a>
            ) : (
              <div className="deleted">
                {exp.l(
                  `This content is hidden to prevent spam.
                   To view it, please {url|log in}.`,
                  {url: '/account/login'},
                )}
              </div>
            )}
          </UserProfileProperty>
        ) : null}

        {user.deleted ? null : (
          <UserProfileProperty name={l('Subscribers:')}>
            {subscriberCount ? (
              exp.l(
                '{count} ({url|view list})',
                {
                  count: subscriberCount,
                  url: `/user/${encodedName}/subscribers`,
                },
              )
            ) : (
              l('0')
            )}
            {$c.user && !viewingOwnProfile ? (
              <>
                {' '}
                {bracketed(
                  subscribed ? (
                    <a
                      href={
                        `/account/subscriptions/editor/remove?id=${user.id}` +
                        '&' + returnToCurrentPage($c)
                      }
                    >
                      {l('unsubscribe')}
                    </a>
                  ) : (
                    <a
                      href={
                        `/account/subscriptions/editor/add?id=${user.id}` +
                        '&' + returnToCurrentPage($c)
                      }
                    >
                      {l('subscribe')}
                    </a>
                  ),
                )}
              </>
            ) : null}
          </UserProfileProperty>
        )}

        {nonEmpty(biography) ? (
          <UserProfileProperty className="biography" name={l('Bio:')}>
            {showBioAndURL ? (
              expand2react(biography)
            ) : (
              <div className="deleted">
                {exp.l(
                  `This content is hidden to prevent spam.
                   To view it, please {url|log in}.`,
                  {url: '/account/login'},
                )}
              </div>
            )}
          </UserProfileProperty>
        ) : null}

        {languages?.length ? (
          <UserProfileProperty name={l('Languages:')}>
            <ul className="inline">
              {languages.map(language => (
                <li key={language.language.id}>
                  {l_languages(language.language.name)}
                  {' '}
                  {bracketedText(FLUENCY_NAMES[language.fluency]())}
                </li>
              ))}
            </ul>
          </UserProfileProperty>
        ) : null}

        {isAccountAdmin($c.user) && ipHashes.length ? (
          <UserProfileProperty name={addColonText(l('IP lookup'))}>
            <ul className="inline">
              {commaOnlyList(ipHashes.map(ipHash => (
                <a
                  href={'/admin/ip-lookup/' + encodeURIComponent(ipHash)}
                  key={ipHash}
                >
                  {ipHash.substring(0, 7)}
                </a>
              )))}
            </ul>
          </UserProfileProperty>
        ) : null}
      </table>
    </>
  );
};

type UserEditsPropertyProps = {
  +addedEntities: number,
  +entityType: string,
  +name: string,
  +user: UnsanitizedEditorT,
};

const UserEditsProperty = ({
  addedEntities,
  entityType,
  name,
  user,
}: UserEditsPropertyProps) => {
  const $c = React.useContext(CatalystContext);
  const encodedName = encodeURIComponent(user.name);
  const createEditTypes: string = entityType === 'cover_art'
    ? String(TYPES.EDIT_RELEASE_ADD_COVER_ART)
    : entityType === 'release' ? (
      // Also list historical edits
      [
        TYPES.EDIT_RELEASE_CREATE,
        TYPES.EDIT_HISTORIC_ADD_RELEASE,
      ].join(',')
    ) : String(TYPES[`EDIT_${entityType.toUpperCase()}_CREATE`]);
  const searchEditsURL = ((createEditTypes: string) => (
    '/search/edits' +
    '?auto_edit_filter=' +
    '&conditions.0.field=editor' +
    '&conditions.0.operator=%3D' +
    `&conditions.0.name=${encodedName}` +
    `&conditions.0.args.0=${user.id}` +
    '&combinator=and' +
    '&conditions.1.field=type' +
    '&conditions.1.operator=%3D' +
    '&conditions.1.args=' + createEditTypes +
    '&conditions.2.field=status' +
    '&conditions.2.operator=%3D' +
    '&conditions.2.args=2' +
    '&negation=0' +
    '&order=desc'
  ));
  return (
    <UserProfileProperty name={name}>
      {$c.user ? (exp.l('{count} ({view_url|view})', {
        count: formatCount($c, addedEntities),
        view_url: searchEditsURL(createEditTypes),
      })) : formatCount($c, addedEntities)}
    </UserProfileProperty>
  );
};

type EditStatsT = {
  +accepted_auto_count: number,
  +accepted_count: number,
  +cancelled_count: number,
  +failed_count: number,
  +last_day_count: number,
  +open_count: number,
  +rejected_count: number,
};

type SecondaryStatsT = {
  +downvoted_tag_count?: number,
  +rating_count?: number,
  +upvoted_tag_count?: number,
};

type VoteStatsT = Array<{
  +all: {
    +count: number,
    +percentage: number,
  },
  +name: string,
  +recent: {
    +count: number,
    +percentage: number,
  },
}>;

type EntitiesStatsT = {
  +area: number,
  +artist: number,
  +cover_art: number,
  +event: number,
  +instrument: number,
  +label: number,
  +place: number,
  +recording: number,
  +release: number,
  +releasegroup: number,
  +series: number,
  +work: number,
};

type UserProfileStatisticsProps = {
  +addedEntities: EntitiesStatsT,
  +editStats: EditStatsT,
  +secondaryStats: SecondaryStatsT,
  +user: UnsanitizedEditorT,
  +votes: VoteStatsT,
};

const UserProfileStatistics = ({
  editStats,
  user,
  votes,
  secondaryStats,
  addedEntities,
}: UserProfileStatisticsProps) => {
  const $c = React.useContext(CatalystContext);
  const voteTotals = votes.pop();
  const encodedName = encodeURIComponent(user.name);
  const allAppliedCount = editStats.accepted_count +
                          editStats.accepted_auto_count;
  const allEditsCount = allAppliedCount +
                        editStats.rejected_count +
                        editStats.failed_count +
                        editStats.cancelled_count +
                        editStats.open_count;
  const hasAddedEntities =
    Object.values(addedEntities).some((number) => number !== 0);
  const hasPublicRatings = secondaryStats.rating_count != null;
  const hasPublicTags = secondaryStats.upvoted_tag_count != null;
  const ratingCount = secondaryStats.rating_count ?? 0;
  const upvotedTagCount = secondaryStats.upvoted_tag_count ?? 0;
  const downvotedTagCount = secondaryStats.downvoted_tag_count ?? 0;

  return (
    <>
      <h2>{l('Statistics')}</h2>

      <table className="statistics">
        <thead>
          <tr>
            <th colSpan="2">
              {l('Edits')}
            </th>
          </tr>
        </thead>

        <tbody>
          <UserProfileProperty name={lp('Total', 'edit descriptor')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, allEditsCount),
                view_url: `/user/${encodedName}/edits`,
              },
            ) : formatCount($c, allEditsCount)}
          </UserProfileProperty>

          <UserProfileProperty name={lp('Accepted', 'edit descriptor')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.accepted_count),
                view_url: `/user/${encodedName}/edits/accepted`,
              },
            ) : formatCount($c, editStats.accepted_count)}
          </UserProfileProperty>

          <UserProfileProperty name={l('Auto-edits')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.accepted_auto_count),
                view_url: `/user/${encodedName}/edits/autoedits`,
              },
            ) : formatCount($c, editStats.accepted_auto_count)}
          </UserProfileProperty>

          <UserProfileProperty className="positive" name={l('Total applied')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, allAppliedCount),
                view_url: `/user/${encodedName}/edits/applied`,
              },
            ) : formatCount($c, allAppliedCount)}
          </UserProfileProperty>

          <UserProfileProperty className="negative" name={l('Voted down')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.rejected_count),
                view_url: `/user/${encodedName}/edits/rejected`,
              },
            ) : formatCount($c, editStats.rejected_count)}
          </UserProfileProperty>

          <UserProfileProperty name={l('Failed')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.failed_count),
                view_url: `/user/${encodedName}/edits/failed`,
              },
            ) : formatCount($c, editStats.failed_count)}
          </UserProfileProperty>

          <UserProfileProperty name={l('Cancelled')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.cancelled_count),
                view_url: `/user/${encodedName}/edits/cancelled`,
              },
            ) : formatCount($c, editStats.cancelled_count)}
          </UserProfileProperty>

          <UserProfileProperty name={l('Open')}>
            {$c.user ? exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.open_count),
                view_url: `/user/${encodedName}/edits/open`,
              },
            ) : formatCount($c, editStats.open_count)}
          </UserProfileProperty>

          <UserProfileProperty name={l('Last 24 hours')}>
            {$c.user ? exp.l('{count} ({view_url|view})', {
              count: formatCount($c, editStats.last_day_count),
              view_url: (
                '/search/edits' +
                '?conditions.1.operator=%3E' +
                '&conditions.1.field=open_time' +
                '&conditions.1.args.0=24+hours+ago' +
                '&combinator=and' +
                `&conditions.0.name=${encodedName}` +
                '&conditions.0.field=editor' +
                '&order=desc' +
                `&conditions.0.args.0=${user.id}` +
                '&conditions.0.operator=%3D' +
                '&negation=0' +
                '&auto_edit_filter='
              ),
            }) : formatCount($c, editStats.last_day_count)}
          </UserProfileProperty>
        </tbody>
      </table>

      <table
        className="statistics"
        title={l('This table shows a summary of votes cast by this editor.')}
      >
        <thead>
          <tr>
            <th colSpan="3">
              {$c.user ? exp.l('Votes ({view_url|view})', {
                view_url: `/user/${encodedName}/votes`,
              }) : l('Votes')}
            </th>
          </tr>
          <tr>
            <th id="table_vote_summary_vote" />
            <th id="table_vote_summary_recent">
              {l('Last 28 days')}
            </th>
            <th id="table_vote_summary_overall">
              {l('Overall')}
            </th>
          </tr>
        </thead>
        <tbody>
          {votes.map(voteStat => (
            <tr key={voteStat.name}>
              <th headers="table_vote_summary_vote">
                {voteStat.name}
              </th>
              <td headers="table_vote_summary_recent">
                {formatCount($c, voteStat.recent.count)}
                {' '}
                {bracketedText(
                  formatPercentage($c, voteStat.recent.percentage / 100, 0),
                )}
              </td>
              <td headers="table_vote_summary_overall">
                {formatCount($c, voteStat.all.count)}
                {' '}
                {bracketedText(
                  formatPercentage($c, voteStat.all.percentage / 100, 0),
                )}
              </td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr>
            <th headers="table_vote_summary_vote">
              {voteTotals.name}
            </th>
            <th className="totals" headers="table_vote_summary_recent">
              {formatCount($c, voteTotals.recent.count)}
              {' '}
              {bracketedText(formatPercentage($c, 1, 0))}
            </th>
            <th className="totals" headers="table_vote_summary_overall">
              {formatCount($c, voteTotals.all.count)}
              {' '}
              {bracketedText(formatPercentage($c, 1, 0))}
            </th>
          </tr>
        </tfoot>
      </table>

      <table
        className="statistics"
        title={l('This table shows a summary ' +
                 'of entities added by this editor.')}
      >
        <thead>
          <tr>
            <th colSpan={hasAddedEntities ? '2' : null}>
              <abbr title={l('Newly applied edits may ' +
                             'need 24 hours to appear')}
              >
                {l('Added entities')}
              </abbr>
            </th>
          </tr>
        </thead>
        <tbody>
          {hasAddedEntities ? (
            Object.keys(ADDED_ENTITIES_TYPES)
              .filter(type => (addedEntities[type] !== 0))
              .map(type => [type, ADDED_ENTITIES_TYPES[type]()])
              .sort((a, b) => compare(a[1], b[1]))
              .map(([entityType, entityTypeName]) => (
                <UserEditsProperty
                  addedEntities={addedEntities[entityType]}
                  entityType={entityType}
                  key={entityType}
                  name={entityTypeName}
                  user={user}
                />
              ))
          ) : (
            <tr>
              <td>
                {l('This user has not created any entities.')}
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {hasPublicTags || hasPublicRatings ? (
        <table
          className="statistics"
          title={l('This table shows a summary ' +
                  'of secondary data added by this editor.')}
        >
          <thead>
            <tr>
              <th colSpan="2">
                {l('Tags and ratings')}
              </th>
            </tr>
          </thead>
          <tbody>
            {hasPublicTags ? (
              <>
                <UserProfileProperty name={l('Tags upvoted')}>
                  {$c.user && upvotedTagCount > 0 ? exp.l(
                    '{count} ({view_url|view})',
                    {
                      count: formatCount($c, upvotedTagCount),
                      view_url: `/user/${encodedName}/tags`,
                    },
                  ) : formatCount($c, upvotedTagCount)}
                </UserProfileProperty>

                <UserProfileProperty name={l('Tags downvoted')}>
                  {$c.user && downvotedTagCount > 0 ? exp.l(
                    '{count} ({view_url|view})',
                    {
                      count: formatCount($c, downvotedTagCount),
                      view_url: `/user/${encodedName}/tags?show_downvoted=1`,
                    },
                  ) : formatCount($c, downvotedTagCount)}
                </UserProfileProperty>
              </>
            ) : null}
            {hasPublicRatings ? (
              <UserProfileProperty name={l('Ratings')}>
                {$c.user && ratingCount > 0 ? exp.l(
                  '{count} ({view_url|view})',
                  {
                    count: formatCount($c, ratingCount),
                    view_url: `/user/${encodedName}/ratings`,
                  },
                ) : formatCount($c, ratingCount)}
              </UserProfileProperty>
            ) : null}
          </tbody>
        </table>
      ) : null}
    </>
  );
};

type UserProfileProps = {
  +addedEntities: EntitiesStatsT,
  +applicationCount: number,
  +editStats: EditStatsT,
  +ipHashes: $ReadOnlyArray<string>,
  +secondaryStats: SecondaryStatsT,
  +subscribed: boolean,
  +subscriberCount: number,
  +tokenCount: number,
  +user: UnsanitizedEditorT,
  +votes: VoteStatsT,
};

const UserProfile = ({
  applicationCount,
  editStats,
  ipHashes,
  secondaryStats,
  subscribed,
  subscriberCount,
  tokenCount,
  user,
  votes,
  addedEntities,
}: UserProfileProps): React.Element<typeof UserAccountLayout> => {
  const $c = React.useContext(SanitizedCatalystContext);
  const viewingOwnProfile = $c.user != null && $c.user.id === user.id;
  const adminViewing = $c.user != null && isAccountAdmin($c.user);
  const encodedName = encodeURIComponent(user.name);
  const restrictions = [];
  if (adminViewing) {
    if (isEditingDisabled(user)) {
      restrictions.push(l('Editing/voting disabled'));
    }
    if (isAddingNotesDisabled(user)) {
      restrictions.push(l('Edit notes disabled'));
    }
    if (isUntrusted(user)) {
      restrictions.push(l('Untrusted'));
    }
  }

  return (
    <UserAccountLayout
      entity={sanitizedAccountLayoutUser(user)}
      page="index"
    >
      {isSpammer(user) && !adminViewing ? (
        <>
          <h2>{l('Blocked Spam Account')}</h2>
          <p>
            {l(`This user was blocked and their profile is hidden
                because they were deemed to be spamming.
                If you see spam in MusicBrainz, please do let us know
                by reporting the spammer from their user page.`)}
          </p>
        </>
      ) : (
        <>
          {isSpammer(user) && adminViewing ? (
            <Warning
              message={
                l(`This user is marked as a spammer and is blocked
                   for all non-admin users.`)
              }
            />
          ) : null}

          {restrictions.length && adminViewing ? (
            <Warning
              message={
                texp.l(
                  `This user’s editing rights have been restricted.
                   Active restrictions: {restrictions}.`,
                  {
                    restrictions: commaListText(restrictions),
                  },
                )
              }
            />
          ) : null}

          <UserProfileInformation
            applicationCount={applicationCount}
            ipHashes={ipHashes}
            subscribed={subscribed}
            subscriberCount={subscriberCount}
            tokenCount={tokenCount}
            user={user}
            viewingOwnProfile={viewingOwnProfile}
          />

          <UserProfileStatistics
            addedEntities={addedEntities}
            editStats={editStats}
            secondaryStats={secondaryStats}
            user={user}
            votes={votes}
          />

          {$c.user && !viewingOwnProfile && !user.deleted ? (
            <h2 style={{clear: 'both'}}>
              <a href={`/user/${encodedName}/report`}>
                {l('Report this user for bad behavior')}
              </a>
            </h2>
          ) : null}
        </>
      )}
    </UserAccountLayout>
  );
};

export default UserProfile;
