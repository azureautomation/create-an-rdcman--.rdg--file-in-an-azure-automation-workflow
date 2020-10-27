workflow Get-RDCManFile
{
    [OutputType("system.string")]
  	Param 
    (             
        [parameter(Mandatory=$true)]
        [String] 
        $AzureConnectionName,
		
        [parameter(Mandatory=$true)] 
        [String] 
        $ServiceName,
		
        [parameter(Mandatory=$true)] 
        [String]
        $AdminUser,
		
        [parameter(Mandatory=$false)] 
        [String] 
        $AdminPwd = "",
		
        [parameter(Mandatory=$false)] 
        [String] 
        $Domain = ""
    )
    
    Connect-Azure -AzureConnectionName $AzureConnectionName

   	InlineScript
	{
		#Create a template XML
		$template = '<?xml version="1.0" encoding="utf-8"?>
		<RDCMan schemaVersion="1">
			<version>2.2</version>
			<file>
				<properties>
					<name></name>
					<expanded>True</expanded>
				</properties>
				<group>
					<properties>
						<name></name>
						<expanded>True</expanded>
						<logonCredentials inherit="None">
							<userName></userName>
							<domain></domain>
							<password storeAsClearText="True"></password>
						</logonCredentials>
					</properties>
					<server>
						<name></name>
						<displayName></displayName>
						<connectionSettings inherit="None">
							<port></port>
						</connectionSettings>
					</server>
				</group>
			</file>
		</RDCMan>'

		#Load template into XML object
		$xml = New-Object xml
		$xml.LoadXml($template)

		#Set file properties
		$file = (@($xml.RDCMan.file.properties)[0]).Clone()
		$file.name = $Using:AzureConnectionName
		$xml.RDCMan.file.properties | Where-Object { $_.Name -eq "" } | ForEach-Object  { [void]$xml.RDCMan.file.ReplaceChild($file,$_) }

		
		#Set group properties
		$group = (@($xml.RDCMan.file.group.properties)[0]).Clone()
		$group.name = $Using:ServiceName
		$group.logonCredentials.Username = $Using:AdminUser
		$group.logonCredentials.Password.InnerText = $Using:AdminPwd
		$group.logonCredentials.Domain = $Using:Domain
		$xml.RDCMan.file.group.properties | Where-Object { $_.Name -eq "" } | ForEach-Object  { [void]$xml.RDCMan.file.group.ReplaceChild($group,$_) }

		$server = (@($xml.RDCMan.file.group.server)[0]).Clone()

		ForEach ($vm in (Get-AzureVM -ServiceName $Using:ServiceName)) 
		{ 
			$ep = Get-AzureEndpoint -Name RDP -VM $vm
			
			$server = $server.clone()	
			$server.DisplayName = $vm.Name
			$server.Name = $Using:ServiceName + ".cloudapp.net"
			$server.connectionSettings.port = $ep.Port.ToString()
			$xml.RDCMan.file.group.AppendChild($server) > $null
			#Remove template server
			$xml.RDCMan.file.group.server | Where-Object { $_.Name -eq "" } | ForEach-Object  { [void]$xml.RDCMan.file.group.RemoveChild($_) }
		}
		
		Write-Output $xml.OuterXml
	}
}