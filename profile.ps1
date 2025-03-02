Invoke-Expression (& { $hook = if ($PSVersionTable.PSVersion.Major -ge 6) { 'pwd' } else { 'prompt' } (zoxide init powershell --hook $hook | Out-String) })
oh-my-posh init pwsh --config "$env:HOME/.cache/oh-my-posh/themes/dracula.omp.json" | Invoke-Expression
