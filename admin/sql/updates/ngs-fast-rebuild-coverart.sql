
CREATE UNIQUE INDEX l_release_url_idx_uniq ON l_release_url (entity0, entity1, link);

-- Add coverart for ASINs using the old way
UPDATE release_coverart
    SET coverfetched = NOW() - '1 minute'::INTERVAL * ROUND(RANDOM() * 20160), -- 20160 minutes = 2 weeks
        coverarturl = (SELECT 'http://' 
        || (CASE WHEN substring(url.url from E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/') = 'de' THEN 'ec2.images-amazon.com' ELSE 'ec1.images-amazon.com' END)
        || '/images/P/'
        || substring(url.url from 'product/([0-9A-Z]{10})')
        || '.'
        || (CASE WHEN substring(url.url from E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/') = 'de' THEN '03' 
                WHEN substring(url.url from E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/') = 'fr'  THEN '08'
                WHEN substring(url.url from E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/') = 'co.jp' THEN '09'
                WHEN substring(url.url from E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/') = 'co.uk' THEN '02'
                WHEN substring(url.url from E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/') IN ('ca', 'com') THEN '01'
            END)
        || '.MZZZZZZZ.jpg'
        FROM l_release_url l
          JOIN link      ON l.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          JOIN url       ON l.entity1 = url.id
        WHERE link_type.name = 'amazon asin'
            AND url ~ E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/gp/product/[0-9A-Z]{10}\$'
            AND l.entity0 = release_coverart.id
        LIMIT 1
    )
    WHERE EXISTS (SELECT 1  FROM l_release_url l
          JOIN link      ON l.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          JOIN url       ON l.entity1 = url.id
        WHERE link_type.name = 'amazon asin'
            AND url ~ E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/gp/product/[0-9A-Z]{10}\$'
            AND l.entity0 = release_coverart.id
    ) AND coverarturl IS NULL;

UPDATE release_meta
    SET amazonasin = (SELECT substring(url.url from 'product/([0-9A-Z]{10})')
        FROM l_release_url l
          JOIN link      ON l.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          JOIN url       ON l.entity1 = url.id
        WHERE link_type.name = 'amazon asin'
            AND url ~ E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/gp/product/[0-9A-Z]{10}\$'
            AND l.entity0 = release_meta.id
        LIMIT 1
    ), infourl = (SELECT url.url
        FROM l_release_url l
          JOIN link      ON l.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          JOIN url       ON l.entity1 = url.id
        WHERE link_type.name = 'amazon asin'
            AND url ~ E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/gp/product/[0-9A-Z]{10}\$'
            AND l.entity0 = release_meta.id
        LIMIT 1
    )
    WHERE EXISTS (SELECT 1  FROM l_release_url l
          JOIN link      ON l.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          JOIN url       ON l.entity1 = url.id
        WHERE link_type.name = 'amazon asin'
            AND url ~ E'^http://www\\.amazon\\.(com|ca|de|fr|co\\.(jp|uk))/gp/product/[0-9A-Z]{10}\$'
            AND l.entity0 = release_meta.id
    ) AND amazonasin IS NULL;

DROP INDEX l_release_url_idx_uniq;
