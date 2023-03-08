/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import linkedEntities from '../../common/linkedEntities.mjs';
import {keyBy} from '../../common/utility/arrays.js';
import sleep from '../../common/utility/sleep.js';
import {
  exportLinkAttributeTypeInfo,
  exportLinkTypeInfo,
} from '../../relationship-editor/utility/exportTypeInfo.js';

const typeInfoPromises = new Map<string, Promise<void>>();
const loadedTypeInfo = new Set<string>();

export default function withLoadedTypeInfo<-Config, +Instance = mixed>(
  WrappedComponent: React$AbstractComponent<Config, Instance>,
  typeInfoToLoad: $ReadOnlySet<string>,
): React$AbstractComponent<Config, Instance> {
  const ComponentWrapper = React.forwardRef((
    props: Config,
    ref:
      | {current: Instance | null, ...}
      | ((Instance | null) => mixed),
  ) => {
    const [isLoading, setLoading] = React.useState<boolean>(true);

    const [
      typeInfoLoadErrors,
      setTypeInfoLoadErrors,
    ] = React.useState<$ReadOnlyArray<string>>([]);

    const loadingCanceledRef = React.useRef<boolean>(false);

    const loadTypeInfo = React.useCallback(async function (
      typeName: string,
    ) {
      const fetchUrl = '/ws/js/type-info/' + typeName;

      const response = await fetch(fetchUrl);

      if (!response.ok) {
        throw new Error(
          'Got a ' + String(response.status) + ' fetching ' +
          fetchUrl,
        );
      }

      const responseJson: {
        // $FlowIgnore[unclear-type]
        +[listName: string]: Array<any>,
      } = await response.json();
      const typeInfo = responseJson[typeName + '_list'];

      switch (typeName) {
        case 'language': {
          linkedEntities.language = Object.fromEntries(
            keyBy(typeInfo, language => language.id),
          );
          break;
        }
        case 'link_attribute_type': {
          exportLinkAttributeTypeInfo(typeInfo);
          break;
        }
        case 'link_type': {
          exportLinkTypeInfo(typeInfo);
          break;
        }
        case 'series_type': {
          linkedEntities.series_type = Object.fromEntries(
            keyBy(typeInfo, type => String(type.id)),
          );
          break;
        }
        case 'work_type': {
          linkedEntities.work_type = Object.fromEntries(
            keyBy(typeInfo, type => String(type.id)),
          );
          break;
        }
      }

      loadedTypeInfo.add(typeName);
    }, []);

    const loadAllTypeInfo = React.useCallback(async function () {
      for (const typeName of typeInfoToLoad) {
        if (loadingCanceledRef.current) {
          break;
        }

        if (loadedTypeInfo.has(typeName)) {
          continue;
        }

        let typeInfoPromise = typeInfoPromises.get(typeName);
        if (typeInfoPromise == null) {
          typeInfoPromise = loadTypeInfo(typeName);
          typeInfoPromises.set(typeName, typeInfoPromise);
          await typeInfoPromise;
          typeInfoPromises.delete(typeName);
        } else {
          await typeInfoPromise;
          await sleep(500);
        }
      }

      setLoading(false);
    }, [loadTypeInfo]);

    React.useEffect(() => {
      loadingCanceledRef.current = false;

      loadAllTypeInfo().catch((error) => {
        setTypeInfoLoadErrors([
          ...typeInfoLoadErrors,
          error.message,
        ]);
      });

      return () => {
        loadingCanceledRef.current = true;
      };
    }, [loadAllTypeInfo, typeInfoLoadErrors]);

    return (
      isLoading ? (
        typeInfoLoadErrors.length ? (
          <ul className="errors">
            {typeInfoLoadErrors.map((error, index) => (
              <li key={index}>{error}</li>
            ))}
          </ul>
        ) : (
          <p className="loading-message">
            {l('Loading...')}
          </p>
        )
      ) : (
        <WrappedComponent ref={ref} {...props} />
      )
    );
  });

  return ComponentWrapper;
}

export function withLoadedTypeInfoForRelationshipEditor<
  -Config,
  +Instance = mixed,
>(
  WrappedComponent: React$AbstractComponent<Config, Instance>,
  extraTypeInfoToLoad?: $ReadOnlyArray<string> = [],
): React$AbstractComponent<Config, Instance> {
  return withLoadedTypeInfo(
    WrappedComponent,
    new Set([
      'link_attribute_type',
      'link_type',
      'series_type',
      ...extraTypeInfoToLoad,
    ]),
  );
}
