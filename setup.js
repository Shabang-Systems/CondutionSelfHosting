const r = require('rethinkdb');
const readline = require("readline");

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

var connection = null;

console.log("Welcome to Condution Self Hosting! We're really glad you're excited to run your own self hosted instance of the application database. Make sure to check our our guide at [insert link] for instructions on how to get started, troubleshooting tips, and limitations.")

console.log("Step 1: Initializing connection with localhost")
r.connect( {host:'localhost', port: 28015, user: "admin"}, function(err, conn) {
    if (err) throw err;
    connection = conn;
    console.log("Step 2: Creating databases")
    r.dbCreate('users').run(conn, function(err, result) {
	if (err) console.log("Skipping: Database user already created");
    });

    r.dbCreate('workspaces').run(conn, function(err, result) {
	if (err) console.log("Skipping: Databases workspace already created");
    });
    readline.question('WARNING THIS WILL BE IMMUTABLE UPON CREATION inital user username: ', username => {
	readline.question('initial user password: ', password => {
	    r.db('rethinkdb').table('users').insert({id: username, password: password})
	})
    })
});


