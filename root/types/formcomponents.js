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
  readonly gid: FieldT<string | null>,
  readonly id: FieldT<string | null>,
  readonly name: FieldT<string>,
}>;

declare type ArtistFieldT = CompoundFieldT<{
  readonly id: FieldT<string | null>,
  readonly name: FieldT<string>,
}>;

declare type ArtistCreditFieldT = CompoundFieldT<{
  readonly names: ArtistCreditNameFieldT,
}>;

declare type ArtistCreditNameFieldT = CompoundFieldT<{
  readonly artist: ArtistCreditFieldT,
  readonly join_phrase: FieldT<string>,
  readonly name: FieldT<string>,
}>;

declare type CompoundFieldT<out F> = {
  readonly errors: ReadonlyArray<string>,
  readonly field: F,
  readonly has_errors: boolean,
  readonly html_name: string,
  readonly id: number,
  readonly pendingErrors?: ReadonlyArray<string>,
  readonly type: 'compound_field',
};

declare type DatePeriodFieldT = CompoundFieldT<{
  readonly begin_date: PartialDateFieldT,
  readonly end_date: PartialDateFieldT,
  readonly ended: FieldT<boolean>,
}>;

declare type FieldT<out V> = {
  readonly errors: ReadonlyArray<string>,
  readonly has_errors: boolean,
  readonly html_name: string,
  readonly id: number,
  readonly pendingErrors?: ReadonlyArray<string>,
  readonly type: 'field',
  readonly value: V,
};

// See lib/MusicBrainz/Server/Form/Role/ToJSON.pm
declare type FormT<out F, out N: string = ''> = {
  readonly field: F,
  readonly has_errors: boolean,
  readonly name: N,
  readonly type: 'form',
};

declare type SubfieldsT = {
  readonly [fieldName: string]: AnyFieldT,
};

declare type AnyFieldT =
  | {
      readonly errors: ReadonlyArray<string>,
      readonly field: SubfieldsT,
      readonly pendingErrors?: ReadonlyArray<string>,
      readonly type: 'compound_field',
      ...
    }
  | {
      readonly errors: ReadonlyArray<string>,
      readonly field: ReadonlyArray<AnyFieldT>,
      readonly pendingErrors?: ReadonlyArray<string>,
      readonly type: 'repeatable_field',
      ...
    }
  | {
      readonly errors: ReadonlyArray<string>,
      readonly pendingErrors?: ReadonlyArray<string>,
      readonly type: 'field',
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
declare type GroupedOptionsT = ReadonlyArray<{
  readonly optgroup: string,
  readonly options: SelectOptionsT,
}>;

declare type MaybeGroupedOptionsT =
  | {readonly grouped: true, readonly options: GroupedOptionsT}
  | {readonly grouped: false, readonly options: SelectOptionsT};

// See `buildOptionsTree` in root/static/scripts/edit/forms.js.
declare type OptionListT = ReadonlyArray<{
  readonly text: string,
  readonly value: number,
}>;

declare type OptionTreeT<out T> = {
  ...EntityRoleT<T>,
  readonly child_order: number,
  readonly description: string,
  readonly gid: string,
  readonly name: string,
  readonly parent_id: number | null,
};

declare type PartialDateFieldT = CompoundFieldT<{
  readonly day: FieldT<StrOrNum | null>,
  readonly month: FieldT<StrOrNum | null>,
  readonly year: FieldT<StrOrNum | null>,
}>;

declare type RepeatableFieldT<out F> = {
  readonly errors: ReadonlyArray<string>,
  readonly field: ReadonlyArray<F>,
  readonly has_errors: boolean,
  readonly html_name: string,
  readonly id: number,
  readonly last_index: number,
  readonly pendingErrors?: ReadonlyArray<string>,
  readonly type: 'repeatable_field',
};

/*
 * See MusicBrainz::Server::Form::Utils::select_options.
 * FIXME(michael): Consolidate with OptionListT.
 */
declare type SelectOptionT = {
  readonly label: string | (() => string),
  readonly value: number | string,
};

declare type SelectOptionsT = ReadonlyArray<SelectOptionT>;
