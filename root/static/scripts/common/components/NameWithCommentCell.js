/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import DescriptiveLink from './DescriptiveLink.js';
import EntityLink from './EntityLink.js';

type PropsT = {
  +canEditCollectionComments?: boolean,
  +collectionComments?: {+[entityGid: string]: string},
  +collectionId: number,
  +descriptive?: boolean,
  +entity: RelatableEntityT | CollectionT,
  +showArtworkPresence?: boolean,
};

component NameWithCommentCell(
  canEditCollectionComments: boolean = false,
  collectionComments?: {+[entityGid: string]: string},
  collectionId: number,
  descriptive: boolean = true,
  entity: RelatableEntityT | CollectionT,
  showArtworkPresence?: boolean,
) {
  const [comment, setComment] = React.useState(
    collectionComments && collectionComments[entity.gid]
      ? collectionComments[entity.gid]
      : '',
  );
  const hasComment = nonEmpty(comment);
  const [expandedTextArea, setExpandedTextArea] = React.useState(false);
  const [showError, setShowError] = React.useState(false);
  const endpoint = '/ws/js/set-collection-comment?' +
                   'collection=' + collectionId + '&' +
                   'entity=' + entity.id + '&' +
                   'entity-type=' + entity.entityType;

  return (
    <>
      {descriptive ? (
        <DescriptiveLink entity={entity} />
      ) : (
        <EntityLink
          entity={entity}
          showArtworkPresence={showArtworkPresence}
          // Event lists show date in its own column
          showEventDate={false}
        />
      )}
      {hasComment || canEditCollectionComments ? (
        <>
          <br />
          <div className="collection-comment small">
            {hasComment ? (
              <>
                {addColonText(lp('Comment', 'collection_comment'))}
                {' '}
                {comment}
              </>
            ) : (
              addColonText(lp('Add comment', 'collection_comment'))
            )}
            {canEditCollectionComments ? (
              <>
                {' '}
                <button
                  className="icon edit-item"
                  onClick={(event) => {
                    event.preventDefault();
                    setExpandedTextArea(!expandedTextArea);
                  }}
                  type="button"
                />
                {expandedTextArea ? (
                  <>
                    <br />
                    {showError ? (
                      <p className="error">
                        {l('Something went wrong, please try again.')}
                      </p>
                    ) : null}
                    <textarea
                      className="edit-collection-comment"
                      defaultValue={comment}
                      onBlur={(event) => {
                        const newComment = event.target.value;
                        fetch(endpoint, {
                          body: newComment,
                          headers: {
                            'Content-Type': 'text/plain; charset=utf-8',
                          },
                          method: 'POST',
                        }).then(
                          function (response) {
                            if (response.ok) {
                              setComment(newComment);
                              setExpandedTextArea(false);
                              setShowError(false);
                            } else {
                              setShowError(true);
                            }
                          },
                        ).catch(() => {
                          setShowError(true);
                        });
                      }}
                      rows="4"
                    />
                  </>
                ) : null}
              </>
            ) : null}
          </div>
        </>
      ) : null}
    </>
  );
}

export default (
  hydrate<PropsT>(
    'div.name-with-comment',
    NameWithCommentCell,
  ): React.AbstractComponent<PropsT, void>
);
