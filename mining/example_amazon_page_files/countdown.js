
/**
 * Creates an instance of AmazonCountdown.
 * @param {Number} timeRemaining Duration of the countdown (in seconds)
 * @param {Function} expirationCallback Function to call when countdown expires (optional)
 * @param {DOMElement} displayElement DOM element to be used for the display (optional)
 * @param {Function} formatFunction Function that takes hours, min, and sec and returns the display string (optional)
 * @param {Boolean} displayEnabled Whether or not the display is initially enabled (defaults to false)
 * @constructor
 */
function AmazonCountdown(timeRemaining, expirationCallback, displayElement, formatFunction, displayEnabled) {
    if (timeRemaining < 1) {
        return;
    }

    var that = this;

    /**
     * @type Number
     */
    this.endTime = this.getCurrentTime() + timeRemaining;

    /**
     * @type Function
     */
    this.expirationCallback = expirationCallback;

    /**
     * @type DOMElement
     */
    this.displayElement = displayElement;

    /**
     * @type Boolean
     */
    this.displayEnabled = !!displayEnabled;

    /**
     * @type Function
     */
    this.formatFunction = formatFunction;

    // Kick off countdown, refreshing every second
    this.update();

    /**
     * @type Number
     */
    this.currentTimer = setInterval(function() { that.update(); }, 60000);
}

/**
 * Updates the countdown state. Will also cause the display to be
 * updated with applicable. If the countdown has expired, the
 * expiration callback will be executed.
 */
AmazonCountdown.prototype.update = function() {
    var secondsLeft = this.endTime - this.getCurrentTime();
    if (secondsLeft < 0) {
        secondsLeft = 0;
    }

    this.updateDisplay(secondsLeft);

    if (secondsLeft === 0) {
        // Countdown has expired, execute callback if specified
        if (typeof this.expirationCallback === "function") {
            this.expirationCallback();
        }
        this.destroy();
    }
};

/**
 * Updates the display, if enabled.
 * @param {Number} secondsLeft Number of seconds remaining in the countdown
 */
AmazonCountdown.prototype.updateDisplay = function(secondsLeft) {
    if (this.displayElement && this.displayEnabled) {
        var h = Math.floor(secondsLeft / 3600);
        var m = Math.floor((secondsLeft % 3600) / 60);
        var s = secondsLeft % 60;
        this.displayElement.innerHTML = this.getCountdownDisplay(h, m, s);
    }
};

/**
 * Gets the display string for a given time. Defaults to
 * Hh Mm Ss. Will use the formatFunction instead if provided.
 * @param {Number} h Number of hours
 * @param {Number} m Number of minutes
 * @param {Number} s Number of seconds
 * @return {String} The display string to show
 */
AmazonCountdown.prototype.getCountdownDisplay = function(h, m, s) {
    if (typeof this.formatFunction === "function") {
        // Display format has been overidden
        return this.formatFunction(h, m, s);
    }
    return h + "h " + m + "m " + s + "s";
};

/**
 * Enable the countdown display
 */
AmazonCountdown.prototype.enableDisplay = function() {
    this.displayEnabled = true;
    this.update();
};

/**
 * Disable the countdown display
 * @param {Boolean} clearContent Whether or not to clear out the display
 */
AmazonCountdown.prototype.disableDisplay = function(clearContent) {
    this.displayEnabled = false;
    if (clearContent && this.displayElement) {
        this.displayElement.innerHTML = "";
    }
};

/**
 * Gets the current epoch time in seconds
 * @return {Number} the current time
 */
AmazonCountdown.prototype.getCurrentTime = function() {
    return Math.floor(+new Date() / 1000);
};

/**
 * Countdown destructor. Make sure to call this for instances
 * which are no longer required.
 */
AmazonCountdown.prototype.destroy = function() {
    clearTimeout(this.currentTimer);
};

if (typeof(P) !== 'undefined') {
    P.register("AmazonCountdown", function () {
        return AmazonCountdown;
    });
}

/**
 * Delete amznJQ declaration below only after this change is deployed
 * to Prod and all its consumers migrate their calls to AUI PageJS.
 */
amznJQ.declareAvailable('AmazonCountdown');
