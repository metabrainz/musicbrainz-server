/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useCallback, useEffect, useState} from 'react';

// Originally from https://usehooks-ts.com/react-hook/use-media-query
export default function useMediaQuery(queryStr: string): boolean {
  const getMatches = (query: string): boolean => {
    if (typeof window !== 'undefined') {
      return window.matchMedia(query).matches;
    }
    return false;
  };

  const [matches, setMatches] = useState<boolean>(getMatches(queryStr));

  const handleChange = useCallback(() => {
    setMatches(getMatches(queryStr));
  }, [queryStr]);

  useEffect(() => {
    const matchMedia = window.matchMedia(queryStr);
    handleChange();
    matchMedia.addEventListener('change', handleChange);
    return () => {
      matchMedia.removeEventListener('change', handleChange);
    };
  }, [queryStr, handleChange]);

  return matches;
}
