/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import SubHeader from '../components/SubHeader.js';
import Tabs from '../components/Tabs.js';
import Layout from '../layout/index.js';
import TagLink from '../static/scripts/common/components/TagLink.js';

type Props = {
  +children: React$Node,
  +page: string,
  +tag: TagT,
  +title?: string,
};

const tabLinks: $ReadOnlyArray<[string, () => string]> = [
  ['', N_l('Overview')],
  ['/artist', N_l('Artists')],
  ['/release-group', N_l('Release groups')],
  ['/release', N_l('Releases')],
  ['/recording', N_l('Recordings')],
  ['/work', N_l('Works')],
  ['/label', N_l('Labels')],
  ['/place', N_l('Places')],
  ['/area', N_l('Areas')],
  ['/instrument', N_l('Instruments')],
  ['/series', N_lp('Series', 'plural')],
  ['/event', N_l('Events')],
];

const TagLayout = ({
  children,
  page,
  tag,
  title,
}: Props): React$Element<typeof Layout> => (
  <Layout
    fullWidth
    title={
      nonEmpty(title)
        ? hyphenateTitle(
          texp.lp('Tag “{tag}”', 'folksonomy', {tag: tag.name}),
          title,
        ) : texp.lp('Tag “{tag}”', 'folksonomy', {tag: tag.name})
    }
  >
    <div id="content">
      <div className="tagheader">
        <h1>
          {exp.lp(
            'Tag “{tag}”',
            'folksonomy',
            {tag: <TagLink tag={tag.name} />},
          )}
        </h1>
        <SubHeader subHeading={lp('Tag', 'folksonomy')} />
      </div>
      <Tabs>
        {tabLinks.map(link => (
          <li className={page === link[0] ? 'sel' : ''} key={link[0]}>
            <a href={'/tag/' + encodeURIComponent(tag.name) + link[0]}>
              {link[1]()}
            </a>
          </li>
        ))}
      </Tabs>
      {children}
    </div>
  </Layout>
);

export default TagLayout;
