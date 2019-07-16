## XDHealthCheck

Functions to connect to a Citrix Farm and extract details for a HTML Health check Dashboard

**To get started run the following:**

- ```Install-Module -Name XDHealthCheck```
- ```Import-Module XDHealthCheck```
- ```Install-ParametersFile```


And answer the setup questions.

Once everything is setup you can run  ```Start-CitrixHealthCheck -JSONParameterFilePath <ParametersFile>``` for the main health check report, or run ```Start-CitrixAudit -JSONParameterFilePath <ParametersFile>``` for an audit on machine catalogues, delivery groups and published applications.

I’ve also created some reports under Reporting folder.
