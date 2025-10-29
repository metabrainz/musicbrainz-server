/*
 * @flow
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from '../i18n/expand2react.js';

import Bubble from './Bubble.js';

component TypeBubble(
    controlRef: {+current: HTMLElement | null},
    descriptions: {+[id: string]: string},
    types: SelectOptionsT,
    field: FieldT<string>,
) {
  return (
    <Bubble
      controlRef={controlRef}
      id="type-bubble"
    >
      <span
        id="type-bubble-default"
        style={
          field.value ? {display: 'none'} : null
        }
      >
        {l(`Select any type from the list to see its description.
            If no type seems to fit, just leave this blank.`)}
      </span>
      {types.map((type) => {
        const typeId = type.value.toString();
        const selectedType = field.value.toString();
        const description = descriptions[typeId];
        return (
          <span
            className="type-bubble-description"
            id={`type-bubble-description-${typeId}`}
            key={typeId}
            style={
              selectedType === typeId
                ? {}
                : {display: 'none'}
            }
          >
            {nonEmpty(description)
              ? expand2react(description)
              : l('No description available.')}
          </span>
        );
      })}
    </Bubble>
  );
}

export default TypeBubble;
