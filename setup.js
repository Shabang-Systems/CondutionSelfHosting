const r = require('rethinkdb');
const readline = require("readline");

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

var connection = null;

console.log("Welcome to Condution Self Hosting! We're really glad you're excited to run your own self hosted instance of the application database. Make sure to check our our guide at [insert link] for instructions on how to get started, troubleshooting tips, and limitations. If you have any questions make sure to join our discord!")

console.log("Step 1: Initializing connection with localhost")
r.connect( {host:'localhost', port: 28015, user: "admin", password: ''}, function(err, conn) {
    if (err) throw err;
    connection = conn;
    console.log("Step 2: Creating databases")
    r.dbCreate('users').run(conn, function(err, result) {
	if (err) console.log("Skipping: Database user already created");
    });

    r.dbCreate('workspaces').run(conn, function(err, result) {
	if (err) console.log("Skipping: Databases workspace already created");
    });
    rl.question('WARNING THIS WILL BE IMMUTABLE UPON CREATION inital user username: ', username => {
	rl.question('initial user password: ', password => {
	    r.db('rethinkdb').table('users').insert({id: username, password: password}).run(conn, (err, result) => {
		if (err) console.log("Something has gone wrong creating that user, please try again.");
		r.db('users').tableCreate(username).run(connection, function(err, result) {
		    if (err) console.log("A user with this name already exists, please try again.")
		    r.db('users').table(username).insert([{
			tags: {},
			tasks: {},
			projects: {}
		    }]).run(connection);
		    r.db('users').table(username).grant(username, {read: true, write: true, config: true});

		process.exit()
		})
	    })
	})
    })
    
});


