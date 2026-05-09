# Board and Padstack Automation Strategy

结论：手动创建 board、padstack、测试对象、DRC 执行和 report 导出可以脚本化一大部分，但建议分阶段推进。原因是 Allegro 的 SKILL API、batch 命令、padstack 编辑入口和 DRC report 命令在不同版本/许可/本地环境中可能不同。

本工程当前保持“不自动启动 Allegro”的原则，只提供脚本骨架和输入数据。所有不确定 Allegro API 都用 `TODO` 标注。

## 可自动化程度

| 项目 | 自动化可行性 | 推荐方式 | 风险 |
|---|---:|---|---|
| 新建测试 board | 中 | Allegro 命令脚本或 SKILL 初始化 | stackup、template、单位设置依赖本地流程 |
| 设置 board outline | 高 | SKILL 创建简单矩形 outline | API 名称需确认 |
| 建立 stackup | 中 | template board 更稳；脚本修改为辅 | Constraint/stackup API 版本差异较大 |
| 创建 padstack | 中 | 优先复用 `.pad` 文件；必要时用 Padstack Editor 命令流 | padstack editor 是否支持 batch 取决于安装环境 |
| 放置 via / mechanical hole | 高 | SKILL 从 case matrix 批量放置 | via、pin、mechanical object API 不同 |
| 设置 blind / buried layer span | 中 | SKILL 或预定义 padstack | span API 需确认 |
| 指定 net | 高 | SKILL 赋 net 或预先建 net | no-net/mechanical 对象需区别处理 |
| 启用 `DUP_DRILL_HOLE_VMODE` | 中 | Constraint 命令、参数文件或 SKILL | 属性位置和命令名需确认 |
| 运行 DRC | 中高 | `dbdoctor.exe -drc_only` 可用于 batch 更新 DRC | 是否已启用目标 DRC 仍需确认 |
| 导出 DRC report | 高 | `report.exe -v drc <brd> <out>` 已在本机 help 中确认 | report 格式需用真实输出校准解析器 |

## 本机已探测到的 Cadence 工具

路径：`C:\Cadence\SPB_24.1\tools\bin`

已确认存在：

- `allegro.exe`
- `allegro_batch.exe`
- `batch_drc.exe`
- `dbdoctor.exe`
- `extracta.exe`
- `padstack_editor.exe`
- `refresh_padstack.exe`
- `report.exe`

已确认命令行 help：

- `allegro_batch.exe -help`
- `allegro_batch.exe report -help`
- `allegro_batch.exe refresh_padstack -help`
- `allegro_batch.exe extracta -help`
- `dbdoctor.exe -help`
- `extracta.exe -help`
- `report.exe -help`

`report.exe` 版本输出：`24.1-S001`。

`batch_drc.exe -help` 和 `padstack_editor.exe -help` 在本机未输出 help 文本，但命令返回成功；暂不依赖它们。

## 已可脚本化的 DRC/report 链路

新增脚本：

```powershell
.\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_boundary_test.brd
```

默认行为：

1. 调用 `dbdoctor.exe -drc_only -outfile <copy.brd> <input.brd>`，在副本上更新 DRC。
2. 调用 `report.exe -v drc <copy.brd> <report.rpt>`，导出 DRC report。

如果只想导出已有 board 中的 report，不更新 DRC：

```powershell
.\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_boundary_test.brd -ReportOnly
```

注意：这条链路不能自动保证 `DUP_DRILL_HOLE_VMODE` 已启用。该属性仍建议先在 Allegro 中手工确认，或后续通过已验证的 SKILL / constraint command 自动设置。

## 推荐分阶段

### Stage A: 半自动

手工新建 board 和 padstack，使用 SKILL 只批量放置 case 对象。优点是最快获得 DRC 边界数据，且风险最低。

适合现在立即做：

- 手工准备 `dh_boundary_test.brd`
- 手工准备少量 padstack
- 运行 `dh_run_selected_cases(...)`
- 手工运行 DRC / 导出 report

### Stage B: 对象创建自动化

在确认放置 via、slot、mechanical hole 的 API 后，SKILL 从 `duplicate_drill_hole_case_matrix.csv` 批量创建所有 case，并写出对象 ID 映射日志。

建议输出：

- `results/generated_objects.csv`
- `reports/<case_id>_drc.rpt`

### Stage C: Board / padstack 初始化自动化

如果你的环境允许 batch 创建 board 和 padstack，可以再增加：

- 初始化 board 尺寸、单位、层叠
- 创建或导入 padstack
- 启用 `DUP_DRILL_HOLE_VMODE`
- 跑 DRC 并导出 report

这一步最依赖本地 Allegro 版本和公司 flow，建议等 Stage A/B 的 API 验证完成再做。

## 推荐的输入数据

- `matrix/duplicate_drill_hole_case_matrix.csv`：case 定义。
- `matrix/padstack_requirements.csv`：padstack 需求清单。

## 不建议完全自动化的部分

- 不建议假设 GUI 可点击、可截图、可自动化。
- 不建议在未确认 API 前自动修改生产环境 constraint 或 padstack library。
- 不建议在同一个 board 中混合过多未隔离 case，除非记录了每个 case 的 origin 和对象 ID。

## 最小可落地路径

1. 手工创建 board 和 padstack。
2. 在 Allegro 中加载 `skill/duplicate_drill_hole_sweep_skeleton.il`。
3. 逐个替换 TODO：先实现坐标转换、padstack lookup、via 放置。
4. 批量放置 TC001、TC002、TC012、TC014-TC018。
5. 手工运行 DRC，导出 report。
6. 用 `scripts/parse_drc_report.py` 解析。

一旦这条链路跑通，再扩展 slot、NPTH、pin、mounting hole、blind/buried span。
