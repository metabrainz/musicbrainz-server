/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {unwrapNl} from '../../i18n.js';
import clean from '../../utility/clean.js';
import setMapDefault from '../../utility/setMapDefault.js';
import {unaccent} from '../../utility/strings.js';

import type {
  EntityItemT,
  ItemT,
  OptionItemT,
} from './types.js';

const itemIndexes:
  WeakMap<
    // $FlowIgnore[unclear-type]
    $ReadOnlyArray<ItemT<any>>,
    Map<
      string, // gram
      // $FlowIgnore[unclear-type]
      Set<OptionItemT<any>>, // items containing `gram`
    >,
  > = new WeakMap();

/*
 * The first search term returned for an item should be the most
 * important (the name).  We cache these for use in `weightEntry`
 * below.
 */
const itemFirstSearchTerms:
  // $FlowIgnore[unclear-type]
  WeakMap<OptionItemT<any>, string> = new WeakMap();

function normalize(input: string): string {
  return unaccent(input).toLowerCase();
}

const MAX_GRAM_SIZE = 6;

function* getNGrams(
  input: string,
): Generator<string, void, void> {
  const normalizedInput = normalize(input);
  const length = normalizedInput.length;
  for (let i = 0; i < length; i++) {
    let gram = '';
    for (let n = 0; n < MAX_GRAM_SIZE; n++) {
      if (i < (length - n)) {
        gram += normalizedInput[i + n];
        yield gram;
      } else {
        break;
      }
    }
  }
}

export function getItemName<+T: EntityItemT>(
  item: OptionItemT<T>,
): Array<string> {
  return [unwrapNl<string>(item.name)];
}

const createItemSet =
  <+T: EntityItemT>(): Set<OptionItemT<T>> => new Set();

export function indexItems<+T: EntityItemT>(
  items: $ReadOnlyArray<ItemT<T>>,
  extractSearchTerms: (OptionItemT<T>) => Array<string>,
): void {
  if (itemIndexes.has(items)) {
    return;
  }
  const index: Map<string, Set<OptionItemT<T>>> = new Map();
  for (const item of items) {
    if (item.type === 'option' && item.disabled !== true) {
      const searchTerms = extractSearchTerms(item)
        .map(clean)
        .filter(nonEmpty);
      invariant(
        searchTerms.length,
        'No search terms were returned for indexing',
      );
      itemFirstSearchTerms.set(item, searchTerms[0]);
      for (const searchTerm of searchTerms) {
        for (const nGram of getNGrams(searchTerm)) {
          setMapDefault(index, nGram, createItemSet).add(item);
        }
      }
    }
  }
  itemIndexes.set(items, index);
}

function getItem<+T: EntityItemT>(
  itemAndRank: [OptionItemT<T>, number],
): OptionItemT<T> {
  const itemCopy = {...itemAndRank[0]};
  /*
   * The searched items are displayed as a flat list. If there's a tree
   * hierarchy, it wouldn't make sense here, so we should remove any
   * `level`.
   */
  delete itemCopy.level;
  return itemCopy;
}

function compareItemRanks<+T: EntityItemT>(
  a: [OptionItemT<T>, number],
  b: [OptionItemT<T>, number],
): number {
  return b[1] - a[1];
}

function weightEntry<+T: EntityItemT>(
  itemAndRank: [OptionItemT<T>, number],
  searchTerm: string,
): number {
  const item = itemAndRank[0];
  const itemFirstSearchTerm = itemFirstSearchTerms.get(item);
  invariant(
    itemFirstSearchTerm != null,
    'The item to be weighted has not been indexed',
  );
  let rank = itemAndRank[1];
  const itemFirstSearchTermLength = itemFirstSearchTerm.length;
  const searchTermPosition = itemFirstSearchTerm.indexOf(searchTerm);
  if (searchTermPosition >= 0) {
    rank *= (1 + (
      // Prefer matches earlier in the string
      (itemFirstSearchTermLength - searchTermPosition) /
      itemFirstSearchTermLength
    ));
    rank *= (1 + ((
      // Prefer matches closer in length
      searchTerm.length / itemFirstSearchTermLength
    ) * 2));
  }
  return rank;
}

export default function searchItems<+T: EntityItemT>(
  items: $ReadOnlyArray<OptionItemT<T>>,
  searchTerm: string,
): $ReadOnlyArray<OptionItemT<T>> {
  if (!searchTerm) {
    return items;
  }
  const index = itemIndexes.get(items);
  invariant(
    index,
    'The items to be searched have not been indexed',
  );
  const itemRanks = new Map<OptionItemT<T>, number>();
  const addMatchingItems = (
    n: number,
    items: Set<OptionItemT<T>>,
  ) => {
    for (const item of items) {
      itemRanks.set(item, (itemRanks.get(item) ?? 0) + n);
    }
  };
  for (const nGram of getNGrams(searchTerm)) {
    const matchingItems = index.get(nGram);
    if (matchingItems) {
      addMatchingItems(nGram.length, matchingItems);
    }
  }
  let rankedEntries = Array.from(itemRanks.entries())
    .map((itemAndRank) => [
      itemAndRank[0],
      weightEntry(itemAndRank, searchTerm),
    ])
    .sort(compareItemRanks);
  if (rankedEntries.length) {
    const maxRank = rankedEntries[0][1];
    /*
     * 1-grams can produce a lot of dubious matches, so filter out results
     * that aren't within at least 25% of the top-rank.
     */
    rankedEntries = rankedEntries
      .filter((itemAndRank) => (itemAndRank[1] / maxRank) >= 0.25);
  }
  return rankedEntries.map(getItem);
}
