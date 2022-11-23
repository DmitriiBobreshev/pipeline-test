# MavenAuthenticate@0 task canary tests

This yaml runs these tests for the MavenAuthenticate@0 task:

1. Install maven package from private collection scoped feed.
    * Uses ProjectA to download package Project from https://buildcanary.pkgs.visualstudio.com/_packaging/Canary/maven/v1
2. Install maven package from a public feed.
    * Uses ProjectA to download package ProjectB from public feed  https://buildcanary.pkgs.visualstudio.com/PublicCanary/_packaging/PublicCanary/maven/v1
3. Install maven package from an external feed using a service connection.
    * Uses ProjectA to download package ProjectD from project-scoped feed  https://pkgs.dev.azure.com/codesharing-SU0/dc67aaa1-8d0a-4b1d-9312-8409aadc06d8/_packaging/TestProject-Canary/maven/v1
    * The service connection used is 'Maven-TestProject-Canary@Codesharing-SU0'. It is authenticated using a PAT, which should be updated every year and should be scoped to Packaging read/write.
4. Deploy a package to collection scoped feed
    * Uses ProjectB to deploy package ProjectB to feed https://buildcanary.pkgs.visualstudio.com/_packaging/Canary/maven/v1
5. Deploy a package to project-scoped feed 
    * Uses ProjectC to deploy package ProjectC to feed https://buildcanary.pkgs.visualstudio.com/PublicCanary/_packaging/PublicCanary/maven/v1