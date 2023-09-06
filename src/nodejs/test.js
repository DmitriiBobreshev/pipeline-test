const {
    randomBytes
  , createHash
  } = require('crypto');

async function test() {
    const hrtime = process.hrtime.bigint;
    const tsg = hrtime();
    const messages = Array(1 << 23).fill().map(_ => randomBytes(1 << 16));
    console.log('generated:', Number(hrtime() - tsg) / 1e6 | 0, 'ms');

    const tsh = hrtime();
    const hashes = messages.map(data => createHash('sha256').update(data).digest('hex'));
    console.log('hashed:   ', Number(hrtime() - tsh) / 1e6 | 0, 'ms');
    return 2;
}
async function main() {
    let i = 0;
    while (i++ < 1000000000) {
        await Promise.all([test(), test(), test(), test(), test(), test(), test(), test()]);
    }
}


main();
