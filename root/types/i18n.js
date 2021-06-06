/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type AnchorProps = {
  +className?: string,
  +href: string,
  +key?: number | string,
  +target?: '_blank',
  +title?: string,
};

declare type Expand2ReactInput = VarSubstArg | AnchorProps;

declare type Expand2ReactOutput = string | React$MixedElement;

declare type ExpandLFunc<-Input, Output> = (
  key: string,
  args: {+[arg: string]: Input | Output, ...},
) => Output;

declare type VarSubstArg =
  | StrOrNum
  | React$MixedElement;
