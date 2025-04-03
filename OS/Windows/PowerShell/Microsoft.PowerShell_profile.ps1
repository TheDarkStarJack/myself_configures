<#
echo $profile
gvim $profile
* FileName: Microsoft.PowerShell_profile.ps1
#>

#------------------------------- Import Modules BEGIN -------------------------------
# 引入 ps-read-line
Import-Module PSReadLine -Scope Global

# 引入 fzf ，避免重复导入，每次加载时间太久了 超过一秒
if (-not (Get-Module PSFzf))
{
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
if(Get-Module -ListAvailable -Name "PSFzf" -ErrorAction Stop)
{
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
  # 设置 PSFzf 展示的历史记录数量为 10 条，默认展示全部历史记录，会冲刷掉终端已有的消息
		$env:FZF_DEFAULT_OPTS="--height 10"
}

#-------------------------------  Set Hot-keys END    -------------------------------
#==================== prompt ===========
# Admin Check and Prompt Customization

# function Get-OS{
#   $os = Get-CimInstance -ClassName Win32_OperatingSystem
#   $os.Caption
# }

# $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($IsWindows)
{
  $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    #opt-out of telemetry before doing anything, only if PowerShell is run as admin
    if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem)
    {
      [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
    }
  $UserName = $env:UserName;
} elseif ($isLinux)
{
  $isAdmin = (id -u) -eq 0
  $UserName = $env:USER;
} else
{
  $isAdmin = $false
    echo "Not Windows or Linux"
}

$adminSuffix = if ($isAdmin)
{ " [ADMIN]" 
} else
{ "" 
}

# $Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

function Prompt
{
  $id = 1;
  $hostname = hostname;
  $historyItem = Get-History -Count 1;
  if ($historyItem)
  {
    $id = $historyItem.Id + 1
  }
  if ($isAdmin)
  {
    $identifier = "#"
    $adminMask = "Admin"
  } else
  {
    $identifier = "$"
  }
  Write-Host -ForegroundColor DarkGray "`n[$(Get-Location)] $adminMask"
		Write-Host -NoNewline
		"($UserName@$hostname):$id $identifier "
		$Host.UI.RawUI.WindowTitle = "$(Get-Location)"
}

#=================== 自定义函数 =========
# 部分函数参考：https://github.com/ChrisTitusTech/powershell-profile/blob/main/Microsoft.PowerShell_profile.ps1

# Initial GitHub.com connectivity check with 1 second timeout
$canConnectToGitHub = Test-Connection github.com -Count 1 -Quiet -TimeoutSeconds 1

# Import Modules and External Profiles
# Ensure Terminal-Icons module is installed before importing
if (-not (Get-Module -ListAvailable -Name Terminal-Icons))
{
  Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}

# Check for Profile Updates
function Update-Profile
{
  if (-not $global:canConnectToGitHub)
  {
    Write-Host "Skipping profile update check due to GitHub.com not responding within 1 second." -ForegroundColor Yellow
    return
  }

  try
  {
    $url = "https://raw.githubusercontent.com/TheDarkStarJack/myself_configures/main/OS/Windows/PowerShell/Microsoft.PowerShell_profile.ps1"
    $oldhash = Get-FileHash $PROFILE
    Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
    $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
    if ($newhash.Hash -ne $oldhash.Hash)
    {
      Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
      Write-Host "Profile has been updated. Please restart your shell to reflect changes" -ForegroundColor Magenta
    }
  } catch
  {
    Write-Error "Unable to check for `$profile updates"
  } finally
  {
    Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
  }
}

function  Get-TerminialImages
{
  $url = "https://darkstaronline.work/WindowsTerminal/wallhaven-oxq8gl.jpg"

  Invoke-WebRequest -Uri $url -OutFile "$env:HOMEPATH/.config/Terminal-image.jpg"
  
}

# 生成新的 hosts 文件 https://answers.microsoft.com/zh-hans/windows/forum/all/hosts%E6%96%87%E4%BB%B6%E4%B8%A2%E5%A4%B1%E6%88%96/a4353b28-8d8a-468e-a7a5-db132ceb36d5
function Set-Hosts-Tip()
{
  #$filepath = $env:windir + "\WinSxS\hosts"
  #$files = Get-ChildItem -Path $filepath -Recurse
  ## 遍历每个文件并执行相应操作
  #foreach ($file in $files)
  #{
  #  $destination = Join-Path $filepath $file.Name
  #  Copy-Item -Path $file.FullName -Destination $destination -Force
  #  Write-Output $file.FullName
  #  Start-Process notepad.exe -ArgumentList $file.FullName
  #}
  Write-Output {当前用户不是管理员，请使用管理员用户执行}
  Write-Output {请执行以下命令，如果没有 sudo 命令 ，需要使用管理管运行 cmd 执行}
  Write-Output {sudo cmd "for /f %P in ('dir %windir%\WinSxS\hosts /b /s') do copy %P %windir%\System33\drivers\etc & echo %P & Notepad %P"}
  Write-Output {添加 GitHub DNS ，https://gitee.com/TheDarkStar/github-hosts }
}

## 手动配置 GitHub dns 文件，避免有的时候无法使用 VPN ，从 gitee 同步
function Set-Hosts()
{
  if(-not $isAdmin)
  {
    Set-Hosts-Tip
  } else
  {
    # 获取 WinSxS 目录和 System32 目录的完整路径
    $winSxSDir = Join-Path -Path $env:windir -ChildPath 'WinSxS';
    $system32Dir = Join-Path -Path $env:windir -ChildPath 'System32\drivers\etc';

    # 遍历 WinSxS 目录下所有名为 hosts 的文件
    Get-ChildItem -Path $winSxSDir -Filter hosts -Recurse -File | ForEach-Object {
      # 定义源文件和目标文件的路径
      $sourceFile = $_.FullName
      $destinationFile = Join-Path -Path $system32Dir -ChildPath $_.Name

      # 复制文件
      Copy-Item -Path $sourceFile -Destination $destinationFile

      # 打印文件路径
      Write-Host "Copied: $($sourceFile)"

      # 使用 Notepad 打开文件
      #Start-Process -FilePath notepad.exe -ArgumentList $destinationFile
      notepad $destinationFile
    }
  }
}

# 创建文件
function touch($file)
{ "" | Out-File $file -Encoding utf8 
}
# 查找文件
function ff($name)
{
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Output "$($_.FullName)"
  }
}

# 获取公网 IP 
function Get-PubIP
{ (Invoke-WebRequest http://ifconfig.me/ip).Content 
}

# 获取连接过的wifi的密码
function Get-WIFIPasswords()
{
  $pfs = netsh wlan show profiles | Select-String "所有用户配置文件"

  foreach ($pf in $pfs)
  {
    # 从配置文件中提取 WiFi 网络名称
    $wifiName = $pf -replace "    所有用户配置文件 : ", ""

    # 获取该 WiFi 网络的详细信息，包括密码
    $result = netsh wlan show profile name="$wifiName" key=clear

    # 从详细信息中提取密码
    $password = $result | Select-String "关键内容"
    if ($password)
    {
      $password = $password -replace "    关键内容            : ", ""
      Write-Output "WiFi网络: $wifiName, 密码: $password"
    }
  }
}

function reload-profile
{
  #	使用 & 或者 . 加载 profile 的时候不会立即生效，当前会话并不会看到效果
  #	& $PROFILE
  . (Resolve-Path $PROFILE)
}

function unzip ($file)
{
  Write-Output("Extracting", $file, "to", $pwd)
		$fullFile = Get-ChildItem -Path $pwd -Filter $file | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir)
{
  if ( $dir )
  {
    Get-ChildItem $dir | select-string $regex
    return
  }
  $input | select-string $regex
}

function df
{
  get-volume

  #Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, VolumeName, @{Name="Size(GB)"; Expression={"{0:N2}" -f ($_.Size / 1GB)}}, @{Name="FreeSpace(GB)"; Expression={"{0:N2}" -f ($_.FreeSpace / 1GB)}}, @{Name="UsedSpace(GB)"; Expression={"{0:N2}" -f (($_.Size - $_.FreeSpace) / 1GB)}}
}

function sed($file, $find, $replace)
{
	(Get-Content $file).replace("$find", $replace) | Set-Content $file
}

# function which($name) {
#     Get-Command $name | Select-Object -ExpandProperty Definition
# }
# 获取环境变量信息，按照分号分割换行显示，默认都是一长串字符，不方便查看
function Get-Path
{
  $env:PATH -split ';' | sort
}

# 在当前会话设置环境变量
function export($name, $value)
{
  # 也可以直接使用这种方式，不过没有 set-item 灵活
  # $env:MY_VARIABLE 
  set-item -force -path "env:$name" -value $value;
}

function unset($name)
{
  Remove-Item "env:$name"
}

# 设置全局的环境变量 默认为当前用户设置
function Set-Path($name,$value)
{
  $EnvName = "$name";
  $EnvValue = "$value";
  [System.Environment]::SetEnvironmentVariable($EnvName, $EnvValue, [System.EnvironmentVariableTarget]::User);
}

function Unset-Path($name)
{
  $EnvName = "$name";
  [System.Environment]::SetEnvironmentVariable($EnvName, $null, [System.EnvironmentVariableTarget]::User);
}

function uptime
{
  Get-Uptime -Since
  Get-Uptime
}

function top()
{
  While ($true)
  {
    # Get-Process | Sort-Object -desc cpu | Select-Object -Property NPM,PM,WS/1024,CPU,Id,SI,ProcessName,StartTime -First 3 | Format-Table
    Get-Process | Sort-Object -desc cpu | Select-Object -first 30; Sleep -seconds 2; Cls;
    Write-Host " NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName";
    Write-Host " ------    -----      -----     ------      --  -- -----------"
  }
}

function pkill($name)
{
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name)
{
  Get-Process $name
}

function pgrepm($name)
{
  Get-Process | Where-Object -Property ProcessName  -Match $name
}

function head
{
  param($Path, $n = 10)
		Get-Content $Path -Head $n
}

function stat($name)
{
  Get-ChildItem $name | Select-Object -Property Mode,creationtime,LastWriteTime,LastAccessTime,Length,name,Directory,FullName,Root,LinkTarget
}

function tail
{
  param($Path, $n = 10, [switch]$f = $false)
		Get-Content $Path -Tail $n -Wait:$f
}

# Quick File Creation
function nf
{ param($name) New-Item -ItemType "file" -Path . -Name $name 
}

# Directory Management
function mkcd
{ param($dir) mkdir $dir -Force; Set-Location $dir 
}

# 创建符号链接
function mklink ($name, $target)
{
  New-Item -ItemType SymbolicLink -Path $name -Target $target
}

### Quality of Life Aliases

# Navigation Shortcuts
function docs
{ Set-Location -Path $HOME\Documents 
}

function dtop
{ Set-Location -Path $HOME\Desktop 
}

# Quick Access to Editing the Profile
function ep
{ vim $PROFILE 
}

# Simplified Process Management
function k9
{ Stop-Process -Name $args[0] 
}

# Enhanced Listing
if($isWindows)
{
  function la
  { Get-ChildItem -Path . -Force | Format-Table -AutoSize 
  }
  function ll
  { Get-ChildItem -Path . -Force -Hidden | Format-Table -AutoSize 
  }
}

# Git Shortcuts
function gits
{ git status 
}

function gita
{ git add . 
}

function gitc
{ param($m) git commit -m "$m" 
}

function gitp
{ git push 
}

function g
{ __zoxide_z github 
}

function gitcl
{ git clone "$args" 
}

function gitcom
{
  git add .
		git commit -m "$args"
}
function lazyg
{
  git add .
		git commit -m "$args"
		git push
}

# Quick Access to System Information
function sysinfo
{ Get-ComputerInfo 
}

# Networking Utilities
function flushdns
{
  Clear-DnsClientCache
		Write-Host "DNS has been flushed"
}

# Clipboard Utilities
function cpy
{ Set-Clipboard $args[0] 
}

function pst
{ Get-Clipboard 
}

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

# ollama model download and speed up
# 因为 ollama 下载模型速度速度会越来越慢慢，所以可以使用该函数利用ollama的自动续传功能进行下载
function Get-OllamaModels {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModelName,
        [int]$RetryInterval = 60,
        [int]$MaxAttempts = 10
    )

    $attempt = 0
    $modelFound = $false

    while ($attempt -lt $MaxAttempts -and -not $modelFound) {
        # 检查模型是否存在（精确匹配）
        $existingModels = ollama list | ForEach-Object { ($_ -split '\s+')[0] }
        if ($ModelName -in $existingModels) {
            Write-Host "模型 '$ModelName' 已存在，无需下载。" -ForegroundColor Green
            $modelFound = $true
            break
        }

        # 启动下载进程
        Write-Host "正在下载模型 '$ModelName' (尝试次数: $($attempt + 1)/$MaxAttempts)..." -ForegroundColor Cyan
        $process = Start-Process -FilePath "ollama" -ArgumentList "run", $ModelName -PassThru -NoNewWindow

        # 等待一段时间后终止进程
        Start-Sleep -Seconds $RetryInterval
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            Write-Host "已终止下载进程，准备重新启动..." -ForegroundColor Yellow
        } catch {
            Write-Host "终止进程失败，可能已自然退出。" -ForegroundColor Red
        }
        #$downloadSpeed = Get-DownloadSpeedSomehow  # 根据速度实现下载速度监控自动重新下载
        #if ($downloadSpeed -lt 100KBps) {
        #    Stop-Process -Id $process.Id -Force
        #}
        # 检查模型是否已成功下载
        $existingModels = ollama list | ForEach-Object { ($_ -split '\s+')[0] }
        if ($ModelName -in $existingModels) {
            Write-Host "模型 '$ModelName' 已成功加载！" -ForegroundColor Green
            $modelFound = $true
            break
        }

        $attempt++
    }

    if (-not $modelFound) {
        Write-Host "无法在 $MaxAttempts 次尝试内加载模型 '$ModelName'，请检查网络或模型名称。" -ForegroundColor Red
        #exit 1
    }
}

