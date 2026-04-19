# vSphere-8-IOPS-Manager
This utility was written primarily for my own needs, because starting with vSphere 8 VMware removed the ability to manage VM disk IOPS from the vCenter GUI, while the company I work for actively uses a mechanism for allocating IOPS on the storage system depending on the class and size of the target VM's disk.

# Requirements:
The utility requires PowerCLI (https://developer.broadcom.com/powercli) and PowerShell 7 to be installed.

Tested on VCF PowerCLI 9.0.0 and PowerShell 7.5.4, but it should also work with older versions of PowerCLI and PowerShell.
VCF PowerCLI 9.0.0 only works with PowerShell 7! (see PowerCLI documentation)

The executable .exe was built using Microsoft .NET SDK 9, so you can rebuild it yourself using the source script IOPSManager.ps1
