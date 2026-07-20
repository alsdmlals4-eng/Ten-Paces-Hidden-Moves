param(
    [string]$GodotPath = "",
    [switch]$NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ExpectedBranch = "agent/t0-combat-poc-board"
$ReportRelativePath = "artifacts/verification/step0-godot-verification.md"
$CommitMessage = "test: verify STEP 0 card components in Godot"

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Host "`n== $Label ==" -ForegroundColor Cyan
    $output = & $FilePath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Host $_ }

    if ($exitCode -ne 0) {
        throw "$Label 실패 (exit=$exitCode)"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Resolve-GodotExecutable {
    param([string]$ExplicitPath)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (-not (Test-Path -LiteralPath $ExplicitPath -PathType Leaf)) {
            throw "지정한 Godot 실행 파일을 찾을 수 없습니다: $ExplicitPath"
        }
        return (Resolve-Path -LiteralPath $ExplicitPath).Path
    }

    if (-not [string]::IsNullOrWhiteSpace($env:GODOT_BIN) -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) {
        return (Resolve-Path -LiteralPath $env:GODOT_BIN).Path
    }

    foreach ($commandName in @("godot4", "godot", "Godot_v4.7.1-stable_win64_console", "Godot_v4.7.1-stable_win64")) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }

    $knownPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Links\godot.exe",
        "$env:USERPROFILE\scoop\shims\godot.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7.1-stable_win64_console.exe",
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4.7.1-stable_win64.exe",
        "C:\Godot\Godot_v4.7.1-stable_win64_console.exe",
        "C:\Godot\Godot_v4.7.1-stable_win64.exe"
    )

    foreach ($candidate in $knownPaths) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    $searchRoots = @(
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Documents"
    ) | Where-Object { Test-Path -LiteralPath $_ -PathType Container }

    foreach ($root in $searchRoots) {
        $candidate = Get-ChildItem -LiteralPath $root -Filter "Godot*.exe" -File -Recurse -ErrorAction SilentlyContinue |
            Sort-Object @{ Expression = { if ($_.Name -like "*console*") { 0 } else { 1 } } }, FullName |
            Select-Object -First 1
        if ($null -ne $candidate) {
            return $candidate.FullName
        }
    }

    throw "Godot 실행 파일을 찾지 못했습니다. -GodotPath 또는 GODOT_BIN 환경 변수를 사용하세요."
}

function Resolve-PythonCommand {
    $py = Get-Command "py" -ErrorAction SilentlyContinue
    if ($null -ne $py) {
        return @{ Exe = $py.Source; Prefix = @("-3") }
    }

    $python = Get-Command "python" -ErrorAction SilentlyContinue
    if ($null -ne $python) {
        return @{ Exe = $python.Source; Prefix = @() }
    }

    throw "Python 3 실행 파일을 찾지 못했습니다. py 또는 python을 PATH에 등록하세요."
}

