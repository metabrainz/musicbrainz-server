/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type AnchorProps = {
  +className?: string,
  +href: string,
  +rel?: 'noopener noreferrer',
  +target?: '_blank',
  +title?: string,
};

declare type VarSubstScalarArg =
  | StrOrNum
  | React$MixedElement;

declare type VarSubstArg =
  | VarSubstScalarArg
  | $ReadOnlyArray<VarSubstScalarArg>;

declare type Expand2ReactInput = VarSubstArg | AnchorProps;

declare type Expand2ReactScalarOutput =
  | string
  | React$MixedElement;

declare type Expand2ReactOutput =
  | Expand2ReactScalarOutput
  | Array<Expand2ReactScalarOutput>;

declare type ExpandLFunc<-Input, Output> = (
  key: string,
  args: {+[arg: string]: Input | Output | string, ...},
) => Output;

declare type N_l_T = () => string;
