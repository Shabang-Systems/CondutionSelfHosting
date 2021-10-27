const r = require('rethinkdb');
const readline = require("readline");

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

// TODO run expirements
// 1. Figure out if perms are all no by default or if they have to be set
// 2. Attempt to recreate table not found crashing


rl.question('Admin password (if one specified otherwise leave blank)', admin_password => {
    r.connect( {host:'localhost', port: 28015, user: "admin", password: admin_password}, function(err, conn) {
	rl.question('New user username: '){}
    }
}
