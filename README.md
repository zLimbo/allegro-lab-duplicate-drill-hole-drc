# Duplicate Drill Hole DRC Local Test Project

本工程用于辅助验证 Cadence Allegro Duplicate Drill Hole DRC 的真实判定边界。

- Attribute: `DUP_DRILL_HOLE_VMODE`
- DRC Code / Identifier: `DH`
- 核心假设：只有 drill hole 的 `XY` 完全相同且 `layer span` 完全相同时才报错。
- 待验证变量：padstack、孔径、plating、slot、object type、net、坐标微小偏差。

第一阶段内容只包含本地文档、CSV 模板、report 解析脚本和可选 SKILL 骨架。它不会启动 Allegro，也不假设 GUI 可自动化。

## 文件结构

- `docs/test_plan.md`：测试计划与判定逻辑。
- `docs/manual_allegro_steps.md`：需要在 Allegro 中手工执行的步骤。
- `matrix/duplicate_drill_hole_case_matrix.csv`：建议 case matrix。
- `matrix/padstack_requirements.csv`：测试所需 padstack 清单。
- `results/dh_results_template.csv`：人工记录结果模板。
- `scripts/parse_drc_report.py`：解析 Allegro DRC report 中 `DH` 记录的辅助脚本。
- `scripts/run_drc_report.ps1`：调用 Cadence 24.1 命令行工具更新 DRC 并导出 report。
- `skill/duplicate_drill_hole_sweep_skeleton.il`：可选 SKILL 脚本骨架，含 TODO 标注。
- `docs/automation_strategy.md`：board / padstack / DRC 自动化可行性与分阶段建议。
- `docs/automated_verification_results.md`：本机自动化实测结果与结论。
- `results/automated_verification_summary.csv`：自动化验证汇总结果。

## 推荐流程

1. 在 Allegro 中新建一个小型测试 board，开启 `DUP_DRILL_HOLE_VMODE`。
2. 依据 `matrix/duplicate_drill_hole_case_matrix.csv` 逐个建立或修改测试对象。
3. 每个 case 运行 DRC，并导出 DRC report。
4. 用 `scripts/parse_drc_report.py` 从 report 中提取 `DH` 相关记录。
5. 把人工观察、report 解析结果、DRC marker 坐标写入 `results/dh_results_template.csv`。

示例：

```powershell
python .\scripts\parse_drc_report.py .\reports\case_001_drc.rpt --csv .\results\case_001_dh.csv
```

本机 Cadence 24.1 路径已探测为 `C:\Cadence\SPB_24.1\tools\bin`。如果已有 `.brd`，可以尝试：

```powershell
.\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_boundary_test.brd
```

如果 Allegro report 格式与解析脚本假设不同，请先保存一份真实 report，再按脚本中的正则表达式注释做小范围调整。
