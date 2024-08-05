<#
echo $profile
gvim $profile
* FileName: Microsoft.PowerShell_profile.ps1
#>

#------------------------------- Import Modules BEGIN -------------------------------
# 引入 ps-read-line
Import-Module PSReadLine -Scope Global

# 引入 fzf ，避免重复导入，每次加载时间太久了 超过一秒
if (-not (Get-Module PSFzf)) {
	Import-Module PSFzf -Scope Global
}
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

# 以列表的形式展现提示
Set-PSReadLineOption -PredictionViewStyle ListView

# 删除光标前所有字符
Set-PSReadLineKeyHandler -Key "Ctrl+u" -Function BackwardDeleteLine

# 删除当前后所有字符
Set-PSReadLineKeyHandler -Key "Ctrl+k" -Function DeleteToEnd

# 设置 Ctrl-a/e 到行首或者行尾 Linux 习惯操作  使用 Get-PSReadLineKeyHandler 查看所有的按键映射
Set-PSReadLineKeyHandler -Key "Ctrl+a" -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key "Ctrl+e" -Function EndOfLine

# 设置 Ctrl+r 加载 fzf 历史记录
if(Get-Module -ListAvailable -Name "PSFzf" -ErrorAction Stop) {
	Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
# 设置 PSFzf 展示的历史记录数量为 10 条，默认展示全部历史记录，会冲刷掉终端已有的消息
		$env:FZF_DEFAULT_OPTS="--height 10"
}

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

#=================== 自定义函数 =========
# 创建文件
function touch($file) { "" | Out-File $file -Encoding ASCII }
# 查找文件
function ff($name) {
	Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
		Write-Output "$($_.FullName)"
	}
}

