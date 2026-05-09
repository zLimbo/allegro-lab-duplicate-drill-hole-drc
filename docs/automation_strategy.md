# Board and Padstack Automation Strategy

结论：本项目已验证 Allegro 24.1 可以通过 no-gui/batch 方式完成测试板生成、DRC 更新、report 导出与结果解析。

## 已验证命令链路

Cadence 工具路径：

```text
C:\Cadence\SPB_24.1\tools\bin
```

已验证可用命令：

```powershell
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
dbdoctor.exe -drc_only -outfile <out.brd> <in.brd>
report.exe -v drc <board.brd> <report.rpt>
python scripts\parse_drc_report.py <report.rpt> --csv <out.csv>
```

## 自动化覆盖范围

| 项目 | 当前状态 | 实现方式 |
|---|---|---|
| 创建测试 board | 已实现 | 复制 Cadence demo board 作为 template |
| 清理 keepin/keepout | 已实现 | `axlDeleteByLayer` |
| 创建 round padstack | 已实现 | SKILL `make_axlPadStackDrill` / `axlDBCreatePadStack` |
| 创建 slot padstack | 已实现 | SKILL slot drill / oblong pad |
| 创建 blind/buried padstack | 已实现 | SKILL `bbvia` drill usage |
| 创建不同 copper pad 尺寸/形状 | 已实现 | 自定义 padstack pad figure/size |
| 放置 via pair/triple | 已实现 | `axlDBCreateVia` |
| 放置 package pin-via case | 已实现 | `axlDBCreateSymbol` + via |
| 使用 demo board 真实 through pin | 已实现 | 扫描 component pin 并放置 via |
| 启用 Duplicate Drill Hole | 已实现 | `axlCNSDesignModeSet 'Duplicate_Drill_Hole 'on` |
| 关闭其它 DRC mode | 已实现 | spacing/same-net/physical/assembly/ecset/design mode set off |
| 运行 DRC | 已实现 | `dbdoctor.exe -drc_only` |
| 导出 report | 已实现 | `report.exe -v drc` |
| 解析 DH | 已实现 | `scripts/parse_drc_report.py` |

## 当前推荐流程

1. 用 `scripts/dh_showcase_board.il` 维护或新增 case。
2. 用 `scripts/dh_showcase_board.scr` 在 no-gui Allegro 中生成 board。
3. 用 `scripts/run_drc_report.ps1` 更新 DRC 并导出 report。
4. 用 `scripts/parse_drc_report.py` 生成结构化 CSV。
5. 将 case 说明与结论同步到 `docs/showcase_case_analysis.md`。

## 仍需谨慎的点

- 不同 Allegro 版本、license、公司封装的 template board 可能导致 SKILL API 或 constraint mode 名称不同。
- 当前 slot case 没有穷举旋转角和非中心几何相交场景。
- 当前 production-style mounting hole symbol 未作为独立公司库对象验证；现有覆盖包括 NPTH padstack、package pin、真实 through pin。
- 坐标阈值应表述为 Allegro 数据库存储/量化后的 XY 行为，而不是任意浮点几何相等。
