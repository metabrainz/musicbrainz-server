/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * Types should be (mostly) kept in alphabetical order, though you may e.g.
 * keep Foo and WritableFoo or ReadOnlyFoo next to each other for clarity.
 */

declare type AreaFieldT = CompoundFieldT<{
  +gid: FieldT<string | null>,
  +name: FieldT<string>,
}>;

declare type CompoundFieldT<F> = {
  errors: Array<string>,
  field: F,
  has_errors: boolean,
  html_name: string,
  id: number,
  pendingErrors?: Array<string>,
  type: 'compound_field',
};

declare type ReadOnlyCompoundFieldT<+F> = {
  +errors: $ReadOnlyArray<string>,
  +field: F,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'compound_field',
};

declare type DatePeriodFieldT = ReadOnlyCompoundFieldT<{
  +begin_date: PartialDateFieldT,
  +end_date: PartialDateFieldT,
  +ended: ReadOnlyFieldT<boolean>,
}>;

declare type WritableDatePeriodFieldT = CompoundFieldT<{
  +begin_date: WritablePartialDateFieldT,
  +end_date: WritablePartialDateFieldT,
  +ended: FieldT<boolean>,
}>;

declare type FieldT<V> = {
  errors: Array<string>,
  has_errors: boolean,
  html_name: string,
  /*
   * The field `id` is unique across all fields on the page. It's purpose
   * is for passing to `key` attributes on React elements.
   */
  id: number,
  pendingErrors?: Array<string>,
  type: 'field',
  value: V,
};

declare type ReadOnlyFieldT<+V> = {
  +errors: $ReadOnlyArray<string>,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'field',
  +value: V,
};

// See lib/MusicBrainz/Server/Form/Role/ToJSON.pm
declare type FormT<F, N: string = ''> = {
  field: F,
  has_errors: boolean,
  name: N,
  +type: 'form',
};

declare type ReadOnlyFormT<+F, +N: string = ''> = {
  +field: F,
  +has_errors: boolean,
  +name: N,
  +type: 'form',
};

/*
 * See MusicBrainz::Server::Form::Utils::build_grouped_options
 * FIXME(michael): Figure out a way to consolidate GroupedOptionsT,
 * OptionListT, and OptionTreeT?
 */
declare type GroupedOptionsT = $ReadOnlyArray<{
  +optgroup: string,
  +options: SelectOptionsT,
}>;

declare type MaybeGroupedOptionsT =
  | {+grouped: true, +options: GroupedOptionsT}
  | {+grouped: false, +options: SelectOptionsT};

// See MB.forms.buildOptionsTree
declare type OptionListT = $ReadOnlyArray<{
  +text: string,
  +value: number,
}>;

declare type OptionTreeT<+T> = {
  ...EntityRoleT<T>,
  +child_order: number,
  +description: string,
  +gid: string,
  +name: string,
  +parent_id: number | null,
};

declare type PartialDateFieldT = ReadOnlyCompoundFieldT<{
  +day: ReadOnlyFieldT<StrOrNum | null>,
  +month: ReadOnlyFieldT<StrOrNum | null>,
  +year: ReadOnlyFieldT<StrOrNum | null>,
}>;

declare type WritablePartialDateFieldT = CompoundFieldT<{
  +day: FieldT<StrOrNum | null>,
  +month: FieldT<StrOrNum | null>,
  +year: FieldT<StrOrNum | null>,
}>;

declare type RepeatableFieldT<F> = {
  errors: Array<string>,
  field: Array<F>,
  has_errors: boolean,
  html_name: string,
  id: number,
  last_index: number,
  pendingErrors?: Array<string>,
  type: 'repeatable_field',
};

declare type ReadOnlyRepeatableFieldT<+F> = {
  +errors: $ReadOnlyArray<string>,
  +field: $ReadOnlyArray<F>,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  last_index: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'repeatable_field',
};

/*
 * See MusicBrainz::Server::Form::Utils::select_options.
 * FIXME(michael): Consolidate with OptionListT.
 */
declare type SelectOptionT = {
  +label: string | (() => string),
  +value: number | string,
};

declare type SelectOptionsT = $ReadOnlyArray<SelectOptionT>;