## 获取指定目录下的视频文件的播放时长信息
function Get-VideoDuration {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [switch]$l,        # 显示所有视频的时长信息
        [switch]$s,        # 按降序排序
        [int]$n = 10       # 默认显示前10条，支持 -n 3 格式
    )

    # 检查 ffprobe 是否可用
    if (-not (Get-Command ffprobe -ErrorAction SilentlyContinue)) {
        Write-Host "错误：未找到 ffprobe，请先安装 FFmpeg 并添加至环境变量" -ForegroundColor Red
        return 0
    }

    # 统一视频扩展名处理（不区分大小写）
    $videoExtensions = @(".mp4", ".avi", ".mkv", ".mov", ".flv", ".wmv")
    $videoFiles = Get-ChildItem -Path $Path -Recurse -File | 
        Where-Object { $videoExtensions -contains $_.Extension.ToLower() }

    # 定义时长转换函数
    function Format-Duration {
        param([double]$Seconds)
        $ts = [TimeSpan]::FromSeconds($Seconds)
        return "{0}小时 {1:D2}分钟 {2:D2}秒" -f $ts.Hours, $ts.Minutes, $ts.Seconds
    }

    # 获取所有视频时长
    $videoDurations = @()
    foreach ($file in $videoFiles) {
        try {
            $jsonOutput = ffprobe -v error -show_entries format=duration -of json "$($file.FullName)"
            $duration = ($jsonOutput | ConvertFrom-Json).format.duration
            if ($duration) {
                $videoDurations += [PSCustomObject]@{
                    Name     = $file.Name
                    Path     = $file.FullName
                    Duration = [math]::Round([decimal]$duration, 2)
                }
            }
        } catch {
            Write-Host "无法解析文件: $($file.Name)" -ForegroundColor Yellow
        }
    }

    # 处理排序逻辑
    $sorted = if ($s) { 
        $videoDurations | Sort-Object Duration -Descending 
    } else { 
        $videoDurations | Sort-Object Duration 
    }

    # 处理显示逻辑
    if ($l) {
        $sorted | ForEach-Object {
            $formatted = Format-Duration $_.Duration
            Write-Host "$($_.Name)".PadRight(50) -NoNewline
            Write-Host $formatted -ForegroundColor Cyan
        }
    }

    # 计算总时长
    $total = ($videoDurations | Measure-Object -Property Duration -Sum).Sum
    $totalFormatted = Format-Duration $total

    # 显示统计信息
    if ($n -gt 0) {
        Write-Host "`n总播放时长: $totalFormatted" -ForegroundColor Green
        Write-Host "`n时长最长的前$n 个视频:`n" -ForegroundColor Yellow
        $sorted | Select-Object -First $n | ForEach-Object {
            $formatted = Format-Duration $_.Duration
            [PSCustomObject]@{
                文件名 = $_.Name
                路径   = $_.Path
                时长   = $formatted
            }
        } | Format-Table -AutoSize -Wrap
    }
}

