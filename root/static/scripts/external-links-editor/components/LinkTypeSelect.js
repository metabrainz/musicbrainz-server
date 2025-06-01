/*
 * @flow strict-local
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities from '../../common/linkedEntities.mjs';
import type {LinkTypeOptionT} from '../types.js';

component LinkTypeSelect(
  handleTypeBlur: (SyntheticFocusEvent<HTMLSelectElement>) => void,
  handleTypeChange: (SyntheticEvent<HTMLSelectElement>) => void,
  id?: string,
  options: $ReadOnlyArray<LinkTypeOptionT>,
  type: number | null,
) {
  const optionAvailable = options.some(option => option.value === type);
  // If the selected type is not available, display it as placeholder
  const linkType = type == null ? null : linkedEntities.link_type[type];
  const placeholder = (optionAvailable || !linkType)
    ? '\xA0'
    : l_relationships(
      linkType.link_phrase,
    );

  return (
    <select
      // If the selected type is not available, display an error indicator
      className={
        (optionAvailable || type == null) ? 'link-type' : 'link-type error'
      }
      id={id}
      onBlur={handleTypeBlur}
      onChange={handleTypeChange}
      value={type ?? ''}
    >
      <option value="">{placeholder}</option>
      {options.map(option => (
        <option
          disabled={option.disabled}
          key={option.value}
          value={option.value}
        >
          {option.text}
        </option>
      ))}
    </select>
  );
}

export default LinkTypeSelect;
