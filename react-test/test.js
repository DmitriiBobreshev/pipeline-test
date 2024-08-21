var ncp = require('child_process');
var run = function (cl, inheritStreams) {
    console.log('');
    console.log(`> ${cl}`);
    var options = {
        stdio: inheritStreams ? 'inherit' : 'pipe'
    };
    var rc = 0;
    var output;
    try {
        output = ncp.execSync(cl, options);
    }
    catch (err) {
        if (!inheritStreams) {
            console.error(err.output ? err.output.toString() : err.message);
        }

        throw new Error(`The following command line failed: '${cl}'`);
    }

    output = (output || '').toString().trim();
    if (!inheritStreams) {
        console.log(output);
    }

    return output;
}

const deps = require('./deps.json');
const failed = [];

for (const dep of deps.developmentDependencies) {
  const [packageName, version] = dep.split(' ')
  try {
    run(`npm install ${packageName + '@' + version} --save-dev`, true);
  } catch (e) {
    failed.push(`${packageName}@${version}`);
  }
}

for (const dep of deps.dependencies) {
  const [packageName, version] = dep.split(' ')
  try {
    run(`npm install ${packageName + '@' + version} --save`, true);
  } catch (e) {
    failed.push(`${packageName}@${version}`);
  }
}

console.log(failed)