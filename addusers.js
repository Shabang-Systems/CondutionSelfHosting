const r = require('rethinkdb');
const readline = require("readline");

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

// TODO run expirements
// 1. Figure out if perms are all no by default or if they have to be set
// 2. Attempt to recreate table not found crashing
// 3. Implement things like user deletion

rl.question('Admin password (if one specified otherwise leave blank)', admin_password => {
    r.connect( {host:'localhost', port: 28015, user: "admin", password: admin_password}, function(err, conn) {
	rl.question('New user username: ', new_username => {
	    r.question('New user password: ', new_password => {
		r.db('rethinkdb').table('users').insert({id: new_username, password: new_password}).run(conn, (err, result) => {
		    if (err) console.log("something has gone wrong with creating that user please try again")
		    r.db('users').tableCreate(new_username).run(conn, (err, result) => {
			r.db('users').table(new_username).insert([{
			    tags: {},
			    tasks: {},
			    projects: {}
			}]).run(conn);
			r.db.('users').table(new_username).grant(new_username, {read: true, write: true, config: false});
		    })
		})
	    })
	})
    }
}
