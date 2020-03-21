// $('body').terminal({
//     hello: function(what) {
//         this.echo('Hello, ' + what +
//                   '. Wellcome to this terminal.');
//     }
// }, {
//     greetings: 'Black Paths'
// });

const welcomeMessage = "-----------------------------------------------------------------<br>\
Welcome to Black Paths, a game of exploration based entirely\
 in text. <br><br> For a list of possible commands, type \"help\" and hit enter\
 -----------------------------------------------------------------";

const startingRoom = "A room";
const startingSpace = "Central";
const startingEvent = "Central";
var currentRoom = startingRoom;
var currentSpace = startingSpace;
var currentSpaceDetail = rooms[currentRoom]["spaces"][currentSpace]["detail"];
var commands = ["go", "inventory"];
var inventory = ["lighter"];

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

function showHelp() {
    $('.terminal-output').append("<p>Here are the possible commands: </p>");
    $('.terminal-output').append("<p><ul>");
    for (var i = 0; i < commands.length; i++) {
        $('.terminal-output').append("<li>" + commands[i] + "</li>");
    }
    $('.terminal-output').append("</ul></p>");

}

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

// $(document).ready(function() {
//     $('.terminal-output').append("<p>" + rooms.start.description + "</p>");

//     $(document).keypress(function(key) {
//         if (key.which === 13 && $('#user-input').is(':focus')) {
//             var value = $('#user-input').val().toLowerCase();
//             $('#user-input').val("");
//             playerInput(value);
//         }
//     })


// })

$('body').terminal(
  function(command) {
    playerInput(command);
  },
 { greetings: ""}, 
 { prompt: '>', name: 'test' });

// give starting message:
$('.terminal-output').append("<p>" + welcomeMessage + "</p>");
$('.terminal-output').append("<p>" + rooms[currentRoom]["description"] + "</p>");
$('.terminal-output').append("<p>" + currentSpaceDetail + "</p>");

