<#
.SYNOPSIS
    Merge the latest Moonlight V+ upstream into the Material 3 redesign branch.

.DESCRIPTION
    This keeps the M3 work as a thin, reviewable layer on top of upstream instead
    of a permanent fork. The script:
      1. refuses to run on a dirty work tree;
      2. fetches qiin2333/moonlight-vplus master;
      3. creates/updates a dedicated sync branch from the M3 base branch;
      4. merges upstream and runs the token consistency check;
      5. optionally pushes the sync branch for a pull request.

    On a conflict the merge is left in place so a human can resolve it. The
    common conflict hotspots are listed in docs/M3_DESIGN_SYSTEM.md.

.PARAMETER BaseBranch
    Branch that contains the Material 3 work. Default: m3-redesign.

.PARAMETER UpstreamBranch
    Upstream branch to merge. Default: master.

.PARAMETER SyncBranch
    Local branch used for the merge. Default: automation/upstream-sync.

.PARAMETER Push
    Push SyncBranch to the origin remote after a clean merge.

.PARAMETER AllowDirty
    Skip the clean-work-tree guard (not recommended).
#>
[CmdletBinding()]
param(
    [string]$BaseBranch = "m3-redesign",
    [string]$UpstreamBranch = "master",
    [string]$UpstreamUrl = "https://github.com/qiin2333/moonlight-vplus.git",
    [string]$SyncBranch = "automation/upstream-sync",
    [switch]$Push,
    [switch]$AllowDirty
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    function Invoke-Git {
        param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
        & git @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
        }
    }

    if (-not (Test-Path ".git")) {
        throw "Run this script from a checkout of the Moonlight V+ repository."
    }

    if (-not $AllowDirty) {
        $dirty = & git status --porcelain
        if ($LASTEXITCODE -ne 0) { throw "Unable to read git status." }
        if ($dirty) {
            throw "Working tree is dirty. Commit or stash your changes first, or pass -AllowDirty."
        }
    }

    $remotes = & git remote
    if ($remotes -notcontains "upstream") {
        Write-Host "Adding upstream remote: $UpstreamUrl"
        Invoke-Git remote add upstream $UpstreamUrl
    } else {
        Invoke-Git remote set-url upstream $UpstreamUrl
    }

    Write-Host "Fetching upstream/$UpstreamBranch..."
    Invoke-Git fetch --prune upstream $UpstreamBranch

    $baseExists = & git show-ref --verify --quiet "refs/heads/$BaseBranch"
    if ($LASTEXITCODE -ne 0) {
        throw "Base branch '$BaseBranch' does not exist. Create it from the M3 work first."
    }

    Write-Host "Preparing $SyncBranch from $BaseBranch..."
    & git switch -C $SyncBranch $BaseBranch
    if ($LASTEXITCODE -ne 0) { throw "Unable to create $SyncBranch." }

    $upstreamRef = "upstream/$UpstreamBranch"
    $behind = & git rev-list --count "HEAD..$upstreamRef"
    if ($LASTEXITCODE -ne 0) { throw "Unable to compare with $upstreamRef." }
    if ([int]$behind -eq 0) {
        Write-Host "Already up to date with $upstreamRef. Nothing to do."
        exit 0
    }

    Write-Host "Merging $upstreamRef ($behind commit(s))..."
    & git merge --no-edit $upstreamRef
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Merge conflict. Resolve the conflicts, then run:"
        Write-Host "  git add <files>; git commit; ./scripts/check-m3-tokens.ps1; git push -u origin $SyncBranch"
        Write-Host "Conflict hotspots are documented in docs/M3_DESIGN_SYSTEM.md."
        exit 2
    }

    $checker = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell.exe" }
    & $checker -NoProfile -File (Join-Path $PSScriptRoot "check-m3-tokens.ps1")
    if ($LASTEXITCODE -ne 0) {
        throw "Material 3 token check failed after the upstream merge."
    }

    Write-Host ""
    Write-Host "Merge complete. Changed files:"
    & git diff --stat "$BaseBranch..HEAD"

    if ($Push) {
        Write-Host "Pushing $SyncBranch to origin..."
        Invoke-Git push --force-with-lease -u origin $SyncBranch
    } else {
        Write-Host "Next: review the diff, run CI/build, then push $SyncBranch and open a PR into $BaseBranch."
    }
}
finally {
    Pop-Location
}
