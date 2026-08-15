# 小账本

一个针对两台手机共同使用的轻量记账 PWA：按月开账、支出/收入分类、自定义金额键盘、流水编辑、月度统计、离线记录、共享码云同步和 JSON 备份。无需账号体系，可直接安装到手机桌面。

## 本地运行

不能直接双击 `index.html`（Service Worker 需要 HTTP）。在项目目录运行：

```bash
npx serve .
```

打开终端显示的网址即可。未配置云端时，所有功能都可用，但数据只保存在当前设备。

## 配置两台手机同步

1. 在 [Supabase](https://supabase.com/) 新建免费项目。
2. 打开 SQL Editor，执行 `supabase.sql`。
3. 从项目顶部的 **Connect** 窗口复制 Project URL 和 **Publishable key**；旧项目也可使用 anon key。
4. 填入 `config.js` 的 `SUPABASE_URL` 和 `SUPABASE_ANON_KEY`。字段名保留了 anon，但支持新的 Publishable key。
5. 两台手机进入应用“设置”，填写相同的、至少 12 位的随机共享码。

`supabase.sql` 已使用行级安全策略（RLS），每个请求只能读取请求头中共享码对应的数据，不能枚举其他账本。共享码仍等同于这本账的密码，因此不要使用姓名、手机号等易猜内容；如果未来提供给更多用户，应升级为正式登录。

> 不要把 Secret key 或 service_role key 填入前端文件；它们拥有高权限，只能用于服务器。

## 部署到 GitHub Pages

项目已经包含 `.github/workflows/pages.yml`：

1. 新建 GitHub 仓库，把本目录全部文件推送到 `main` 分支。
2. 仓库 Settings → Pages → Build and deployment 选择 `GitHub Actions`。
3. 打开 Actions 页面，等待 `Deploy Pocket Ledger` 完成。
4. 两台手机打开 Pages 提供的 HTTPS 地址，在浏览器菜单中选择“添加到主屏幕”。

修改 `config.js` 后推送，GitHub 会自动重新部署。

## 数据规则

- 每条记录有全局唯一 ID，双设备合并时不会产生重复记录。
- 删除采用软删除，避免另一台设备同步后把旧记录恢复。
- 空的月账本也会同步，因此一台手机新开月份后，另一台也能看到。
- 离线新增会先写入浏览器本地存储，联网后自动尝试同步。
- 可随时从设置导出 JSON 备份。
