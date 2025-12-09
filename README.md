# NixOS Hyprland Setup for wen (中 / EN)

## 简介 (简体中文)
注：这些东西是ai生成的，谨慎使用，并确保按照自己的配置更改config！！！！！！！
这个工作区包含一个完整的非-flake NixOS 配置（25.11），针对物理机部署优化，包含：
- `configuration.nix`：完整系统配置（Hyprland、fcitx5、中文字体、Chrome、Flatpak）
- `dotfiles/`：Hyprland、Waybar、Mako、fcitx5 用户配置文件
- `scripts/`：部署、清理、壁纸解码脚本
- 双语文档与对话记录

**重要** ：密码已设置为 "3014"（明文），首次启动后建议在目标机修改为强密码。

## 快速部署（Quick Deploy）

### 前置要求
- 目标机器已安装 NixOS 25.11
- 有 root/sudo 权限
- （可选）信任的镜像公钥文件 `trusted-keys.txt`

### 步骤 1：将文件复制到目标机
```bash
# 在 Windows 主机上（PowerShell）
scp -r c:\Users\wen\mynixos user@target-machine:/tmp/mynixos

# 或在 WSL 上
bash -c "scp -r /mnt/c/Users/wen/mynixos user@target-machine:/tmp/mynixos"
```

### 步骤 2：在目标机上运行部署脚本
```bash
# SSH 进入目标机
ssh user@target-machine

# 解码壁纸
sudo bash /tmp/mynixos/scripts/deploy-wallpapers.sh

# 使用中国镜像和信任公钥进行一代部署
sudo bash /tmp/mynixos/scripts/deploy-generation.sh \
  --source /tmp/mynixos/configuration.nix \
  --substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-cache/ https://mirrors.ustc.edu.cn/nix-cache/ https://cache.nixos.org" \
  --trusted-keys-file /tmp/trusted-keys.txt \
  --yes
```

### 步骤 3：清理旧世代（可选）
```bash
sudo bash /tmp/mynixos/scripts/cleanup-generations.sh --keep 3
```

## 文件说明

| 文件 | 用途 |
|------|------|
| `configuration.nix` | 主配置文件；包含系统、桌面、包、环境变量 |
| `dotfiles/hypr/hyprland.conf` | Hyprland 配置；autostart 包括 waybar、mako、fcitx5 |
| `dotfiles/waybar/config.json` | Waybar 配置；支持网络、电池、音量、时间等 |
| `dotfiles/waybar/style.css` | Waybar 样式；深色主题 |
| `dotfiles/mako/mako.conf` | Mako 通知配置；位置、边距、超时设置 |
| `dotfiles/fcitx5/profile` | fcitx5 配置；拼音、rime 输入法 |
| `scripts/deploy-generation.sh` | **主部署脚本**；将配置复制并运行 `nixos-rebuild switch` |
| `scripts/cleanup-generations.sh` | 清理旧世代和回收空间 |
| `scripts/deploy-wallpapers.sh` | 解码 base64 壁纸到 `~/.config/hypr/` |

## 配置互兼容性检查 ✓

已验证以下组件的匹配与兼容性：

- ✓ **fcitx5 + 中文字体**：`GTK_IM_MODULE`/`QT_IM_MODULE`/`XMODIFIERS` 环境变量已设置，fcitx5 + fcitx5-rime 和 noto-fonts-cjk-{sans,serif} 已包含
- ✓ **Hyprland + Waybar + Mako**：autostart 包含三个工具，样式配色一致（深色）
- ✓ **PipeWire 音频**：pipewire + pipewire-pulse 已配置，waybar 的音量模块可正常工作
- ✓ **Flatpak + Wayland**：`xdg-desktop-portal-wlr` 已添加以支持 Flatpak 和屏幕截图
- ✓ **SDDM + Hyprland**：显示管理器已设置，启用 `services.displayManager.defaultSession = "hyprland"`
- ✓ **谷歌 Chrome**：`google-chrome` 已包含，`allowUnfree = true` 已设置

## 常见问题

### Q1：登陆后没看到 Hyprland 界面？
A：检查 SDDM 是否启用（`services.displayManager.sddm.enable`）且会话名为 "hyprland"。也可手动在 TTY 登陆后运行 `Hyprland` 命令。

### Q2：中文输入法不工作？
A：
1. 检查 `fcitx5` 进程是否运行：`ps aux | grep fcitx5`
2. 如果未运行，手动启动：`fcitx5 &`（或等待 Hyprland autostart）
3. 确认环境变量：`echo $GTK_IM_MODULE` 应为 "fcitx5"

### Q3：Waybar 显示不正常？
A：确保路径正确（`--config /home/wen/.config/waybar/config.json`）并检查权限。

### Q4：壁纸没有显示？
A：
1. 运行 `deploy-wallpapers.sh` 解码 base64 文件到 `~/.config/hypr/`
2. 检查 `hyprland.conf` 中的壁纸路径：`/home/wen/.config/hypr/wallpaper1.png`

### Q5：部署失败，如何回滚？
A：`deploy-generation.sh` 会自动备份旧配置到 `/etc/nixos/configuration.nix.bak.<timestamp>`。可运行：
```bash
sudo cp /etc/nixos/configuration.nix.bak.20251209093000 /etc/nixos/configuration.nix
sudo nixos-rebuild switch
```

## 安全提醒 ⚠️

- ⚠️ **密码**：当前配置使用明文密码 "3014"。建议首次启动后立即更改：`passwd`
- ⚠️ **SSH**：若要远程访问，修改 SSH 密钥验证而不是密码登陆（编辑 `configuration.nix` 中 `services.openssh.settings`）
- ⚠️ **Trusted Keys**：如果使用自定义镜像，请确保只信任官方发布的公钥

## 语法校验结果 ✓

```
✓ configuration.nix: Nix syntax valid (nix-instantiate --parse)
✓ deploy-generation.sh: Bash syntax OK
✓ cleanup-generations.sh: Bash syntax OK
✓ deploy-wallpapers.sh: Bash syntax OK
✓ waybar/config.json: JSON format OK
```

## 下一步

1. **在目标机部署**：按上面的"快速部署"步骤执行
2. **测试 Hyprland**：重启或手动启动 Hyprland
3. **自定义配置**：根据硬件调整 GPU 驱动、字体、快捷键等
4. **安装更多应用**：通过 Flatpak（推荐微信、QQ、WPS）或 nixpkgs

---

**作者备注**：此配置经过 WSL 语法验证和 NixOS 评估检查，但实际部署效果需在目标 NixOS 25.11 物理机上测试。如遇问题，请查看 `/tmp/nixos-rebuild.log`。



