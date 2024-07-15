<#
 echo $profile
 gvim $profile
 * FileName: Microsoft.PowerShell_profile.ps1
#>

#------------------------------- Import Modules BEGIN -------------------------------
# 引入 ps-read-line
Import-Module PSReadLine

# 引入 posh-git
## Import-Module posh-git

# 引入 oh-my-posh
## Import-Module oh-my-posh

# 设置 PowerShell 主题
# Set-PoshPrompt ys
## Set-PoshPrompt emodipt-extend
#------------------------------- Import Modules END   -------------------------------

#-------------------------------  Set Hot-keys BEGIN  -------------------------------
# 设置预测文本来源为历史记录
Set-PSReadLineOption -PredictionSource History

# 每次回溯输入历史，光标定位于输入内容末尾
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# 设置 Tab 为菜单补全和 Intellisense
Set-PSReadLineKeyHandler -Key "Tab" -Function MenuComplete

# 设置 Ctrl+d 为退出 PowerShell
Set-PSReadlineKeyHandler -Key "Ctrl+d" -Function ViExit

# 设置 Ctrl+z 为撤销
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo

# 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward

# 设置向下键为前向搜索历史纪录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
#-------------------------------  Set Hot-keys END    -------------------------------

#==================== prompt ===========
function Prompt {
    $id = 1
    $UserName = $env:UserName
    $hostname = hostname
    $historyItem = Get-History -Count 1
    if ($historyItem) {
        $id = $historyItem.Id + 1
    }
    Write-Host -ForegroundColor DarkGray "`n[$(Get-Location)]"
    Write-Host -NoNewline
    "($UserName@$hostname):$id > "
    $Host.UI.RawUI.WindowTitle = "$(Get-Location)"
}
