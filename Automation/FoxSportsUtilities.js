function NBAPreGameChip(cellLabel) {
    var labelParts = cellLabel.split(", ");

    this.teams = labelParts.shift();
    this.startDate = labelParts.shift();
    this.channel = labelParts.shift();
    this.videoAvailability = labelParts.shift();
}

function NBAGameChip(cellLabel) {
    var labelParts = cellLabel.split(", ");

    this.nowPlaying = labelParts.shift();
    this.teams = labelParts.shift();
    this.gameQuarter = labelParts.shift();
    this.timeLeft = labelParts.shift();
    this.awayTeamScore = labelParts.shift();
    this.homeTeamScore = labelParts.shift();
    this.channel = labelParts.shift();
    this.videoAvailability = labelParts.shift();
}

function madeIt() {
    UIALogger.logMessage("Made it here!");
}

function log(message) {
    UIALogger.logMessage(message);
}

function FSNBATeamSchedulePastGame(name) {

    var scheduleParts = name.split(",");

    this.date = scheduleParts.shift() + ", " + scheduleParts.shift();
    this.opponent = scheduleParts.shift();
    this.result = scheduleParts.shift();
    this.hi_points = scheduleParts.shift();
    this.hi_rebounds = scheduleParts.shift();
}

function testLineScore(predicate, totalScoreLabel) {
    var lineScoreView = getLineScoreElement();
    var periedScoreElements = getLineScorePeriodsElement().staticTexts().withPredicate(predicate);
    $.Assert.isNotNull(periedScoreElements, "Could not find and period score elements with the predicate \"" + predicate + "\"");

    var i, len = periedScoreElements.length,
        score = 0;

    for (i = 0; i < len; i++) {
        var periodScore = periedScoreElements[i].value();
        if (!/^-+$/.test(periodScore)) {
            score = score + parseInt(periodScore);
        }
    }

    var totalScoreElement = lineScoreView.staticTexts()[totalScoreLabel];
    $.Assert.isValid(totalScoreElement, "The total score element with the label \"" + +"\" does not exist");

    var totalScore = parseInt(totalScoreElement.value());
    $.Assert.isTrue(score == totalScore, "The sum of the period scores (" + score + ") does not match the teams total score (" + totalScore + ")");
}

function testLineScoreLabels(requiredLabels) {
    const LINE_SCORE_TOTAL_SCORE_LABEL_ID = "totalScoreLabel";
    const LINE_SCORE_TOTAL_SCORE_LABEL_VALUE = "TOTAL";

    var lineScoreElement = getLineScoreElement();
    var lineScorePeriodsElement = getLineScorePeriodsElement();

    var i = header = null;
    for (i in requiredLabels) {
        header = lineScorePeriodsElement.staticTexts()[i];
        $.Assert.isValid(header, "The required label \"" + i + "\" does not exist");
        $.Assert.isEqual(header.value(), requiredLabels[i], "The value for " + i + ", \"" + header.value() + "\", does not match the specified value \"" + requiredLabels[i] + "\"");
    }

    var totalScoreLabel = lineScoreElement.staticTexts()[LINE_SCORE_TOTAL_SCORE_LABEL_ID];
    $.Assert.isValid(totalScoreLabel, "The required label \"" + LINE_SCORE_TOTAL_SCORE_LABEL_ID + "\" does not exist");
    $.Assert.isEqual(totalScoreLabel.value(), LINE_SCORE_TOTAL_SCORE_LABEL_VALUE, "The value for the total score label, \"" + totalScoreLabel.value() + "\", does not match the specified value \"" + LINE_SCORE_TOTAL_SCORE_LABEL_VALUE + "\"");
}

function navigateToOrganizationEvent(organization, event) {
    var orgList = $.mainWindow.tableViews()["organization list"];

    $.Assert.isValid(orgList.cells()[organization], "The organization \"" + organization + "\" does not exist");

    if (orgList.selectedCell().name() != organization) {
        orgList.cells()[organization].tap();
        $.Assert.isEqual(orgList.selectedCell().name(), organization, "The organization \"" + organization + "\" was not able to be selected or did not remain selected");
    }

    if (event == null) {
        // Don't try and select an event if the tester doesn't pass in one
        return;
    }

    var eventsList = $.mainWindow.elements()["eventsSection"].tableViews()["eventsList"];
    var eventName = null;

    if (!isNaN(event)) {
        $.Assert.isValid(eventsList.cells()[event], "No event exists at index " + event);
        eventName = eventsList.cells()[event].name();
    } else {
        eventName = event
        $.Assert.isValid(eventList.cells()[eventName], "The event with identifier \"" + eventName + "\" does not exist");
    }

    eventsList.cells()[eventName].tap();
    $.Assert.isEqual(eventsList.selectedCell().name(), eventName, "The event \"" + eventName + "\" was not able to be selected or did not remain selected");
}

function navigateToNBAGameStatsForEvent(event) {
    const NBA_ORGANIZATION_ID = "NBA";
    const GAME_STATS_BUTTON_ID = "Stats";

    navigateToEventSectionForOrganizationEvent(GAME_STATS_BUTTON_ID, NBA_ORGANIZATION_ID, event);
}

function navigateToEventSectionForOrganizationEvent(section, organization, event) {
    navigateToOrganizationEvent(organization, event);

    var controller = getEventDetailsSegmentedController();
    var sectionButton = controller.buttons().firstWithName(section);
    $.Assert.isValid(sectionButton, "The section button named \"" + section + "\" does not exist");

    if (controller.selectedButton().name() != sectionButton.name()) {
        sectionButton.tap();
    }
}

function getLineScoreElement() {
    const EVENT_DETAILS_ID = "eventDetails";
    const EVENT_STATS_ID = "gameStats";
    const EVENT_LINE_SCORE_ID = "lineScore";

    var lineScoreElement = $.mainWindow.scrollViews()[EVENT_DETAILS_ID].scrollViews()[0].scrollViews()[EVENT_STATS_ID].elements()[EVENT_LINE_SCORE_ID];
    $.Assert.isValid(lineScoreElement, "The line score does not exist");

    return lineScoreElement;
}

function getLineScorePeriodsElement() {
    const EVENT_LINE_SCORE_PERIOD_SCORES_ID = "periodScores";

    var lineScoreElement = getLineScoreElement();
    var periodScoresElement = lineScoreElement.scrollViews()[EVENT_LINE_SCORE_PERIOD_SCORES_ID];
    $.Assert.isValid(periodScoresElement, "The line score period scores scroll view does not exist");

    return periodScoresElement;
}

function getEventDetailsSegmentedController() {
    const EVENT_DETAILS_ID = "eventDetails";
    const EVENT_DETAILS_SEGMENTED_CONTROLLER_ID = "eventDetailsSegmentedController";

    var controller = $.mainWindow.elements()[EVENT_DETAILS_ID].segmentedControls()[EVENT_DETAILS_SEGMENTED_CONTROLLER_ID];
    $.Assert.isValid(controller, "The Event Details controller does not exist");

    return controller;
}
