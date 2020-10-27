Create an RDCMan (.rdg) file in an Azure Automation Workflow
============================================================

            

**Description**


This runbook generates a Remote Desktop Connection Manager (.rdg) file out of an existing Cloud Service.


Connect-Azure must be imported and published in order for this runbook to work.


It iterates through all your VMs in a cloud service and generates the required XML for the .RDG file.


You can then either copy/paste it - or use Set-Content & Set-AzureStorageBlobContent to put it into blob storage automatically..


This demonstrates usage and how to put it up into blob storage:

 

Here's what the powershell workflow does..


 


*) Downloads connection info for all your VMs in an Azure Cloud Services.


*) Generates an .RDG file XML for Remote Desktop Connection Manager (RDCMan)


*) Built to be run out of Azure Automation


 


* *


* *


        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
