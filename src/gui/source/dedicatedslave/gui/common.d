module dedicatedslave.gui.common;

import std.algorithm;
import std.experimental.logger;
import std.signals;
import std.string;

/**************************************************************
 * This block defines some generic signal handling based on D's
 * std.Signals package. All of the internal D's signals use this
 * as a way to communicate with each other. This is new since
 * version 1.40. The old way of using delegates had a memory leak
 * issue associated with it, not sure if it's a D bug or something
 * in the code. However was wanting to switch to this for awhile so
 * made sense to change anyway.
 **************************************************************/
public:

/**
 * Generic signal struct
 */
struct GenericEvent(TArgs...) {
  mixin Signal!TArgs;
}

/***********************************************************
 * Function for parsing out the username, hostname and
 * directory from a string in the format
 * 'user@hostname:directory' where the various parts are
 * optional but the delimiters are not
 ***********************************************************/

void parsePromptParts(string prompt, out string username, out string hostname, out string directory) {
    if (prompt.length == 0) return;
    ptrdiff_t userStarts = prompt.indexOf('@');
    ptrdiff_t dirStarts = prompt.indexOf(':');

    if (userStarts > 0) {
        username = prompt[0..userStarts];
    }
    if (dirStarts >= 0) {
        hostname = prompt[max(0, userStarts + 1)..dirStarts];
    } else {
        hostname = prompt[max(0, userStarts + 1)..prompt.length];
    }
    if (dirStarts >=0 ) {
        directory = prompt[max(0, dirStarts + 1)..prompt.length];
    }
}