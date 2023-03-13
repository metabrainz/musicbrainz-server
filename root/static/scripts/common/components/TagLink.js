/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type UserTagLinkProps = {
  +content?: string,
  +showDownvoted?: boolean,
  +subPath?: string,
  +tag: string,
  +username: string,
};

type TagLinkProps = {
  +content?: string,
  +subPath?: string,
  +tag: string,
};

export const UserTagLink = (
  {content, showDownvoted = false, subPath, tag, username}: UserTagLinkProps,
): React$Element<'a'> => {
  const url = '/user/' + encodeURIComponent(username) +
              '/tag/' + encodeURIComponent(tag) +
              (subPath == null ? '' : '/' + subPath) +
              (showDownvoted ? '?show_downvoted=1' : '');
  return <a href={url}>{content == null ? tag : content}</a>;
};

const TagLink = (
  {content, subPath, tag}: TagLinkProps,
): React$Element<'a'> => {
  const url = '/tag/' + encodeURIComponent(tag) +
              (subPath == null ? '' : '/' + subPath);
  return <a href={url}>{content == null ? tag : content}</a>;
};

export default TagLink;
