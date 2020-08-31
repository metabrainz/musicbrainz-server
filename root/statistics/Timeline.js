// @flow

import * as React from 'react';

import Layout from '../layout';
import * as manifest from '../static/manifest';
import {default as TimelineContent}
  from '../static/scripts/statistics/timeline/components/Timeline';
import {renderPropsScript} from '../utility/hydrate';

type Props = {
  +$c: CatalystContextT,
};

const Timeline = (props: Props): React.Element<typeof Layout> => (
  <Layout
    $c={props.$c}
    beforePageContent={
      <>
        {manifest.js('timeline.js', {async: 'async'})}
        {renderPropsScript(props)}
      </>
    }
    title={hyphenateTitle(l('Database Statistics'), l('Timeline Graph'))}
  >
    <TimelineContent $c={props.$c} />
  </Layout>
);

export default Timeline;
