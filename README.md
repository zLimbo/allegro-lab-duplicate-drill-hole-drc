# Allegro Lab: Duplicate Drill Hole DRC

本工程用于验证 Cadence Allegro Duplicate Drill Hole DRC 的真实判定边界。

- Attribute: `DUP_DRILL_HOLE_VMODE`
- DRC Code / Identifier: `DH`
- Allegro 版本：`Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition`
- 本地 Cadence 路径：`C:\Cadence\SPB_24.1\tools\bin`

当前项目已验证 Allegro 可通过 no-gui/batch 方式自动化执行：

```powershell
allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>
dbdoctor.exe -drc_only -outfile <out.brd> <in.brd>
report.exe -v drc <board.brd> <report.rpt>
```

## 主要文件

- `docs/test_plan.md`：测试计划与判定逻辑。
- `docs/automation_strategy.md`：自动化策略与已验证命令链路。
- `docs/automated_verification_results.md`：自动化实测结果与结论。
- `docs/showcase_case_analysis.md`：展示板中每个 case 的类型、结果与分析。
- `matrix/duplicate_drill_hole_case_matrix.csv`：原始 case matrix。
- `matrix/padstack_requirements.csv`：测试所需 padstack 清单。
- `scripts/dh_showcase_board.il`：生成展示板的 Allegro SKILL 脚本。
- `scripts/dh_showcase_board.scr`：展示板生成 replay script。
- `scripts/run_drc_report.ps1`：调用 Cadence 命令行工具更新 DRC 并导出 report。
- `scripts/parse_drc_report.py`：解析 Allegro DRC report 中 `DH` 记录。
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`：已生成 DRC 的展示板。
- `reports/dh_duplicate_drill_showcase.drc.rpt`：展示板 DRC report。
- `results/dh_showcase_objects.csv`：展示板对象坐标与说明。
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`：解析后的 DH 记录。

## 一键重跑展示板

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_duplicate_drill_showcase.brd' -Force
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_duplicate_drill_showcase.brd -OutputBoardPath .\allegro\dh_duplicate_drill_showcase.drc_only.brd -ReportPath .\reports\dh_duplicate_drill_showcase.drc.rpt
python .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

## 当前结论摘要

实测表明，Duplicate Drill Hole 的判定不要求 layer span 完全相同。更接近的模型是：

```text
report DH when:
  effective drill XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

目前观察到不影响 DH 的因素包括 padstack 名称、copper pad 大小、copper pad 形状、孔径、plating、round/slot、slot 尺寸、object type、net/no-net。
