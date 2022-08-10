/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Layout from '../layout/index.js';

type VotingGuideRowProps = {
  +guideName: string,
  +mainUrl: string,
  +showSubscribedArtistsUrl?: boolean,
};

const VotingGuideRow = ({
  guideName,
  mainUrl,
  showSubscribedArtistsUrl = false,
}: VotingGuideRowProps) => {
  const subscribedArtistsCondition =
    '&conditions.9.field=artist&conditions.9.operator=subscribed';
  return (
    <li>
      <a href={mainUrl}>
        {guideName}
      </a>
      {showSubscribedArtistsUrl ? (
        <ul>
          <li>
            <a href={mainUrl + subscribedArtistsCondition}>
              {l('…related to artists in my subscriptions')}
            </a>
          </li>
        </ul>
      ) : null}
    </li>
  );
};

const VotingIndex = (): React.Element<typeof Layout> => (
  <Layout fullWidth title={l('Voting suggestions')}>
    <div id="content">
      <h1>{l('Voting suggestions')}</h1>

      <p>
        {exp.l(
          `If you’d like to help ensuring the changes made to MusicBrainz data
           are correct, but do not know where to start, the following
           suggestions should be useful. These are pre-defined
           {edit_search|edit searches}; once you’re comfortable with the edit
           search you can refine them further or just create your own personal
           searches and bookmark them for your own use!`,
          {edit_search: '/search/edits'},
        )}
      </p>
      <p>
        {exp.l(
          `While reviewing the work of your fellow editors, always keep the
           {coc|Code of Conduct} in mind. Almost all editors want to help, so
           your goal as a voter is to help them help better. This applies even
           more for beginners: always try to be helpful and patient with them,
           even if they are making mistakes, so that they’ll hopefully grow
           into better editors! That said, if you find an editor that seems
           to be vandalizing the data, you can always report them
           from their profile.`,
          {coc: '/doc/Code_of_Conduct'},
        )}
      </p>
      <p>
        {l(
          `By default, these searches skip your own edits and edits you have
           already voted on (when relevant). To change that, load the search
           and then remove the conditions “Editor is not me” and “Voter is me
           and voted No vote”, respectively.`,
        )}
      </p>

      <h2>{l('Destructive edits')}</h2>
      <p>
        {l(
          `Destructive edits (removals and merges) are often very hard or even
           impossible to revert. As such, an incorrect destructive edit that
           applies unnoticed can cause quite a big mess! Most are guaranteed
           to remain open for at least two full days even if they get three
           “Yes” votes, to avoid them closing too quickly, but it’s always
           good to get more eyes on them. Below you can find four different
           searches: one for all destructive edits (which might be
           overwhelming sometimes), one for entity merges and removals only
           (the edits more likely to cause a mess if they incorrectly go
           through), one for relationship removals only, and one for
           destructive changes to releases (track, medium and release label
           removals).`,
        )}
      </p>
      <ul>
        {/* eslint-disable max-len */}
        <VotingGuideRow
          guideName={l('All open destructive edits')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=9&conditions.0.args=84&conditions.0.args=4&conditions.0.args=153&conditions.0.args=134&conditions.0.args=14&conditions.0.args=64&conditions.0.args=74&conditions.0.args=24&conditions.0.args=225%2C223%2C311&conditions.0.args=143&conditions.0.args=44&conditions.0.args=83&conditions.0.args=3&conditions.0.args=315&conditions.0.args=152&conditions.0.args=133&conditions.0.args=78&conditions.0.args=410&conditions.0.args=13&conditions.0.args=53&conditions.0.args=63&conditions.0.args=73&conditions.0.args=23&conditions.0.args=36&conditions.0.args=224&conditions.0.args=142&conditions.0.args=211&conditions.0.args=43&conditions.0.args=47&' +
            'conditions.1.field=status&conditions.1.operator=%3D&conditions.1.args=1&' +
            'conditions.2.field=editor&conditions.2.operator=not_me&conditions.2.name=&conditions.2.args.0=&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open entity merges and removals')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=84&conditions.0.args=4&conditions.0.args=153&conditions.0.args=134&conditions.0.args=14&conditions.0.args=64&conditions.0.args=74&conditions.0.args=24&conditions.0.args=143&conditions.0.args=44&conditions.0.args=83&conditions.0.args=3&conditions.0.args=152&conditions.0.args=133&conditions.0.args=13&conditions.0.args=63&conditions.0.args=73&conditions.0.args=310%2C212&conditions.0.args=23&conditions.0.args=142&conditions.0.args=43&' +
            'conditions.1.field=status&conditions.1.operator=%3D&conditions.1.args=1&' +
            'conditions.2.field=editor&conditions.2.operator=not_me&conditions.2.name=&conditions.2.args.0=&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open relationship removals')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=92%2C235&' +
            'conditions.1.field=status&conditions.1.operator=%3D&conditions.1.args=1&' +
            'conditions.2.field=editor&conditions.2.operator=not_me&conditions.2.name=&conditions.2.args.0=&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open destructive changes to releases')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=53&conditions.0.args=36&conditions.0.args=211&' +
            'conditions.1.field=status&conditions.1.operator=%3D&conditions.1.args=1&' +
            'conditions.2.field=editor&conditions.2.operator=not_me&conditions.2.name=&conditions.2.args.0=&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        {/* eslint-enable max-len */}
      </ul>

      <h2>{l('Unreviewed and potentially problematic edits')}</h2>
      <p>
        {l(
          `Edits that nobody have seen can always benefit from a quick check:
           even if you’re not familiar with the music in question, you might
           be able to notice that something seems wrong. Don’t forget you
           don’t need to vote on every edit: it’s perfectly fine to just
           abstain if you feel something doesn’t seem wrong but it’s also not
           100% obvious that it is right without further checks.`,
        )}
      </p>
      <ul>
        {/* eslint-disable max-len */}
        <VotingGuideRow
          guideName={l('Unreviewed edits (0 votes) that will close in less than a day')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=open_time&conditions.1.operator=<&conditions.1.args.0=6+days+ago&conditions.1.args.1=&' +
            'conditions.2.field=vote_count&conditions.2.vote=1&conditions.2.operator=%3D&conditions.2.args.0=0&conditions.2.args.1=&' +
            'conditions.3.field=vote_count&conditions.3.vote=0&conditions.3.operator=%3D&conditions.3.args.0=0&conditions.3.args.1=&' +
            'conditions.4.field=vote_count&conditions.4.vote=-1&conditions.4.operator=%3D&conditions.4.args.0=0&conditions.4.args.1=&' +
            'conditions.5.field=editor&conditions.5.operator=not_me&conditions.5.name=&conditions.5.args.0='}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open unreviewed edits (0 votes)')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=vote_count&conditions.1.vote=1&conditions.1.operator=%3D&conditions.1.args.0=0&conditions.1.args.1=&' +
            'conditions.2.field=vote_count&conditions.2.vote=0&conditions.2.operator=%3D&conditions.2.args.0=0&conditions.2.args.1=&' +
            'conditions.3.field=vote_count&conditions.3.vote=-1&conditions.3.operator=%3D&conditions.3.args.0=0&conditions.3.args.1=&' +
            'conditions.4.field=editor&conditions.4.operator=not_me&conditions.4.name=&conditions.4.args.0='}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open unconfirmed edits (“Abstain” votes only) that will close in less than a day')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=open_time&conditions.1.operator=<&conditions.1.args.0=6+days+ago&conditions.1.args.1=&' +
            'conditions.2.field=vote_count&conditions.2.vote=1&conditions.2.operator=%3D&conditions.2.args.0=0&conditions.2.args.1=&' +
            'conditions.3.field=vote_count&conditions.3.vote=0&conditions.3.operator=%3D&conditions.3.args.0=0&conditions.3.args.1=&' +
            'conditions.4.field=editor&conditions.4.operator=not_me&conditions.4.name=&conditions.4.args.0='}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open unconfirmed edits (“Abstain” votes only)')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=vote_count&conditions.1.vote=1&conditions.1.operator=%3D&conditions.1.args.0=0&conditions.1.args.1=&' +
            'conditions.2.field=vote_count&conditions.2.vote=0&conditions.2.operator=%3D&conditions.2.args.0=0&conditions.2.args.1=&' +
            'conditions.3.field=editor&conditions.3.operator=not_me&conditions.3.name=&conditions.3.args.0='}
          showSubscribedArtistsUrl
        />
        {/* eslint-enable max-len */}
      </ul>
      <p>
        {l(
          `Edits that have already received “No” votes are also ones likely
           to benefit from more eyes on them, to either confirm the edit is 
           indeed incorrect or to add a dissenting opinion to the current
           “No” vote. Similarly, edits with both “Yes” and “No” votes are
           likely to benefit from more opinions to push them to one side or
           the other. As always, remember to be polite, even if you disagree
           with a voter!`,
        )}
      </p>
      <ul>
        {/* eslint-disable max-len */}
        <VotingGuideRow
          guideName={l('Open edits with at least 1 “No” vote')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=vote_count&conditions.1.vote=0&conditions.1.operator=>&conditions.1.args.0=0&conditions.1.args.1=&' +
            'conditions.2.field=editor&conditions.2.operator=not_me&conditions.2.name=&conditions.2.args.0=&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('Open edits with both “Yes” and “No” votes (controversial edits)')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=vote_count&conditions.1.vote=0&conditions.1.operator=>&conditions.1.args.0=0&conditions.1.args.1=&' +
            'conditions.2.field=vote_count&conditions.2.vote=1&conditions.2.operator=>&conditions.2.args.0=0&conditions.2.args.1=&' +
            'conditions.3.field=editor&conditions.3.operator=not_me&conditions.3.name=&conditions.3.args.0=&' +
            'conditions.4.field=voter&conditions.4.operator=me&conditions.4.name=&conditions.4.voter_id=&conditions.4.args=no'}
          showSubscribedArtistsUrl
        />
        {/* eslint-enable max-len */}
      </ul>

      <h2>{l('Edits by beginners')}</h2>
      <p>
        {exp.l(
          `Beginner editors are the ones most likely to need a friendly eye on
           their edits. When reviewing these, look for cases where the editor
           is making edits that go against the MusicBrainz guidelines, or seem
           otherwise wrong, and leave notes guiding the editor so that they
           can do better in the future. Make sure to link to the appropriate
           guidelines, or to relevant examples of well-entered data, and above
           all remember to be nice. Chances are if these users are making a
           terrible mess, they’re not doing it on purpose but out of
           confusion: MusicBrainz can be daunting for newcomers! If at all
           possible, fix the errors (and let the editor know that you’ve done
           that and that they can check the edits you made to see how it
           should look like) rather than voting “No” on edits, since “No”
           votes can be quite discouraging, especially as a new editor.
           If something is just so bad that there’s no fixing it and it is
           making the existing data worse, do vote against the edit, but
           make sure to explain nicely why that is needed, rather than just
           silently “No”-voting. For a longer overview of the attitude we’re
           hoping for, see {voting_blog|this blog post about voting}.
           Also, if a beginner is making especially good edits,
           you might want to let them know so they’ll feel good about it!`,
          {
            voting_blog: 'https://blog.metabrainz.org/2015/01/09/editing-making-musicbrainz-better/',
          },
        )}
      </p>
      <p>
        {l(
          `The filters for edits you haven’t voted on yet below will only show
           open edits (since you can’t vote on closed edits anyway).
           That said, a fair amount of edits that auto-apply might still be
           worth reviewing when entered by beginners, so consider
           checking those too!`,
        )}
      </p>
      <p>
        {l(
          `Specific searches are provided for edits adding releases/mediums,
           which are probably the most complex and as such reasonably likely
           to have issues, plus for edits adding artists, which might include
           artists trying to add their own data and not doing
           a great job of it.`,
        )}
      </p>

      <ul>
        {/* eslint-disable max-len */}
        <VotingGuideRow
          guideName={l('All edits from beginner editors')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=editor&conditions.0.operator=limited&conditions.0.name=&conditions.0.args.0=&' +
            'conditions.1.field=voter&conditions.1.operator=me&conditions.1.name=&conditions.1.voter_id=&conditions.1.args=no&' +
            'conditions.2.field=status&conditions.2.operator=%3D&conditions.2.args=1'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All edits from beginner editors made less than 2 weeks ago')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=editor&conditions.0.operator=limited&conditions.0.name=&conditions.0.args.0=&' +
            'conditions.1.field=open_time&conditions.1.operator=>&conditions.1.args.0=2+weeks+ago&conditions.1.args.1=&' +
            'conditions.2.field=status&conditions.2.operator=%3D&conditions.2.args=1&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All "Add release/medium" edits by beginner editors')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=editor&conditions.0.operator=limited&conditions.0.name=&conditions.0.args.0=&' +
            'conditions.1.field=type&conditions.1.operator=%3D&conditions.1.args=51&conditions.1.args=31%2C216'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All "Add release/medium" edits by beginner editors made less than 2 weeks ago')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=editor&conditions.0.operator=limited&conditions.0.name=&conditions.0.args.0=&' +
            'conditions.1.field=type&conditions.1.operator=%3D&conditions.1.args=51&conditions.1.args=31%2C216&' +
            'conditions.2.field=open_time&conditions.2.operator=>&conditions.2.args.0=2+weeks+ago&conditions.2.args.1='}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All "Add artist" edits by beginner editors')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=editor&conditions.1.operator=limited&conditions.1.name=&conditions.1.args.0='}
        />
        <VotingGuideRow
          guideName={l('All "Add artist" edits by beginner editors made less than 2 weeks ago')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=editor&conditions.1.operator=limited&conditions.1.name=&conditions.1.args.0=&' +
            'conditions.2.field=open_time&conditions.2.operator=>&conditions.2.args.0=2+weeks+ago&conditions.2.args.1='}
        />
        <VotingGuideRow
          guideName={l('All open destructive edits by beginner editors')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=type&conditions.0.operator=%3D&conditions.0.args=9&conditions.0.args=84&conditions.0.args=4&conditions.0.args=153&conditions.0.args=134&conditions.0.args=14&conditions.0.args=64&conditions.0.args=74&conditions.0.args=24&conditions.0.args=225%2C223%2C311&conditions.0.args=143&conditions.0.args=44&conditions.0.args=83&conditions.0.args=3&conditions.0.args=315&conditions.0.args=152&conditions.0.args=133&conditions.0.args=78&conditions.0.args=410&conditions.0.args=13&conditions.0.args=53&conditions.0.args=63&conditions.0.args=73&conditions.0.args=23&conditions.0.args=36&conditions.0.args=224&conditions.0.args=142&conditions.0.args=211&conditions.0.args=43&conditions.0.args=47&' +
            'conditions.1.field=status&conditions.1.operator=%3D&conditions.1.args=1&' +
            'conditions.2.field=editor&conditions.2.operator=limited&conditions.2.name=&conditions.2.args.0=&' +
            'conditions.3.field=voter&conditions.3.operator=me&conditions.3.name=&conditions.3.voter_id=&conditions.3.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All open unreviewed edits (0 votes) by beginner editors')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=vote_count&conditions.1.vote=1&conditions.1.operator=%3D&conditions.1.args.0=0&conditions.1.args.1=&' +
            'conditions.2.field=vote_count&conditions.2.vote=0&conditions.2.operator=%3D&conditions.2.args.0=0&conditions.2.args.1=&' +
            'conditions.3.field=vote_count&conditions.3.vote=-1&conditions.3.operator=%3D&conditions.3.args.0=0&conditions.3.args.1=&' +
            'conditions.4.field=editor&conditions.4.operator=limited&conditions.4.name=&conditions.4.args.0='}
          showSubscribedArtistsUrl
        />
        {/* eslint-enable max-len */}
      </ul>

      <h2>{l('All edits')}</h2>
      <p>
        {l(
          `Sometimes you might want to just check all edits for some reason.
           If you feel like being overwhelmed by a very long list of edits
           is just what the doctor ordered, just check the searches below!
           Don’t forget you can always experiment with different edit search
           filters to limit the amount of edits shown a bit
           and make it more manageable`,
        )}
      </p>

      <ul>
        {/* eslint-disable max-len */}
        <VotingGuideRow
          guideName={l('All open edits')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&' +
            'conditions.1.field=voter&conditions.1.operator=me&conditions.1.name=&conditions.1.voter_id=&conditions.1.args=no'}
          showSubscribedArtistsUrl
        />
        <VotingGuideRow
          guideName={l('All edits')}
          mainUrl={'/search/edits?' +
            'conditions.0.field=status&conditions.0.operator=%3D&conditions.0.args=1&conditions.0.args=2&conditions.0.args=3&conditions.0.args=4&conditions.0.args=5&conditions.0.args=6&conditions.0.args=7&conditions.0.args=9'}
          showSubscribedArtistsUrl
        />
        {/* eslint-enable max-len */}
      </ul>
    </div>
  </Layout>
);

export default VotingIndex;
