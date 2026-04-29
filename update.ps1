function Get-NextHostname($prefix){

    $root = [ADSI]"LDAP://RootDSE"
    $base = "LDAP://" + $root.defaultNamingContext

    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.SearchRoot = [ADSI]$base
    $searcher.Filter = "(&(objectCategory=computer)(name=$prefix*))"
    $searcher.PageSize = 1000

    $results = $searcher.FindAll()

    $nums=@()

    foreach($item in $results){
        $name = $item.Properties["name"][0]

        if($name -match "$prefix(\d+)$"){
            $nums += [int]$matches[1]
        }
    }

    $last = ($nums | Measure-Object -Maximum).Maximum
    $next = $last + 1

    return @{
        ultimo = $prefix + $last.ToString("00")
        siguiente = $prefix + $next.ToString("00")
    }
}

$ros = Get-NextHostname "NTBA3MROS"
$bue = Get-NextHostname "NTBA3MBUE"

$data = @{
    rosario = $ros
    buenos_aires = $bue
    updated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
}

$data | ConvertTo-Json -Depth 4 | Set-Content .\status.json

Write-Host "status.json actualizado correctamente"