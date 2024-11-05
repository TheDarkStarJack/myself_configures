## 需要使用管理员用户执行
## 设置安装位置环境变量
$env:SCOOP='D:\Program Files\Scoop'
## 将上一步配置好的环境变量添加到系统变量中，（系统变量名，上一步设置的变量名，用户）
[Environment]::SetEnvironmentVariable('SCOOP','$env:SCOOP','User')

## 如果提示 Access to the path 'D:\Program Files\Scoop\apps\scoop\current' is denied.
## 则需要先创建目录，然后授予当前用户读写或完全控制权限
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iwr -useb get.scoop.sh | iex


scoop bucket add extras
scoop install 7zip `
ascii-image-converter `
cacert `
clangd `
ctags `
dark `
docker `
duckdb `
fd `
fiddler `
findutils `
fzf `
gawk `
gcc `
git `
global `
gsudo `
gzip `
lazygit `
llvm `
lua `
lua-language-server `
luarocks `
make `
neovide `
neovim `
nodejs `
oracle-instant-client `
oracle-instant-client-sqlplus
pandoc `
python `
ripgrep `
sed `
shfmt `
sqlite `
stylua `
sudo `
tar `
tree-sitter `
unzip `
vim `
wget `
wget2 `
which `
windows-terminal `
yarn 