try {
    $repoRootOutput = & git rev-parse --show-toplevel 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "현재 폴더가 Git 저장소가 아닙니다."
    }

    $repoRoot = ([string]$repoRootOutput).Trim()
    Set-Location -LiteralPath $repoRoot

    $branch = ((& git branch --show-current) | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $branch -ne $ExpectedBranch) {
        throw "현재 브랜치가 $ExpectedBranch 가 아닙니다. actual=$branch"
    }

    $initialStatus = @(& git status --porcelain --untracked-files=all)
    if ($LASTEXITCODE -ne 0) {
        throw "git status 실행에 실패했습니다."
    }
    if ($initialStatus.Count -gt 0) {
        throw "실행 전 작업 폴더가 깨끗하지 않습니다. 기존 변경을 커밋·보관한 뒤 다시 실행하세요.`n$($initialStatus -join "`n")"
    }

    Invoke-Checked -FilePath "git" -Arguments @("fetch", "origin") -Label "원격 갱신"
    Invoke-Checked -FilePath "git" -Arguments @("pull", "--ff-only", "origin", $ExpectedBranch) -Label "브랜치 fast-forward"

    $postPullStatus = @(& git status --porcelain --untracked-files=all)
    if ($postPullStatus.Count -gt 0) {
        throw "pull 이후 예상하지 못한 로컬 변경이 있습니다.`n$($postPullStatus -join "`n")"
    }

    $godotExe = Resolve-GodotExecutable -ExplicitPath $GodotPath
    $python = Resolve-PythonCommand

    $godotVersion = Invoke-Checked -FilePath $godotExe -Arguments @("--version") -Label "Godot 버전 확인"
    $staticArgs = @($python.Prefix) + @("tests/check_card_component_contract.py")
    $staticOutput = Invoke-Checked -FilePath $python.Exe -Arguments $staticArgs -Label "카드 정적 계약 검사"
    $parseOutput = Invoke-Checked -FilePath $godotExe -Arguments @("--headless", "--editor", "--path", $repoRoot, "--quit") -Label "Godot 프로젝트 import·파싱"
    $runtimeOutput = Invoke-Checked -FilePath $godotExe -Arguments @("--headless", "--path", $repoRoot, "--script", "res://tests/verify_step0.gd") -Label "STEP 0 headless 씬 검증"

    $unexpectedBeforeReport = @(& git status --porcelain --untracked-files=all)
    if ($unexpectedBeforeReport.Count -gt 0) {
        throw "검증 과정에서 예상하지 못한 추적 파일 변경이 생겼습니다. 자동 커밋을 중단합니다.`n$($unexpectedBeforeReport -join "`n")"
    }

    $reportPath = Join-Path $repoRoot $ReportRelativePath
    $reportDirectory = Split-Path -Parent $reportPath
    New-Item -ItemType Directory -Force -Path $reportDirectory | Out-Null

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $versionText = ($godotVersion -join "`n").Trim()
    $staticText = ($staticOutput -join "`n").Trim()
    $parseText = ($parseOutput -join "`n").Trim()
    $runtimeText = ($runtimeOutput -join "`n").Trim()

    $report = @"
# STEP 0 Godot 로컬 검증

- 상태: PASS
- 검증 시각(UTC): $timestamp
- 브랜치: $ExpectedBranch
- Godot 실행 파일: ``$godotExe``
- Godot 버전: ``$versionText``

## 수행 검사

- [x] 실행 전 작업 폴더 clean
- [x] 원격 브랜치 fast-forward
- [x] 카드 계약 정적 검사
- [x] Godot 프로젝트 import·GDScript 파싱
- [x] 카드 카탈로그 7종·필수/금지 필드 검사
- [x] 배지·원화 Atlas 경로 검사
- [x] 카드 미리보기 씬 인스턴스화
- [x] CardView 7개·CardDetailPanel 1개 생성

## 정적 검사 출력

``````text
$staticText
``````

## Godot import·파싱 출력

``````text
$parseText
``````

## Godot STEP 0 검증 출력

``````text
$runtimeText
``````

## 범위 제한

이 자동화는 headless 구조·데이터·씬 로드 검증이다. Windows 실제 클릭, 스크롤, 최소 해상도, 글꼴, 색각 접근성, 시각적 품질은 별도 수동 검수가 필요하다.
"@

    Set-Content -LiteralPath $reportPath -Value $report -Encoding UTF8

    $changedFiles = @()
    $changedFiles += @(& git diff --name-only)
    $changedFiles += @(& git ls-files --others --exclude-standard)
    $changedFiles = @($changedFiles | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $unexpectedFiles = @($changedFiles | Where-Object { $_ -ne $ReportRelativePath })
    if ($unexpectedFiles.Count -gt 0) {
        throw "검증 보고서 외 파일이 변경되어 자동 커밋을 중단합니다.`n$($unexpectedFiles -join "`n")"
    }

    Invoke-Checked -FilePath "git" -Arguments @("add", "--", $ReportRelativePath) -Label "검증 보고서 stage"
    & git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "검증 보고서 내용 변화가 없어 새 커밋을 만들지 않습니다." -ForegroundColor Yellow
    } else {
        Invoke-Checked -FilePath "git" -Arguments @("commit", "-m", $CommitMessage) -Label "검증 결과 커밋"
    }

    $commitSha = ((& git rev-parse HEAD) | Out-String).Trim()
    if (-not $NoPush) {
        Invoke-Checked -FilePath "git" -Arguments @("push", "origin", $ExpectedBranch) -Label "검증 결과 push"
    }

    Write-Host "`nSTEP 0 자동 검증 완료" -ForegroundColor Green
    Write-Host "Commit: $commitSha"
    if ($NoPush) {
        Write-Host "Push: 건너뜀 (-NoPush)"
    } else {
        Write-Host "Push: origin/$ExpectedBranch 완료"
    }
}
catch {
    Write-Host "`nSTEP 0 자동 검증 실패" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "실패 시 자동 commit·push는 수행하지 않습니다." -ForegroundColor Yellow
    exit 1
}