# 获取公网 IP 
function Get-PubIP { (Invoke-WebRequest http://ifconfig.me/ip).Content }

# 获取连接过的wifi的密码
function Get-WIFIPasswords(){
    $pfs = netsh wlan show profiles | Select-String "所有用户配置文件"

    foreach ($pf in $pfs) {
        # 从配置文件中提取 WiFi 网络名称
        $wifiName = $pf -replace "    所有用户配置文件 : ", ""

        # 获取该 WiFi 网络的详细信息，包括密码
        $result = netsh wlan show profile name="$wifiName" key=clear

        # 从详细信息中提取密码
        $password = $result | Select-String "关键内容"
        if ($password) {
            $password = $password -replace "    关键内容            : ", ""
            Write-Output "WiFi网络: $wifiName, 密码: $password"
        }
    }
}

function reload-profile {
#	使用 & 或者 . 加载 profile 的时候不会立即生效，当前会话并不会看到效果
#	& $PROFILE
	. (Resolve-Path $PROFILE)
}

function unzip ($file) {
	Write-Output("Extracting", $file, "to", $pwd)
		$fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
	Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir) {
	if ( $dir ) {
		Get-ChildItem $dir | select-string $regex
			return
	}
	$input | select-string $regex
}

function df {
	get-volume
}

function sed($file, $find, $replace) {
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}

# function which($name) {
#     Get-Command $name | Select-Object -ExpandProperty Definition
# }
# 获取边境变量信息，按照分号分割换行显示，默认都是一长串字符，不方便查看
function Get-Path{
	$env:PATH -split ';'
}

# 在当前会话设置环境变量
function export($name, $value) {
# 也可以直接使用这种方式，不过没有 set-item 灵活
# $env:MY_VARIABLE 
	set-item -force -path "env:$name" -value $value;
}

function unset($name){
	Remove-Item "env:$name"
}

# 设置全局的环境变量 默认为当前用户设置
function Set-Path($name,$value){
	$EnvName = "$name";
	$EnvValue = "$value";
	[System.Environment]::SetEnvironmentVariable($EnvName, $EnvValue, [System.EnvironmentVariableTarget]::User);
}

function Unset-Path($name){
	$EnvName = "$name";
	[System.Environment]::SetEnvironmentVariable($EnvName, $null, [System.EnvironmentVariableTarget]::User);
}

function uptime {
	Get-Uptime -Since
	Get-Uptime
}

function pkill($name) {
	Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name) {
	Get-Process $name
}

function pgrepm($name){
	Get-Process | Where-Object -Property ProcessName  -Match $name
}

function head {
	param($Path, $n = 10)
		Get-Content $Path -Head $n
}

function tail {
	param($Path, $n = 10, [switch]$f = $false)
		Get-Content $Path -Tail $n -Wait:$f
}

# Quick File Creation
function nf { param($name) New-Item -ItemType "file" -Path . -Name $name }

# Directory Management
function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }

### Quality of Life Aliases

# Navigation Shortcuts
function docs { Set-Location -Path $HOME\Documents }

function dtop { Set-Location -Path $HOME\Desktop }

# Quick Access to Editing the Profile
function ep { vim $PROFILE }

# Simplified Process Management
function k9 { Stop-Process -Name $args[0] }

# Enhanced Listing
function la { Get-ChildItem -Path . -Force | Format-Table -AutoSize }
function ll { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize }

# Git Shortcuts
function gits { git status }

function gita { git add . }

function gitc { param($m) git commit -m "$m" }

function gitp { git push }

function g { __zoxide_z github }

function gitcl { git clone "$args" }

function gitcom {
	git add .
		git commit -m "$args"
}
function lazyg {
	git add .
		git commit -m "$args"
		git push
}

# Quick Access to System Information
function sysinfo { Get-ComputerInfo }

# Networking Utilities
function flushdns {
	Clear-DnsClientCache
		Write-Host "DNS has been flushed"
}

# Clipboard Utilities
function cpy { Set-Clipboard $args[0] }

function pst { Get-Clipboard }

# Enhanced PowerShell Experience
Set-PSReadLineOption -Colors @{
	Command = 'Yellow'
		Parameter = 'Green'
		String = 'DarkCyan'
}

$PSROptions = @{
	ContinuationPrompt = '  '
		Colors             = @{
			Parameter          = $PSStyle.Foreground.Magenta
				Selection          = $PSStyle.Background.Black
				InLinePrediction   = $PSStyle.Foreground.BrightYellow + $PSStyle.Background.BrightBlack
		}
}
Set-PSReadLineOption @PSROptions
# Help Function
function Show-Help {
	@"
		PowerShell Profile Help
		=======================

		Edit-Profile - Opens the current user's profile for editing using the configured editor.

		touch <file> - Creates a new empty file.

		ff <name> - Finds files recursively with the specified name.

		Get-PubIP - Retrieves the public IP address of the machine.

		Get-WIFIPasswords - Get account passwords for all WiFi connections.

		winutil - Runs the WinUtil script from Chris Titus Tech.

		uptime - Displays the system uptime : get-uptime -Since.

		reload-profile - Reloads the current user's PowerShell profile.

		unzip <file> - Extracts a zip file to the current directory.

		hb <file> - Uploads the specified file's content to a hastebin-like service and returns the URL.

		grep <regex> [dir] - Searches for a regex pattern in files within the specified directory or from the pipeline input.

		df - Displays information about volumes.

		sed <file> <find> <replace> - Replaces text in a file.

		which <name> - Shows the path of the command.

		Get-Path - Show global environment variables.

		export <name> <value> - Sets an environment variable for the current session.

		unset <name> - Unset an environment variable for the current session.

		Set-Path <name> <value> - set an global environment variable for the current user.

		Unset-Path <name> - unset an global environment variable for the current user.

		pkill <name> - Kills processes by name.

		pgrep <name> - Lists processes by name.

		pgrepm <name> - Lists processes by match name.

		head <path> [n] - Displays the first n lines of a file (default 10).

		tail <path> [n] - Displays the last n lines of a file (default 10).

		nf <name> - Creates a new file with the specified name.

		mkcd <dir> - Creates and changes to a new directory.

		docs - Changes the current directory to the user's Documents folder.

		dtop - Changes the current directory to the user's Desktop folder.

		ep - Opens the profile for editing.

		k9 <name> - Kills a process by name.

		la - Lists all files in the current directory with detailed formatting.

		ll - Lists all files, including hidden, in the current directory with detailed formatting.

		gits - Shortcut for 'git status'.

		gita - Shortcut for 'git add .'.

		gitc <message> - Shortcut for 'git commit -m'.

		gitp - Shortcut for 'git push'.

		g - Changes to the GitHub directory.

		gitcom <message> - Adds all changes and commits with the specified message.

		lazyg <message> - Adds all changes, commits with the specified message, and pushes to the remote repository.

		sysinfo - Displays detailed system information.

		flushdns - Clears the DNS cache.

		cpy <text> - Copies the specified text to the clipboard.

		pst - Retrieves text from the clipboard.

		Use 'Show-Help' to display this help message.
"@
}
Write-Host "Use 'Show-Help' to display help"
