This repository provides buildable scenarios to test the VSTS DotNetCore build tasks

Scenarios
=========
Simple -- a simple project, with no packages to restore

InternalDependency -- This project has a dependency on an internl package sources in the BuildCanary account.

ExternalDependency -- This project has a dependency on an external package sources in the CodeSharing-SU0 account.

Requirements
============

Internal package source -- https://buildcanary.pkgs.visualstudio.com/_packaging/Canary/nuget/v3/index.json

Internal package        -- TestPackages.Adder@1.0.1

External package source -- https://codesharing-su0.pkgs.visualstudio.com/_packaging/Canary/nuget/v3/index.json

External package        -- TestPackages.Subtracter@1.0.2

Service Connection      -- To External Package Source, refresh PAT in service connection every year with a new 12 month PAT.
                        -- PAT should be scoped to Packaging read/write