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
import * as ReactDOM from 'react-dom';

import {
  CatalystContext,
  SanitizedCatalystContext,
} from '../context';

import sanitizedContext from './sanitizedContext';

export default function hydrate<
  Config,
  SanitizedConfig = Config,
>(
  containerSelector: string,
  Component: React.AbstractComponent<Config | SanitizedConfig>,
  mungeProps?: (Config) => SanitizedConfig,
): React.AbstractComponent<Config, void> {
  const [containerTag, ...classes] = containerSelector.split('.');
  if (typeof document !== 'undefined') {
    // This should only run on the client.
    const $ = require('jquery');
    $(function () {
      const roots = document.querySelectorAll(containerSelector);
      for (const root of roots) {
        const contextString = root.getAttribute('data-context');
        const propString = root.getAttribute('data-props');
        root.removeAttribute('data-context');
        root.removeAttribute('data-props');
        if (contextString && propString) {
          const $c: SanitizedCatalystContextT = JSON.parse(contextString);
          const props: SanitizedConfig = JSON.parse(propString);
          ReactDOM.hydrate(
            <SanitizedCatalystContext.Provider value={$c}>
              <Component {...props} />
            </SanitizedCatalystContext.Provider>,
            root,
          );
        }
      }
    });
  }
  return (props: Config) => {
    let dataProps = props;
    if (mungeProps) {
      dataProps = mungeProps(dataProps);
    }
    return (
      <CatalystContext.Consumer>
        {$c => React.createElement(
          containerTag,
          {
            'className': classes.join(' '),
            'data-context': JSON.stringify(sanitizedContext($c)),
            'data-props': JSON.stringify(dataProps),
          },
          <Component {...props} />,
        )}
      </CatalystContext.Consumer>
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
