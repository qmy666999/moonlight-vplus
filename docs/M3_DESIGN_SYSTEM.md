# Material 3 design system

Moonlight V+ 的界面正在收敛到一套 **Material 3（M3）** 设计系统。目标不是把界面做成 Google 示例，而是让现有“串流主机 + 应用启动器 + 设置”在保留功能与性能的前提下，拥有统一的色彩、排版、形状、层级和动效。

## 1. 设计原则

- **Tonal first**：用 M3 的 surface / surface-container / primary-container 表达层级，少用高饱和渐变和大面积发光。
- **One accent**：品牌粉 `#FF6B9D` 是默认种子色；开启“跟随壁纸”后，沿用现有 `BgAccent` 从首页背景提取的 12 个色相桶，M3 主色自动跟随。
- **One theme**：Compose 侧统一使用 `MoonlightTheme`，不再在页面里各自 `darkColorScheme()`。
- **Content over chrome**：主机卡片和应用卡片优先展示封面、名称、在线状态和网络质量；装饰层降到最低。
- **Accessible by default**：48dp 触控目标、M3 类型比例、允许系统字体放大、保留手柄焦点态。

## 2. 色彩与动态取色

语义角色定义在：

- `app/src/main/res/values/m3_tokens.xml`（浅色）
- `app/src/main/res/values-night/m3_tokens.xml`（深色）

主色不是写死的静态值，而是通过 `MoonlightM3Overlay` 在运行时映射到 `?attr/appAccent`：

```xml
<item name="m3ColorPrimary">?attr/appAccent</item>
<item name="m3ColorPrimaryContainer">?attr/appAccentSoft</item>
```

`AppTheme.applyPalette()` 按以下顺序应用主题：

1. `AppAccentBrand`：品牌粉基线；
2. `YouAccentOverlayBg0..11`：首页背景提取出的色相桶（可选）；
3. `MoonlightM3Overlay`：把当前 accent 解析成 M3 语义角色。

因此切换壁纸、深浅色或强调色后，宿主界面、Compose 面板和对话框会一起更新，无需重启页面。

### 角色速查

| 角色 | 用途 |
| --- | --- |
| `m3_surface` / `m3_on_surface` | 页面底色、主文字 |
| `m3_surface_container_low` | 主机卡片、设置抽屉 |
| `m3_surface_container` | 顶栏、输入框、分组 |
| `m3_surface_container_high` | 按下态、搜索框、次级容器 |
| `m3_primary` / `?attr/appAccent` | 主操作、焦点、选中 |
| `m3_primary_container` | 主色弱化容器、图标底 |
| `m3_outline` / `m3_outline_variant` | 强/弱描边 |
| `m3_on_media` | 封面图上的文字 |
| `m3_error` / `m3_success` / `m3_warning` | 状态语义 |

## 3. 排版、形状、动效

- **排版**：`values/m3_typography.xml` 实现 M3 基线比例（Display / Headline / Title / Body / Label），统一关闭 `includeFontPadding`，标题使用 `sans-serif-medium`。
- **形状**：`values/m3_styles.xml` 定义 4 / 8 / 12 / 16 / 28dp 五档圆角；主机卡 28dp，应用卡 20dp，按钮与图标按钮 16dp/胶囊。
- **动效**：沿用现有 `ExpressiveMotion` 弹簧与 `expressive_item_state` 按压缩放，不新增高开销动画；M3 组件使用标准 ripple 与 state layer。

## 4. Compose：`MoonlightTheme`

`app/src/main/java/com/limelight/ui/theme/MoonlightTheme.kt`

```kotlin
setContent {
    MoonlightTheme {
        // MaterialTheme.colorScheme / typography / shapes 均为 M3 语义值
    }
}
```

- `surfaceOverride` 用于快速设置面板、动作面板、对白框等“浮层表面”。
- `LocalMoonlightExtendedColors` 提供 `success` / `warning` / `onMedia` / 媒体渐变等扩展色。
- 当前已迁移：快速设置面板、动作面板、About 对话框、鼠标设置、开源许可、摇杆校准。
- 游戏内菜单保留自己的深色调色板，但共享 M3 组件和形状；诊断页保留专用高对比配色。

