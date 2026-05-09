<a id="english"></a>

# Allegro Lab: Duplicate Drill Hole DRC

[English](#english) | [中文](#中文)

This repository is a local research project for characterizing Cadence Allegro's Duplicate Drill Hole DRC behavior.

- Attribute: `DUP_DRILL_HOLE_VMODE`
- DRC code / identifier: `DH`
- Tested Allegro version: `Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition`
- Local Cadence tool path used during testing: `C:\Cadence\SPB_24.1\tools\bin`

The project has verified that Allegro can be driven through no-GUI/batch execution for this workflow:

```powershell
allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>
dbdoctor.exe -drc_only -outfile <out.brd> <in.brd>
report.exe -v drc <board.brd> <report.rpt>
```

## Repository Contents

- `docs/test_plan.md`: original test plan and target decision boundaries.
- `docs/automation_strategy.md`: verified automation strategy and command chain.
- `docs/lab_results.md`: unified lab results and conclusions.
- `docs/showcase_case_analysis.md`: detailed per-case analysis for the generated showcase board.
- `matrix/duplicate_drill_hole_case_matrix.csv`: original case matrix.
- `matrix/padstack_requirements.csv`: padstack requirements.
- `scripts/dh_showcase_board.il`: Allegro SKILL script that generates the showcase board.
- `scripts/dh_showcase_board.scr`: Allegro replay script for board generation.
- `scripts/run_drc_report.ps1`: PowerShell wrapper for `dbdoctor` and `report`.
- `scripts/parse_drc_report.py`: parser for Duplicate Drill Hole entries in Allegro DRC reports.
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`: showcase board with regenerated DRC markers.
- `reports/dh_duplicate_drill_showcase.drc.rpt`: exported DRC report for the showcase board.
- `results/dh_showcase_objects.csv`: generated object map and case labels.
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`: parsed DH records.

## Regenerate The Showcase Board

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_duplicate_drill_showcase.brd' -Force
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_duplicate_drill_showcase.brd -OutputBoardPath .\allegro\dh_duplicate_drill_showcase.drc_only.brd -ReportPath .\reports\dh_duplicate_drill_showcase.drc.rpt
python .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

## Current Boundary Model

The observed behavior is best modeled as:

```text
report DH when:
  effective drill XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

Observed non-factors once those two conditions hold include padstack name, copper pad size, copper pad shape, drill diameter, plating, round/slot style, slot size, slot X/Y orientation, object type, net name, and no-net status. Drill-body overlap without matching drill origin has not reported DH in the current showcase. For multi-drill padstacks, current evidence indicates a pattern-level comparison: identical multi-drill patterns at the same origin report, while partial member-hole overlap and pattern/pitch mismatch do not.

See `docs/showcase_case_analysis.md` for detailed per-case evidence.

---

<a id="中文"></a>

# Allegro Lab: Duplicate Drill Hole DRC

[English](#english) | [中文](#中文)

本仓库用于调研 Cadence Allegro 的 Duplicate Drill Hole DRC 真实判定边界。

- Attribute: `DUP_DRILL_HOLE_VMODE`
- DRC code / identifier: `DH`
- 实测 Allegro 版本：`Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition`
- 本地 Cadence 工具路径：`C:\Cadence\SPB_24.1\tools\bin`

本项目已验证 Allegro 可以通过 no-GUI/batch 方式执行以下流程：

```powershell
allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>
dbdoctor.exe -drc_only -outfile <out.brd> <in.brd>
report.exe -v drc <board.brd> <report.rpt>
```

## 仓库内容

- `docs/test_plan.md`：原始测试计划与目标边界。
- `docs/automation_strategy.md`：已验证的自动化策略与命令链路。
- `docs/lab_results.md`：统一 lab 结果与结论。
- `docs/showcase_case_analysis.md`：生成展示板的逐项 case 分析。
- `matrix/duplicate_drill_hole_case_matrix.csv`：原始 case matrix。
- `matrix/padstack_requirements.csv`：padstack 需求。
- `scripts/dh_showcase_board.il`：生成展示板的 Allegro SKILL 脚本。
- `scripts/dh_showcase_board.scr`：展示板生成 replay 脚本。
- `scripts/run_drc_report.ps1`：封装 `dbdoctor` 和 `report` 的 PowerShell 脚本。
- `scripts/parse_drc_report.py`：解析 Allegro DRC report 中 Duplicate Drill Hole 记录的脚本。
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`：已重新生成 DRC marker 的展示板。
- `reports/dh_duplicate_drill_showcase.drc.rpt`：展示板导出的 DRC report。
- `results/dh_showcase_objects.csv`：生成对象映射与 case 标签。
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`：解析后的 DH 记录。

## 重新生成展示板

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_duplicate_drill_showcase.brd' -Force
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_duplicate_drill_showcase.brd -OutputBoardPath .\allegro\dh_duplicate_drill_showcase.drc_only.brd -ReportPath .\reports\dh_duplicate_drill_showcase.drc.rpt
python .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

## 当前边界模型

实测行为更接近以下模型：

```text
report DH when:
  effective drill XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

当上述两个条件成立时，目前观察到以下因素不会抑制 DH：padstack 名称、copper pad 大小、copper pad 形状、孔径、plating、round/slot 类型、slot 尺寸、slot X/Y 方向、object type、net 名称以及 no-net 状态。当前 showcase 中，只有 drill 孔体重叠但 drill origin 不同的情况没有触发 DH。对于 multi-drill padstack，当前证据表明 Allegro 更像是做 pattern-level 比较：同 origin 且 multi-drill pattern 相同会报，局部 member-hole 重合或 pattern/pitch 不同不会报。

逐项证据见 `docs/showcase_case_analysis.md`。
