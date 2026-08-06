# Windows + WSL2 로컬 검증팩 실행

저장소 루트의 PowerShell에서 실행한다.

```powershell
Set-Location C:\Users\user\Documents\GitHub\Ninza\Ten-Paces-Hidden-Moves
$head = git rev-parse HEAD
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\run_windows_wsl2_validation.ps1 -ExpectedHead $head
```

Ubuntu 배포판 이름이 여러 개면 명시한다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\run_windows_wsl2_validation.ps1 -ExpectedHead $head -WslDistribution Ubuntu-24.04
```

검증팩은 다음을 자동 확인한다.

- Windows `py -3.11`, `py -3.12`, `py -3.13`
- WSL2 Ubuntu와 `python3.12`
- exact HEAD 및 실행 전후 clean tree
- `full-validation.yml`의 `matrix-contracts` 명령과 manifest 일치
- 네 환경의 전체 명령 PASS

결과 파일:

- `build/local-validation/results/*.json`
- `build/local-validation/logs/**`
- `build/local-validation/summary.json`

`summary.json`의 `status`가 `PASS`이고 `passed_environments`가 4일 때만 로컬 Python 매트릭스 통과로 사용한다.