## 5. 本轮界面改动

| 界面 | 改动 |
| --- | --- |
| 主机页 `PcView` | M3 顶栏（品牌、副标题、4 个 48dp 图标按钮）、表面色遮罩、28dp 主机卡、M3 空状态、场景按钮分组 |
| 主机卡 | 64dp 封面容器、两行标题、网络质量标签、22dp 状态徽标；多地址主机使用堆叠 tonal 表面 |
| 应用页 `AppView` | M3 标题胶囊、封面底部 scrim、两行标签、圆形运行状态徽标 |
| 设置 | M3 圆形菜单/搜索按钮、56dp 胶囊搜索框、抽屉圆角与表面色、分组/摘要颜色 |
| 全局 | 深浅色、动态 accent、启动背景、对话框表面、M3 按钮/芯片/图标按钮样式 |

## 6. 新界面接入清单

1. 背景用 `@color/m3_surface`，卡片用 `@drawable/m3_card_bg` 或 `m3_card_selector`，不要写新的十六进制背景。
2. 标题/正文使用 `TextAppearance.Moonlight.M3.*`。
3. 按钮用 `Widget.Moonlight.M3.Button` / `Button.Tonal`；图标按钮用 `Widget.Moonlight.M3.IconButton`。
4. Compose 页面用 `MoonlightTheme`，浮层用 `surfaceOverride`。
5. 交互控件至少 48dp；焦点态保留 2dp `?attr/appAccent` 描边。
6. 运行 `pwsh -File scripts/check-m3-tokens.ps1`。
7. 截图检查浅色、深色、跟随壁纸三种状态。

## 7. 保持与上游同步

M3 工作应保持为上游之上的**薄层**，避免长期分叉。仓库包含：

- `scripts/sync-upstream.ps1` / `scripts/sync-upstream.sh`：拉取 `qiin2333/moonlight-vplus` 的 `master`，在 `automation/upstream-sync` 分支上合并，并运行 token 检查。
- `.github/workflows/upstream-sync.yml`：每天定时执行同步；干净合并时自动创建 PR 到 `m3-redesign`；冲突时 job 失败并提示人工处理。

> GitHub 只会从仓库**默认分支**注册定时/手动 workflow。首次启用时，把该 workflow 文件放到默认分支（例如合并一次到 `master`），或把 `m3-redesign` 设为默认分支；workflow 本身会 checkout `m3-redesign` 进行合并。

推荐节奏：

```powershell
# 手动同步（在 m3-redesign 分支上）
pwsh -File scripts/sync-upstream.ps1
# 检查、构建、提交后
pwsh -File scripts/sync-upstream.ps1 -Push
```

### 冲突高发文件

上游经常改动这些文件，合并时优先保留上游功能，再把 M3 样式按语义角色重新套用：

- `app/src/main/res/layout/activity_pc_view.xml`
- `app/src/main/res/layout/pc_grid_item.xml`
- `app/src/main/res/layout/app_grid_item*.xml`
- `app/src/main/res/values/styles.xml`
- `app/src/main/res/values/advance_setting_colors.xml`
- `app/src/main/java/com/limelight/grid/PcGridAdapter.kt`
- `app/src/main/java/com/limelight/utils/AppTheme.kt`

原则：**业务逻辑跟上游，视觉 token 跟 M3**。不要在布局里重新引入渐变卡片或页面私有色板。

## 8. 验证

- `aapt2 compile --dir app/src/main/res`：资源语法。
- `pwsh -File scripts/check-m3-tokens.ps1`：深浅色 token、M3 attr、文本样式引用一致性。
- `./gradlew :app:assembleNonRootDebug`（需要 JDK 17、SDK 36、NDK 28、子模块与 audio-haptics SDK，见 README）。
- 手工检查：浅色/深色/跟随壁纸、字体放大 1.3x、手柄焦点、横竖屏、电视/平板。
