# Place as ci/probe.ps1 in an isolated, owned source repository.
# Do not print or persist the authorization JSON or token.
$repoId = [Environment]::GetEnvironmentVariable('BUILD_REPOSITORY_ID')
$isFork = [Environment]::GetEnvironmentVariable('SYSTEM_PULLREQUEST_ISFORK')
$authPresent = $false
$nonemptyParameter = $false

if (-not [string]::IsNullOrWhiteSpace($repoId)) {
    $key = 'VSTSPSHOSTENDPOINT_AUTH_' + $repoId
    $raw = [Environment]::GetEnvironmentVariable($key)
    $authPresent = -not [string]::IsNullOrWhiteSpace($raw)
    if ($authPresent) {
        try {
            $auth = $raw | ConvertFrom-Json
            if ($null -ne $auth.Parameters) {
                foreach ($name in @('AccessToken', 'ApiToken', 'Password')) {
                    $item = $auth.Parameters.PSObject.Properties[$name]
                    if ($null -ne $item -and -not [string]::IsNullOrWhiteSpace([string]$item.Value)) {
                        $nonemptyParameter = $true
                        break
                    }
                }
            }
        } catch {
            $authPresent = $false
        }
    }
}

Write-Host ('PROBE_IS_FORK=' + $isFork)
Write-Host ('PROBE_SOURCE_AUTH_PRESENT=' + $authPresent)
Write-Host ('PROBE_NONEMPTY_AUTH_PARAMETER=' + $nonemptyParameter)
