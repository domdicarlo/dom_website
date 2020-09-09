// Some helpful constants
const versionInfo = "Version 0.0.1: Early Alpha <br>Gameplay limited to movement\
                     within a single room. Check back often for updates!<br><br> <hr>";
const welcomeMessage = "<hr> <br>\
Welcome to Black Paths, a game of exploration based entirely\
 in text. <br><br> For a list of possible commands, type \"help\" and hit enter <br><br> <hr>";
const startingRoom = "A room";
const startingSpace = "Central";
const startingEvent = "";

// In game variables, for which we change as the game progresses
var currentRoom = startingRoom;
var currentSpace = startingSpace;
var currentSpaceDetail = rooms[currentRoom]["spaces"][currentSpace]["detail"];
var commands = ["go", "inventory"];
var inventory = ["lighter"];

/* changeSpace
 * Description: Takes in a cardinal direction, and tries to change the
 *              players current position in the room by moving in that
 *              direction. 
 *
 *  Input: String dir - should be one of "NORTH", "SOUTH", "EAST", or "WEST"
 *
 *  Output: Changes the player's location by changing "currentSpace". If movement
 *          results in a change in room, changes "currentRoom" too. If direction
 *          is an invalid move, doesn't make the move. Prints out text for movement
 *          either way (either the event triggered by the movement, or
 *          movement error msg).
 * 
 *  To Add: Support for direction synonyms. Support for diagonal directions. 
 *          Multiple types of error messages for movement (depending on reason for
 *          inability)
 */
function changeSpace(dir) {
    if (rooms[currentRoom]["spaces"][currentSpace].directions[dir] !== undefined) {
        currentSpace = rooms[currentRoom]["spaces"][currentSpace].directions[dir];
        currentSpaceDetail = rooms[currentRoom]["spaces"][currentSpace]["detail"];
        // only add in detail text if it exits.
        if (currentSpaceDetail !== undefined) {
            $('.terminal-output').append("<p>" + currentSpaceDetail + "</p>");
        }
    } else {
        $('.terminal-output').append("<p>You can't walk through walls...</p>");
    }


}

/* showHelp
 * Description: Prints help information (such as commands)
 *
 *  Input: Nothing.
 *
 *  Output: Prints help info to screen.
 * 
 *  To Add: Possible arguments, for more information. More helpful information
 */
function showHelp() {
    $('.terminal-output').append("<p>Here are the possible commands: </p>");
    $('.terminal-output').append("<p><ul>");
    for (var i = 0; i < commands.length; i++) {
        $('.terminal-output').append("<li>" + commands[i] + "</li>");
    }
    $('.terminal-output').append("</ul></p>");

}

/* showInventory
 * Description: Prints inventory content to screen
 *
 *  Input: Nothing.
 *
 *  Output: Prints inventory to screen.
 * 
 *  To Add: Unsure now.
 */
function showInventory() {
    if (inventory.length === 0) {
        $('.terminal-output').append("<p>You are not carrying anything!</p>");
        return;
    }
    $('.terminal-output').append("<p>Here is your inventory: </p>");
    $('.terminal-output').append("<p><ul>");
    for (var i = 0; i < inventory.length; i++) {
        $('.terminal-output').append("<li>" + inventory[i] + "</li>");
    }
    $('.terminal-output').append("</ul></p>");

}

/* playerInput
 * Description: Handles all terminal input, as it is.
 *
 *  Input: The input text on the terminal before
 *         hitting "enter"
 *
 *  Output: Calls on appropriate function based on input,
 *          or prints to the screen that the input was
 *          invalid.
 * 
 *  To Add: A lot. We need to build an actual parser.
 */
function playerInput(input) {
    var command = input.split(" ")[0];
    switch (command) {
        case "go":
            var dir = input.split(" ")[1];
            changeSpace(dir);
            break;
        case "help":
            showHelp();
            break;
        case "inventory":
            showInventory();
            break;
        default:
            $('.terminal-output').append("<p>Invalid command!</p>");
    }
}

/* printStartInfo
 * Description: Prints to the terminal all info for starting a new
                game (welcome message, starting room description, etc.)
 *
 *  Input: Nothing.
 *
 *  Output: Prints to screen.
 * 
 *  To Add: Unsure now. Some sort of initial state
 *          (You are unaware of how you got here)
 */
function printStartInfo() {
    $('.terminal-output').append("<p>" + welcomeMessage + "</p>");
    $('.terminal-output').append("<p>" + versionInfo + "</p>");
    $('.terminal-output').append("<p>" + rooms[currentRoom]["description"] + "</p>");
    $('.terminal-output').append("<p>" + currentSpaceDetail + "</p>");
}

// The terminal function that creates the game interface.
$('body').terminal(
  function(command) {
    playerInput(command);
  }, 
 { prompt: '>', greetings: "" });

// give starting message:
printStartInfo();
