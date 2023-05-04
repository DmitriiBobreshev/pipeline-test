const cluster = require('cluster');
const numCPUs = require('os').cpus().length * 10;
const {
    randomBytes
    , createHash
} = require('crypto');

async function test() {
    const hrtime = process.hrtime.bigint;
    const tsg = hrtime();
    const messages = Array(1 << 12).fill().map(_ => randomBytes(1 << 16));
    console.log('generated:', Number(hrtime() - tsg) / 1e6 | 0, 'ms');

    const tsh = hrtime();
    const hashes = messages.map(data => createHash('sha256').update(data).digest('hex'));
    console.log('hashed:   ', Number(hrtime() - tsh) / 1e6 | 0, 'ms');
}

async function main(func) {
    let i = 0;
    while (i++ < 100000000000) {
        await Promise.all([func(), func(), func(), func(), func(), func(), func(), func()]);
    }
}

function noOp() {};

function Cleanup(callback) {
    // attach user callback to the process event emitter
    // if no callback, it will still exit gracefully on Ctrl-C
    callback = callback || noOp;
    process.on('cleanup',callback);
  
    // do app specific cleaning before exiting
    process.on('exit', function () {
      process.emit('cleanup');
      process.exit(2);
    });
  
    // catch ctrl+c event and exit normally
    process.on('SIGINT', function () {
        process.emit('cleanup');
      process.exit(2);
    });
  
    //catch uncaught exceptions, trace, then exit normally
    process.on('uncaughtException', function(e) {
      console.log('Uncaught Exception...');
      console.log(e.stack);
      process.emit('cleanup');
      process.exit(2);

    });
};

Cleanup(function() {
    console.log('cleanup');
})
process.stdin.resume();

if (cluster.isMaster) {
    console.log(`Master ${process.pid} is running`);

    // Fork workers.
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }

    cluster.on('exit', (worker, code, signal) => {
        console.log(`worker ${worker.process.pid} died`);
    });
    main(test)
} else {
    console.log(`Worker ${process.pid} started`);
    main(test)
}

