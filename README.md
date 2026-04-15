# codexUI 中文界面版

这是一个 `codexUI` 的简体中文界面分支。

主要目标：

- 把主要界面文案改成简体中文
- 保留上游原本的本地启动方式
- 尽量少偏离上游

一句话，就是中文界面的 codexUI。

## 最简单的启动方式

### Windows

先安装依赖：

```powershell
pnpm install
```

直接启动：

```powershell
.\start-codexui.bat
```

默认行为：

- 默认复用已有构建结果
- 默认使用 `5900` 端口
- 避开常见的 `4173` 端口冲突

如果你想先强制重新构建：

```powershell
.\start-codexui.bat --build
```

启动后打开：

```text
http://127.0.0.1:5900
```

### Linux / macOS

```bash
pnpm install
pnpm run build
node dist-cli/index.js . --port 5900 --no-tunnel --no-login
```

## 也可以用 npx 启动

```bash
npx codexapp
```

如果不想自动 tunnel：

```bash
npx codexapp --no-tunnel
```

## 运行要求

- Node.js 18+
- 已安装 `pnpm`
- 本机可用的 Codex app-server / Codex CLI 环境

## 说明

这个仓库主要是中文界面分支，不打算做成另一个大分叉。

如果只是想本地用，优先用仓库里的 `start-codexui.bat` 就够了。

## 上游来源

- [friuns2/codexUI](https://github.com/friuns2/codexUI)
- [pavel-voronin/codex-web-local](https://github.com/pavel-voronin/codex-web-local)
