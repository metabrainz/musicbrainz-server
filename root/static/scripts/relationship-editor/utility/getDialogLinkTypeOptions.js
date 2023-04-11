/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  formatLinkTypePhrases,
} from '../../common/components/Autocomplete2/formatters.js';
import {type OptionItemT}
  from '../../common/components/Autocomplete2/types.js';
import {
  PART_OF_SERIES_LINK_TYPE_GIDS,
  PART_OF_SERIES_LINK_TYPES,
} from '../../common/constants.js';
import {compare, unwrapNl} from '../../common/i18n.js';
import linkedEntities from '../../common/linkedEntities.mjs';

function cmpLinkTypeOptions(
  a: OptionItemT<LinkTypeT>,
  b: OptionItemT<LinkTypeT>,
) {
  return (
    (a.entity.child_order - b.entity.child_order) ||
    compare(
      l_relationships(unwrapNl<string>(a.name)),
      l_relationships(unwrapNl<string>(b.name)),
    )
  );
}

function buildOption(
  linkType: LinkTypeT,
  level: number,
): OptionItemT<LinkTypeT> {
  return {
    disabled: !linkType.description,
    entity: linkType,
    id: linkType.id,
    level,
    name: formatLinkTypePhrases(linkType),
    type: 'option',
  };
}

function isInvalidPartOfSeriesType(
  seriesItemType: SeriesEntityTypeT,
  linkType: LinkTypeT,
): boolean {
  return (
    PART_OF_SERIES_LINK_TYPE_GIDS.includes(linkType.gid) &&
    linkType.gid !== PART_OF_SERIES_LINK_TYPES[seriesItemType]
  );
}

const getDialogLinkTypeOptions = (
  source: RelatableEntityT,
  targetType: RelatableEntityTypeT,
): $ReadOnlyArray<OptionItemT<LinkTypeT>> => {
  const options: Array<OptionItemT<LinkTypeT>> = [];

  let seriesItemType = null;
  if (source.entityType === 'series') {
    const seriesTypeId = source.typeID;
    if (seriesTypeId != null) {
      const seriesType = linkedEntities.series_type[String(seriesTypeId)];
      if (seriesType) {
        seriesItemType = seriesType.item_entity_type;
      }
    }
  }

  const buildOptions = (
    parent: LinkTypeT | {+children: $ReadOnlyArray<LinkTypeT>},
    level: number,
  ) => {
    const children = parent.children;

    if (!children) {
      return;
    }

    const childOptions = [];
    let linkType;
    let i = 0;

    while ((linkType = children[i++])) {
      if (
        seriesItemType != null &&
        isInvalidPartOfSeriesType(seriesItemType, linkType)
      ) {
        continue;
      }
      childOptions.push(buildOption(linkType, level));
    }

    childOptions.sort(cmpLinkTypeOptions);

    for (let i = 0; i < childOptions.length; i++) {
      const option = childOptions[i];
      const linkType = option.entity;
      options.push(option);
      buildOptions(linkType, level + 1);
    }
  };

  const entityTypes = [source.entityType, targetType].sort().join('-');

  buildOptions({
    children: linkedEntities.link_type_tree[entityTypes],
  }, 0);

  return options;
};

export default getDialogLinkTypeOptions;

export const hasDialogLinkTypeOptions = (
  sourceType: RelatableEntityTypeT,
  targetType: RelatableEntityTypeT,
): boolean => {
  const entityTypes = [sourceType, targetType].sort().join('-');
  return (linkedEntities.link_type_tree[entityTypes]?.length || 0) > 0;
};
