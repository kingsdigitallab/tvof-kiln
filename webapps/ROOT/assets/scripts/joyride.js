/**
 * Adapted from the Mighty Brian's cookie code.
 * Gets a cookie. Mmmmmmmmm
 */
function getCookie(name) {
    var results = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');

    if (results) {
        return unescape(results[2]);
    } else {
        return null;
    }
}

/**
 * Sets a cookie! Put that cookie down!
 */
function setCookie(name, value, validDays) {
    var expiry = new Date();

    if (validDays != null) {
        expiry.setDate(expiry.getDate() + validDays);
    } else {
        expiry.setDate(expiry.getDate() + 365);
    }

    document.cookie = name + "=" + escape(value) + "; expires=" + expiry.toUTCString() + "; path=/";
}

$(document).ready( function() {
    if (getCookie('joyride') != 'ridden') {
        $(document).foundation('joyride', 'start');
    }

    setCookie('joyride', 'ridden', 365);
});
