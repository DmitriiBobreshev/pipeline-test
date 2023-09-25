process.once('SIGINT', function (code) {
  console.log('SIGINT received...');
});


process.once('SIGTERM', function (code) {
  console.log('SIGTERM received...');
});

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  while (true) {
    console.log('running...');
    await sleep(1000);
  }
}

main()