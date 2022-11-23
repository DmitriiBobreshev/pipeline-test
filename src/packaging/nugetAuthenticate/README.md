This repository provides the Yaml files and custom nuget.config files for the NuGet Authenticate task. 
It uses the InternalDependency and ExternalDependency projects from the NuGet task in src\packaging\nuget\NuGetV2.

Scenarios
=========

InternalDependency -- This project has a dependency on an internal package sources in the BuildCanary account.

ExternalDependency -- This project has a dependency on an external package sources in the CodeSharing-SU0 account.

Requirements
============

Project scoped internal package source -- https://pkgs.dev.azure.com/buildcanary/CanaryBuilds/_packaging/CanaryBuilds/nuget/v3/index.json

Collection scoped internal package source -- https://pkgs.dev.azure.com/buildcanary/_packaging/Canary/nuget/v3/index.json

Public internal package source -- https://buildcanary.pkgs.visualstudio.com/PipelineCanary/_packaging/PipelineCanary-Public/nuget/v3/index.json

Internal package        -- TestPackages.Adder@1.0.1

Project scoped external package source -- https://pkgs.dev.azure.com/codesharing-SU0/dc67aaa1-8d0a-4b1d-9312-8409aadc06d8/_packaging/TestProject-Canary/nuget/v3/index.json

Collection scoped external package source -- https://pkgs.dev.azure.com/codesharing-SU0/_packaging/Canary/nuget/v3/index.json

Public external package source -- https://pkgs.dev.azure.com/codesharing-SU0/Test-Public/_packaging/PublicCanary/nuget/v3/index.json

External package        -- TestPackages.Subtracter@1.0.2

Service Connection      -- To External Package Source, refresh PAT in service connections every year with a new 12 month PAT.
                        -- PAT should be scoped to Packaging read/write
