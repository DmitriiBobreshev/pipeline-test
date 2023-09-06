var fs = require('fs');

fs.readFile('generated.json', 'utf8', function(err, data) {
    console.log(data.toString());
});