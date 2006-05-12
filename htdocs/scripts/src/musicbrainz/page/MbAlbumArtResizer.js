/*----------------------------------------------------------------------------\
|                              Musicbrainz.org                                |
|                 Copyright (c) 2005 Stefan Kestenholz (keschte)              |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
|                                                                             |
| $Id$
\----------------------------------------------------------------------------*/

/**
 * Resize albumart if it provides naturalHeight/Width
 *
 */
function MbAlbumArtResizer() {
	mb.log.enter("MbAlbumArtResizer", "__constructor");

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN	= "MbAlbumArtResizer";
	this.GID = "mb.albumart";

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	  * The purpose of this code is to resize Amazon cover art so that, if
	  * possible, it isn't scaled (it's displayed at its "natural" size).
	  * Firefox provides naturalWidth/naturalHeight, which tells
	  * us how many pixels wide/high the image actually is.
	  *
	  * @param	imgRef		the amazon image to be resized.
	 **/
	this.unscaleAlbumArt = function(imgRef) {
		mb.log.enter(this.GID, "unscaleAlbumArt");
		var w,h;
		if (!imgRef) {
			mb.log.error("imgRef is null");
			return mb.log.exit();
		}

		if (!(w = imgRef.naturalWidth) || !(h = imgRef.naturalHeight)) {
			// image object does not provide naturalWidth/Height
			return mb.log.exit();
		}

		// If the image is too large, scale it down
		// This is the maximum size we'll allow the image to occupy
		var max_w = 200, max_h = 200;
		if (w > max_w || h > max_h)	{
			var scale_w = w/max_w, scale_h = h/max_h;
			if (scale_w > scale_h) {
				w /= scale_w;
				h /= scale_w;
			} else {
				w /= scale_h;
				h /= scale_h;
			}
		}
		imgRef.width = w;
		imgRef.height = h;
		mb.log.info("New size: $x$", w, h);

		// Adjust the margin-right of the div which is next to this floating image
		var obj;
		if ((obj = imgRef.parentNode.nextSibling) != null) {
			obj.style.marginRight = "" + (w+10) + "px";
		}
		return mb.log.exit();
	};

	/**
	  * The purpose of this code is to resize Amazon cover art so that, if
	  * possible, it isn't scaled (it's displayed at its "natural" size).
	  *
	 **/
	this.setupAmazonCoverart = function() {
		mb.log.enter(this.GID, "setupAmazonCoverart");
		var imgs = document.images;
		var cnt = 0;
		for (var i=imgs.length-1; i>=0; i--) {
			var imgRef = imgs[i];
			if (imgRef.className == 'amazon_coverart' &&
				imgRef.complete) {
				this.unscaleAlbumArt(imgRef);
				cnt++;
			}
		}
		mb.log.debug("Resized $ images.", cnt);
		mb.log.exit();
	};

	// exit constructor
	mb.log.exit();
}