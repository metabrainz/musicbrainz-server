/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

/*
 * Types should be (mostly) kept in alphabetical order, though you may e.g.
 * keep Foo and WritableFoo or ReadOnlyFoo next to each other for clarity.
 */

declare type AreaFieldT = CompoundFieldT<{
  +gid: FieldT<string | null>,
  +name: FieldT<string>,
}>;

declare type ArtistCreditFieldT = CompoundFieldT<{
  +names: RepeatableFieldT<ArtistCreditNameFieldT>,
}>;

declare type ArtistCreditNameFieldT = CompoundFieldT<{
  +artist: FieldT<number>,
  +join_phrase: FieldT<string>,
  +name: FieldT<string>,
}>;

declare type CompoundFieldT<+F> = {
  +errors: $ReadOnlyArray<string>,
  +field: F,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'compound_field',
};

declare type DatePeriodFieldT = CompoundFieldT<{
  +begin_date: PartialDateFieldT,
  +end_date: PartialDateFieldT,
  +ended: FieldT<boolean>,
}>;

declare type FieldT<+V> = {
  +errors: $ReadOnlyArray<string>,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +pendingErrors?: $ReadOnlyArray<string>,
  +type: 'field',
  +value: V,
};

// See lib/MusicBrainz/Server/Form/Role/ToJSON.pm
declare type FormT<+F, +N: string = ''> = {
  +field: F,
  +has_errors: boolean,
  +name: N,
  +type: 'form',
};

declare type SubfieldsT = {
  +[fieldName: string]: AnyFieldT,
};

declare type AnyFieldT =
  | {
      +errors: $ReadOnlyArray<string>,
      +field: SubfieldsT,
      +pendingErrors?: $ReadOnlyArray<string>,
      +type: 'compound_field',
      ...
    }
  | {
      +errors: $ReadOnlyArray<string>,
      +field: $ReadOnlyArray<AnyFieldT>,
      +pendingErrors?: $ReadOnlyArray<string>,
      +type: 'repeatable_field',
      ...
    }
  | {
      +errors: $ReadOnlyArray<string>,
      +pendingErrors?: $ReadOnlyArray<string>,
      +type: 'field',
      ...
    };

declare type FormOrAnyFieldT =
  | FormT<SubfieldsT>
  | AnyFieldT;

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

declare type PartialDateFieldT = CompoundFieldT<{
  +day: FieldT<StrOrNum | null>,
  +month: FieldT<StrOrNum | null>,
  +year: FieldT<StrOrNum | null>,
}>;

declare type RepeatableFieldT<+F> = {
  +errors: $ReadOnlyArray<string>,
  +field: $ReadOnlyArray<F>,
  +has_errors: boolean,
  +html_name: string,
  +id: number,
  +last_index: number,
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