# Help Function
function Show-Help
{
  @"
		PowerShell Profile Help
		=======================
		Update-Profile - Update profile file from GitHub.

		touch <file> - Creates a new empty file.

		ff <name> - Finds files recursively with the specified name.

		Get-PubIP - Retrieves the public IP address of the machine.

		Get-WIFIPasswords - Get account passwords for all WiFi connections.

		winutil - Runs the WinUtil script from Chris Titus Tech.

		uptime - Displays the system uptime : get-uptime -Since.

		top -  the top thirty process information is displayed based on CPU usage.

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

    Get-TerminialImages - get WindowsTerminal backgroundImage

		Unset-Path <name> - unset an global environment variable for the current user.

		pkill <name> - Kills processes by name.

		pgrep <name> - Lists processes by name.

		pgrepm <name> - Lists processes by match name.

		head <path> [n] - Displays the first n lines of a file (default 10).

		stat <name> - get object Attributes,Similar to stat in Linux.

		tail <path> [n] - Displays the last n lines of a file (default 10).

		nf <name> - Creates a new file with the specified name.

		mkcd <dir> - Creates and changes to a new directory.

		mklink <from> <target> - Create symbolic link.

		docs - Changes the current directory to the user's Documents folder.

		dtop - Changes the current directory to the user's Desktop folder.

		ep - Opens the profile for editing.

		k9 <name> - Kills a process by name.

		la - Lists all files in the current directory with detailed formatting.(only on windows)

		ll - Lists all files, including hidden, in the current directory with detailed formatting.(only on windows)

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

    Get-OllamaModels -ModelName "llama2" [-RetryInterval 60] [-MaxAttempts 10] - download ollama model and speed up .# 加载 llama2 模型，默认每隔 60 秒重启下载进程，最多尝试 10 次 

    Get-VideoDuration -Path "D:\Videos" [-l 每个视频的时长信息] [-s 时长降序排序] [-n ][10] - get videos duration # 获取指定目录下的视频文件的播放时长信息

		Use 'Show-Help' to display this help message.
"@
}
Write-Host "Use 'Show-Help' to display help"
