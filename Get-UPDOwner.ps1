param (
    [String]$UpdShare = "\\rds-cb1\UPD_Collection1"
)

function Get-UPDOwner {
    param (
        [String]$DiskName
    )

    $sid = (($DiskName).Substring(5)) -replace "\.VHDX*$",""
    $sidObj = New-Object System.Security.Principal.SecurityIdentifier ($sid)
    $userObj = $sidObj.Translate([System.Security.Principal.NTAccount])
    $userName = $userObj.Value
    return $userName
}

function Get-UPDDisk {
    param (
        [String]$UserName,
        [String]$CollectionName
    )

    $updSharePath = (Get-RDSessionCollectionConfiguration -CollectionName $CollectionName `
        -UserProfileDisk).DiskPath
    
    $userObj = Get-ADUser -Identity $UserName
    $diskName = "UVHD-" + $userObj.SID + ".vhdx"
    foreach ($upDisk in (Get-ChildItem $updSharePath)) {
        if ($upDisk.Name -eq $diskName) {
            return "Disk $diskName belongs to $UserName"
        }
    }
    return "User $UserName does not own a disk in $updSharePath"
}

$updArr = Get-ChildItem $UpdShare -Filter "UVHD-S*.vhd"

foreach ($userProfileDisk in $updArr) {
    Get-UPDOwner -DiskName $userProfileDisk.Name
}