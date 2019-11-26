/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UserAccountLayout from '../components/UserAccountLayout';
import {withCatalystContext} from '../context';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import {FLUENCY_NAMES} from '../static/scripts/common/constants';
import commaList from '../static/scripts/common/i18n/commaList';
import expand2react from '../static/scripts/common/i18n/expand2react';
import bracketed, {bracketedText}
  from '../static/scripts/common/utility/bracketed';
import nonEmpty from '../static/scripts/common/utility/nonEmpty';
import {formatCount, formatPercentage} from '../statistics/utilities';
import formatUserDate from '../utility/formatUserDate';
import {canNominate} from '../utility/voting';

function generateUserTypesList(user: EditorT) {
  const typesList = [];
  if (user.deleted) {
    typesList.push(l('Deleted User'));
  }
  if (user.is_auto_editor) {
    typesList.push(exp.l(
      '{doc|Auto-Editor}',
      {doc: '/doc/Editor#Auto-editors'},
    ));
  }
  if (user.is_bot) {
    typesList.push(l('Internal/Bot'));
  }
  if (user.is_relationship_editor) {
    typesList.push(exp.l(
      '{doc|Relationship Editor}',
      {doc: '/doc/Editor#Relationship_editors'},
    ));
  }
  if (user.is_wiki_transcluder) {
    typesList.push(exp.l(
      '{doc|Transclusion Editor}',
      {doc: '/doc/Editor#Transclusion_editors'},
    ));
  }
  if (user.is_location_editor) {
    typesList.push(exp.l(
      '{doc|Location Editor}',
      {doc: '/doc/Editor#Location_editors'},
    ));
  }
  if (user.is_limited) {
    typesList.push(
      <span
        className="tooltip"
        title={l(
          `User accounts must be more than 2 weeks old, have a confirmed
           email address, and more than 10 accepted edits in order
           to vote on others' edits.`,
        )}
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
  <tr className={className || null}>
    <th>{name}</th>
    <td>{children}</td>
  </tr>
);

type UserProfileInformationProps = {
  +$c: CatalystContextT,
  +subscribed: boolean,
  +subscriberCount: number,
  +user: EditorT,
  +viewingOwnProfile: boolean,
};

const UserProfileInformation = withCatalystContext(({
  $c,
  subscribed,
  subscriberCount,
  user,
  viewingOwnProfile,
}: UserProfileInformationProps) => {
  const showBioAndURL = !user.is_limited || $c.user_exists;
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
            until you have confirmed your email.`)}
      </strong>
    ) : null;

  const encodedName = encodeURIComponent(user.name);

  return (
    <>
      <h2>{l('General Information')}</h2>

      <table className="profileinfo" role="presentation">
        <UserProfileProperty name={l('Email:')}>
          {user.email ? (
            <>
              {viewingOwnProfile ? user.email : l('(hidden)')}
              {' '}
              {user.email_confirmation_date ? (
                exp.l('(verified at {date})', {
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
                $c.user_exists ? (
                  bracketed(
                    <a href={`/user/${encodedName}/contact`}>
                      {l('send email')}
                    </a>,
                  )
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

        {user.gender ? (
          <UserProfileProperty name={l('Gender:')}>
            {l(user.gender.name)}
          </UserProfileProperty>
        ) : null}

        {user.area ? (
          <UserProfileProperty name={l('Location:')}>
            <DescriptiveLink entity={user.area} />
          </UserProfileProperty>
        ) : null}

        <UserProfileProperty name={l('Member since:')}>
          {memberSince}
        </UserProfileProperty>

        {$c.user && (viewingOwnProfile || $c.user.is_account_admin) ? (
          <UserProfileProperty name={l('Last login:')}>
            {user.last_login_date
              ? formatUserDate($c, user.last_login_date)
              : l("Hasn't logged in yet")}
          </UserProfileProperty>
        ) : null}

        {user.website ? (
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
          {$c.user_exists && !viewingOwnProfile ? (
            <>
              {' '}
              {bracketed(
                subscribed ? (
                  <a href={
                    `/account/subscriptions/editor/remove?id=${user.id}`}
                  >
                    {l('unsubscribe')}
                  </a>
                ) : (
                  <a href={
                    `/account/subscriptions/editor/add?id=${user.id}`}
                  >
                    {l('subscribe')}
                  </a>
                ),
              )}
            </>
          ) : null}
        </UserProfileProperty>

        {user.biography ? (
          <UserProfileProperty className="biography" name={l('Bio:')}>
            {showBioAndURL ? (
              expand2react(user.biography)
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

        {user.languages && user.languages.length > 0 ? (
          <UserProfileProperty name={l('Languages:')}>
            <ul className="inline">
              {user.languages.map(language => (
                <li key={language.language.id}>
                  {l_languages(language.language.name)}
                  {' '}
                  {bracketedText(FLUENCY_NAMES[language.fluency]())}
                </li>
              ))}
            </ul>
          </UserProfileProperty>
        ) : null}
      </table>
    </>
  );
});

type EditStatsT = {
  +accepted_auto_count: number,
  +accepted_count: number,
  +cancelled_count: number,
  +failed_count: number,
  +last_day_count: number,
  +open_count: number,
  +rejected_count: number,
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

type UserProfileStatisticsProps = {
  +$c: CatalystContextT,
  +editStats: EditStatsT,
  +user: EditorT,
  +votes: VoteStatsT,
};

const UserProfileStatistics = withCatalystContext(({
  $c,
  editStats,
  user,
  votes,
}: UserProfileStatisticsProps) => {
  const voteTotals = votes.pop();
  const encodedName = encodeURIComponent(user.name);
  const allAppliedCount = editStats.accepted_count +
                          editStats.accepted_auto_count;

  return (
    <>
      <h2>{l('Statistics')}</h2>

      <table className="statistics">
        <thead>
          <tr>
            <th colSpan="2">
              {exp.l(
                'Edits ({view_url|view})',
                {view_url: `/user/${encodedName}/edits`},
              )}
            </th>
          </tr>
        </thead>

        <tbody>
          <UserProfileProperty name={lp('Accepted', 'edit descriptor')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.accepted_count),
                view_url: `/user/${encodedName}/edits/accepted`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty name={l('Auto-edits')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.accepted_auto_count),
                view_url: `/user/${encodedName}/edits/autoedits`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty className="positive" name={l('Total applied')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, allAppliedCount),
                view_url: `/user/${encodedName}/edits/applied`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty className="negative" name={l('Voted down')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.rejected_count),
                view_url: `/user/${encodedName}/edits/rejected`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty name={l('Failed')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.failed_count),
                view_url: `/user/${encodedName}/edits/failed`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty name={l('Cancelled')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.cancelled_count),
                view_url: `/user/${encodedName}/edits/cancelled`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty name={l('Open')}>
            {exp.l(
              '{count} ({view_url|view})',
              {
                count: formatCount($c, editStats.open_count),
                view_url: `/user/${encodedName}/edits/open`,
              },
            )}
          </UserProfileProperty>

          <UserProfileProperty name={l('Last 24 hours')}>
            {exp.l('{count} ({view_url|view})', {
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
            })}
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
              {exp.l('Votes ({view_url|view})', {
                view_url: `/user/${encodedName}/votes`,
              })}
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
    </>
  );
});

type UserProfileProps = {
  +$c: CatalystContextT,
  +editStats: EditStatsT,
  +subscribed: boolean,
  +subscriberCount: number,
  +user: EditorT,
  +votes: VoteStatsT,
};

const UserProfile = ({
  $c,
  editStats,
  subscribed,
  subscriberCount,
  user,
  votes,
}: UserProfileProps) => {
  const viewingOwnProfile = !!$c.user && $c.user.id === user.id;
  const encodedName = encodeURIComponent(user.name);

  return (
    <UserAccountLayout entity={user} page="index">
      <UserProfileInformation
        subscribed={subscribed}
        subscriberCount={subscriberCount}
        user={user}
        viewingOwnProfile={viewingOwnProfile}
      />

      <UserProfileStatistics
        editStats={editStats}
        user={user}
        votes={votes}
      />

      {$c.user_exists && !viewingOwnProfile ? (
        <h2 style={{clear: 'both'}}>
          <a href={`/user/${encodedName}/report`}>
            {l('Report this user for bad behavior')}
          </a>
        </h2>
      ) : null}
    </UserAccountLayout>
  );
};

export default withCatalystContext(UserProfile);
