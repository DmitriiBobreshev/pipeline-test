"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
var path = require('path');
var url = require('url');
var fs = require('fs');
const tl = require("azure-pipelines-task-lib/task");
const engine = require("artifact-engine/Engine");
const providers = require("artifact-engine/Providers");
var taskJson = require('./task.json');
tl.setResourcePath(path.join(__dirname, 'task.json'));
const area = 'DownloadFileShareArtifacts';
function getDefaultProps() {
    const hostType = (tl.getVariable('SYSTEM.HOSTTYPE') || "").toLowerCase();
    return {
        hostType: hostType,
        definitionName: '[NonEmail:' + (hostType === 'release' ? tl.getVariable('RELEASE.DEFINITIONNAME') : tl.getVariable('BUILD.DEFINITIONNAME')) + ']',
        processId: hostType === 'release' ? tl.getVariable('RELEASE.RELEASEID') : tl.getVariable('BUILD.BUILDID'),
        processUrl: hostType === 'release' ? tl.getVariable('RELEASE.RELEASEWEBURL') : (tl.getVariable('SYSTEM.TEAMFOUNDATIONSERVERURI') + tl.getVariable('SYSTEM.TEAMPROJECT') + '/_build?buildId=' + tl.getVariable('BUILD.BUILDID')),
        taskDisplayName: tl.getVariable('TASK.DISPLAYNAME'),
        jobid: tl.getVariable('SYSTEM.JOBID'),
        agentVersion: tl.getVariable('AGENT.VERSION'),
        agentOS: tl.getVariable('AGENT.OS'),
        agentName: tl.getVariable('AGENT.NAME'),
        version: taskJson.version
    };
}
function publishEvent(feature, properties) {
    try {
        var splitVersion = (process.env.AGENT_VERSION || '').split('.');
        var major = parseInt(splitVersion[0] || '0');
        var minor = parseInt(splitVersion[1] || '0');
        let telemetry = '';
        if (major > 2 || (major == 2 && minor >= 120)) {
            telemetry = `##vso[telemetry.publish area=${area};feature=${feature}]${JSON.stringify(Object.assign(getDefaultProps(), properties))}`;
        }
        else {
            if (feature === 'reliability') {
                let reliabilityData = properties;
                telemetry = "##vso[task.logissue type=error;code=" + reliabilityData.issueType + ";agentVersion=" + tl.getVariable('Agent.Version') + ";taskId=" + area + "-" + JSON.stringify(taskJson.version) + ";]" + reliabilityData.errorMessage;
            }
        }
        console.log(telemetry);
        ;
    }
    catch (err) {
        tl.warning("Failed to log telemetry, error: " + err);
    }
}
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        const promise = new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
            const downloadPath = tl.getInput("downloadPath", true);
            const debugMode = tl.getVariable('System.Debug');
            const isVerbose = debugMode ? debugMode.toLowerCase() != 'false' : false;
            const parallelLimit = +tl.getInput("parallelizationLimit", false);
            const retryLimit = parseInt(tl.getVariable("VSTS_HTTP_RETRY")) ? parseInt(tl.getVariable("VSTS_HTTP_RETRY")) : 4;
            const itemPattern = tl.getInput("itemPattern", false) || '**';
            const downloader = new engine.ArtifactEngine();
            const downloadUrl = tl.getInput("filesharePath", true);
            let artifactName = tl.getInput("artifactName", true);
            artifactName = artifactName.replace('/', '\\');
            let artifactLocation = path.join(downloadUrl, artifactName);
            console.log(tl.loc("DownloadArtifacts", artifactName, artifactLocation));
            if (!fs.existsSync(artifactLocation)) {
                console.log(tl.loc("ArtifactNameDirectoryNotFound", artifactLocation, downloadUrl));
                artifactLocation = downloadUrl;
            }
            let downloaderOptions = new engine.ArtifactEngineOptions();
            downloaderOptions.itemPattern = itemPattern;
            downloaderOptions.verbose = isVerbose;
            if (parallelLimit) {
                downloaderOptions.parallelProcessingLimit = parallelLimit;
            }
            let fileShareProvider = new providers.FilesystemProvider(artifactLocation, artifactName);
            let fileSystemProvider = new providers.FilesystemProvider(downloadPath);
            let downloadPromise = downloader.processItems(fileShareProvider, fileSystemProvider, downloaderOptions);
            downloadPromise.then(() => {
                console.log(tl.loc('ArtifactsSuccessfullyDownloaded', downloadPath));
                resolve();
            }).catch((error) => {
                reject(error);
            });
        }));
        return promise;
    });
}
main()
    .then((result) => tl.setResult(tl.TaskResult.Succeeded, ""))
    .catch((err) => {
    publishEvent('reliability', { issueType: 'error', errorMessage: JSON.stringify(err, Object.getOwnPropertyNames(err)) });
    tl.setResult(tl.TaskResult.Failed, err);
});
