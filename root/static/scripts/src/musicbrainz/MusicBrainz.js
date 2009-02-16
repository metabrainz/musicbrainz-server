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
   * Main class of the musicbrainz javascript framework
  *
  **/
function MusicBrainz() {

	// ----------------------------------------------------------------------------
	// register class/global id
	// ---------------------------------------------------------------------------
	this.CN = "MusicBrainz";
	this.GID = "mb";
	mb = this;

	// ----------------------------------------------------------------------------
	// global variables
	// ---------------------------------------------------------------------------
	mb.utils = new MbUtils();
	mb.cookie = new MbCookie();
	mb.log = new MbLog(); // order of the objects is important!
	mb.ui = new MbUI();

	// hello world!
	mb.log.scopeStart("Loading the Musicbrainz object");
	mb.log.enter("MusicBrainz", "__constructor");

	// onload handlers
	mb.onPageLoadedActions = [];
	mb.onPageLoadedFlag = false;
	mb.onDomReadyActions = [];
	mb.onDomReadyFlag = false;

	// ----------------------------------------------------------------------------
	// member functions
	// ---------------------------------------------------------------------------

	/**
	  * Returns if the onPageLoaded function have been called
	  *
	  * @returns true, if the window.onload event has _not_ been fired
	  * @see MbLog#scopeStart
	 **/
	mb.isPageLoading = function() {
		return !mb.onPageLoadedFlag;
	};

	/**
	  * Register a function to the stack of methods that are executed
	  * after the window.onload event has fired.
	  *
	  * @param action	the MbEventAction object describing the
	  *					registered function call.
	 **/
	mb.registerPageLoadedAction = function(action) {
		mb.log.enter(mb.GID, "registerPageLoadedAction");
		if (action instanceof MbEventAction) {
			mb.onPageLoadedActions.push(action);
		} else {
			mb.log.error("Invalid argument, expected MbEventAction: $", action);
		}
		mb.log.exit();
	};

	/**
	  * Function which is handles the window.onload event.
	  * Executes the list of registered onPageLoadedActions in the
	  * order they were registed.
	  *
	  * @returns	null
	 **/
	mb.onPageLoaded = function() {
		if (mb.onPageLoadedActions.length > 0) {
			mb.log.scopeStart("Executing onPageLoaded functions");
			mb.log.enter(mb.GID, "onPageLoaded");
			if (!mb.onPageLoadedFlag) {
				if (!mb.onDomReadyFlag) {
					mb.runRegisteredFunctions(mb.onDomReadyActions, "onDomReady");
				}
				mb.onPageLoadedFlag = true;
				mb.runRegisteredFunctions(mb.onPageLoadedActions, "onPageLoaded");
			}
			mb.log.exit();
		}
		mb.log.scopeEnd(); // dump all after page has loaded.
	};
	window.onload = mb.onPageLoaded; // register our onload handler

	/**
	  * Adds a function to the methods that are executed after the
	  * document object model is ready.
	  *
	  * @param action	the MbEventAction object describing the
	  *					registered function call.
	 **/
	mb.registerDOMReadyAction = function(action) {
		mb.log.enter(mb.GID, "registerDOMReadyAction");
		if (action instanceof MbEventAction) {
			mb.onDomReadyActions.push(action);
		} else {
			mb.log.error("Invalid argument, expected MbEventAction: $", action);
		}
		mb.log.exit();
	};

	/**
	  * This method is called if the browser supports detected
	  * of the document.readystate (ie) or supports the eventhandler
	  * for DomContentLoaded (mozilla)
	  *
	  * @see domloaded.js (in /comp/footer)
	 **/
	mb.onDomReady = function() {
		if (mb.onDomReadyActions.length > 0) {
			mb.log.scopeStart("Executing onDomReady functions");
			mb.log.enter(mb.GID, "onDomReady");
			if (!mb.onDomReadyFlag) {
				// flag, so we don't run this twice
				mb.onDomReadyFlag = true;
				mb.log.enter(mb.GID, "onDomReady");
				mb.runRegisteredFunctions(mb.onDomReadyActions, "onDomReady");
				mb.log.exit();
			}
		}
		mb.log.exit();
	};

	/**
	  * Iterates through the functions array <code>actions</code>, and
	  * executes the defined functions.
	  *
	  * @param actions	the list of registered ActionEvent objects
	  *					to handle.
	 **/
	mb.runRegisteredFunctions = function(actions) {
		var i=0, len=actions.length;
		if (len > 0) {
			mb.log.trace("Running $ actions...", len);
			do {
				var action = actions[i];
				if (action instanceof MbEventAction) {
					mb.log.info("* $", action);
					try {
						eval(action.getCode());
					} catch (e) {
						mb.log.error("Caught exception: ", e);
						mb.log.error(mb.log.getStackTrace());
					}
				} else {
					mb.log.error("Invalid object, expected MbEventAction: $", action);
				}
			} while (len > ++i);
		}
	};

	// prepare global objects...
	mb.ua = new MbUserAgent();
	mb.sidebar = new MbSideBar();
	mb.topmenu = new MbTopMenu();
	mb.albumart = new MbAlbumArtResizer();
	mb.diff = new MbDiff();

	// register DOMReady actions...
	mb.registerDOMReadyAction(
		new MbEventAction(mb.topmenu.GID, 'setupTopMenu', "Setting up topmenu events.")
	);
	mb.registerDOMReadyAction(
		new MbEventAction(mb.ui.GID, 'setupPopupLinks', "Setting up popup links")
	);
	mb.registerDOMReadyAction(
		new MbEventAction(mb.ui.GID, 'setupFeedbackBoxes', "Setting up feedback boxes")
	);

	mb.registerPageLoadedAction(
		new MbEventAction(mb.ui.GID, 'setupKeyboardFocus', "Setting up keyboard focus input.")
	);
	mb.registerPageLoadedAction(
		new MbEventAction(mb.albumart.GID, 'setupAmazonCoverart', "Resize amazon coverart")
	);

	// exit constructor
	mb.log.exit();
}