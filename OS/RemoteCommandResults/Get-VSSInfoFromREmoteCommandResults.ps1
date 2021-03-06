﻿function Get-VSSInfoFromRemoteCommandResults {
    <#
    .SYNOPSIS
        Converts the results of vssadmin list writer into powershell friendly objects.
    .DESCRIPTION
        Converts the results of vssadmin list writer into powershell friendly objects.
    .PARAMETER InputObject
        Object or array of objects returned from Get-RemoteCommandResults
    .EXAMPLE
        PS > $a = Get-VSSInfoFromRemoteCommandResults $cmdresults

        Description
        -----------
        Gather and store the results of the remotely run command output generated from New-RemoteCommand

    .NOTES
        Author: Zachary Loeber
        Site: http://www.the-little-things.net/
        Requires: Powershell 2.0

        Version History
        1.0.0 - 09/19/2013
        - Initial release
    
        ** This is a supplement function to New-RemoteCommand and Get-RemoteCommandResults **
    #>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage='Object or array of objects returned from Get-RemoteCommandResults')]
        $InputObject
    )
    begin {
        $VSSResults = @()
        $Results = @()
    }
    process {
        $Results += $InputObject
    }
    end {
        Foreach ($result in $Results)
        {
            $VSSWriters = @()
            $output = $result.CommandResults
            for ($i=0; $i -lt $output.Count; $i++)
            {        if ($output[$i] -match 'Writer name')
                {
                    $vssprops = @{
                        'WriterName' = [regex]::match($output[$i],'(?<=:)(.+)').value
                        'WriterID' = [regex]::match($output[$i+1],'(?<=:)(.+)').value
                        'WriterInstanceID' = [regex]::match($output[$i+2],'(?<=:)(.+)').value
                        'State' = [regex]::match($output[$i+3],'(?<=:)(.+)').value
                        'LastError' = [regex]::match($output[$i+4],'(?<=:)(.+)').value
                    }
                    $VSSWriters += New-Object PSObject -Property $vssprops
                    $i = ($i + 4)
                }
            }
            $VSSResultProps = @{
                'PSComputerName' = $result.PSComputerName
                'PSDateTime' = $result.PSDateTime
                'ComputerName' = $result.ComputerName
                'VSSWriters' = $VSSWriters
            }
            $VSSResults += New-Object PSObject -Property $VSSResultProps
        }
        $VSSResults
    }
}
