const { exit } = require('process');

const spawn = require('child_process').spawn;

const child = spawn(process.argv[0], ['shell_build.js'], {
    detached: true,
    stdio: ['ignore']
});
    
child.unref();
process.exit()