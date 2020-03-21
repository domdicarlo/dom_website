// $('body').terminal({
//     hello: function(what) {
//         this.echo('Hello, ' + what +
//                   '. Wellcome to this terminal.');
//     }
// }, {
//     greetings: 'Black Paths'
// });

const startingRoom = "A room";
const startingSpace = "Central";
var currentRoom = startingRoom;
var currentSpace = startingSpace;
var commands = ["go", "inventory"];
var inventory = ["lighter"];

function changeRoom(dir) {
    if (rooms[currentRoom][currentSpace].directions[dir] !== undefined) {
        currentRoom = rooms[currentRoom][currentSpace].directions[dir];
        $('.terminal-output').append("<p>" + rooms[currentRoom].description + "</p>");
    } else {
        $('.terminal-output').append("<p>You cannot go that way!</p>");
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
            changeRoom(dir);
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
 { greetings: 'Black Paths'}, 
 { prompt: '>', name: 'test' });