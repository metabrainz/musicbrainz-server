import {reduceArtistCredit} from '../static/scripts/common/immutable-entities';
import entityHref from '../static/scripts/common/utility/entityHref';

const ReleaseArtwork = ({
     artwork,
  }: {
    +artwork: ArtworkT,
  }) => {
    const release = artwork.release;
    if (!release) {
      return null;
    }
    const releaseDescription = texp.l('{entity} by {artist}', {
      artist: reduceArtistCredit(release.artistCredit),
      entity: release.name,
    });
    return (
      <div className="artwork-cont" style={{textAlign: 'center'}}>
        <div className="artwork">
          <a
            href={entityHref(release)}
            title={releaseDescription}
          >
            <ArtworkImage
              artwork={artwork}
              fallback={release.cover_art_url || ''}
              hover={releaseDescription}
            />
          </a>
        </div>
      </div>
    );
  };