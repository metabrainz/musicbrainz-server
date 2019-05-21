/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';
import ReactDOM from 'react-dom';

export default function hydrate<Config>(
  containerSelector: string,
  Component: React.AbstractComponent<Config>,
  mungeProps?: (Config) => Config,
): React.AbstractComponent<Config, void> {
  const [containerTag, ...classes] = containerSelector.split('.');
  if (typeof document !== 'undefined') {
    // This should only run on the client.
    const $ = require('jquery');
    $(function () {
      const roots = document.querySelectorAll(containerSelector);
      for (const root of roots) {
        const propString = root.getAttribute('data-props');
        root.removeAttribute('data-props');
        if (propString) {
          const props: Config = JSON.parse(propString);
          ReactDOM.hydrate(<Component {...props} />, root);
        }
      }
    });
  }
  return (props) => {
    let dataProps = props;
    if (mungeProps) {
      dataProps = mungeProps(dataProps);
    }
    return React.createElement(
      containerTag,
      {
        'className': classes.join(' '),
        'data-props': JSON.stringify(dataProps),
      },
      <Component {...props} />,
    );
  };
}

type PropsWithEntity = {entity: MinimalCoreEntityT, ...};

export function minimalEntity<T: $ReadOnly<PropsWithEntity>>(
  props: $Exact<T>,
): $Exact<T> {
  const entity = props.entity;
  return mutate<PropsWithEntity, _>(props, newProps => {
    newProps.entity = {
      entityType: entity.entityType,
      gid: entity.gid,
    };
  });
}
