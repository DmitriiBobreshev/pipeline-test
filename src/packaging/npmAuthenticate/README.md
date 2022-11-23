# Introduction
This project is intended to test the npm authenticate task.
- The first level of this git repo includes a package.json which installs gulp and a gulp plugin
- Once installed, gulp should be called (e.g. .\node_modules\.bin\gulp)
- Gulp will then run the default target in gulpfile.js
- The gulpfile has targets which will CWD into projecta, run 'npm config ls', and finally 'npm install'

Since there are no credentials in the .npmrc which lives in the projecta directory, 'npm install' will fail *unless* you have configured a "NPM Authenticate" task to inject credentials into it.