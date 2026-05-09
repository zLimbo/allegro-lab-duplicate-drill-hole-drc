# Allegro No-GUI Execution Steps

本文件保留为操作入口说明。当前工程已验证可以通过 Allegro no-gui/batch 命令链路生成测试板、运行 DRC 并导出 report。

## 生成展示板

展示板基于 Cadence 安装目录中的 demo board 复制生成：

```powershell
Copy-Item -LiteralPath 'C:\Cadence\SPB_24.1\share\pcb\examples\board_design\Cadence_Demo.brd' -Destination '.\allegro\dh_duplicate_drill_showcase.brd' -Force
cmd /c "call C:\Cadence\SPB_24.1\tools\bin\allegro_cmd.bat && allegro.exe -expert -p . -nographic -s scripts\dh_showcase_board.scr allegro\dh_duplicate_drill_showcase.brd"
```

生成脚本会：

- 删除 demo board 中的 Route Keepin/Keepout 对象。
- 创建测试 padstack，包括 round、slot、blind/buried、不同 copper pad 大小与形状。
- 打开 `Duplicate_Drill_Hole` design mode。
- 关闭其它可用 DRC mode。
- 以阵列方式放置所有测试 case。
- 写出 `results/dh_showcase_objects.csv`。

## 更新 DRC 并导出 Report

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_drc_report.ps1 `
  -BoardPath .\allegro\dh_duplicate_drill_showcase.brd `
  -OutputBoardPath .\allegro\dh_duplicate_drill_showcase.drc_only.brd `
  -ReportPath .\reports\dh_duplicate_drill_showcase.drc.rpt
```

该脚本会调用：

- `dbdoctor.exe -drc_only`
- `report.exe -v drc`

## 解析 DH 结果

```powershell
python .\scripts\parse_drc_report.py .\reports\dh_duplicate_drill_showcase.drc.rpt --csv .\results\dh_duplicate_drill_showcase.parsed_dh.csv
```

## 可视化检查

如需人工查看，可直接打开：

```text
allegro/dh_duplicate_drill_showcase.drc_only.brd
```

此文件已包含重新生成后的 DRC markers。详细 case 分析见：

```text
docs/showcase_case_analysis.md
```
