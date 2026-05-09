# Manual Allegro Steps

以下步骤需要在 Allegro 中手工执行。本工程不会自动启动 Allegro，也不假设 GUI 可自动化。

## 一次性准备

1. 新建一个测试 board，建议命名为 `dh_boundary_test.brd`。
2. 建议使用四层 stackup：`TOP`, `INTERNAL1`, `INTERNAL2`, `BOTTOM`。
3. 建立或确认以下 padstack：
   - round plated through padstack
   - round non-plated through padstack
   - 不同孔径的 round plated padstack
   - slot padstack
   - blind / buried span padstack，如果许可证和流程允许
4. 在 Constraint Manager 或 DRC 设置中启用 `DUP_DRILL_HOLE_VMODE`。
5. 确认 DRC report 可以导出为文本文件。

## 每个 case 的执行步骤

1. 打开 `matrix/duplicate_drill_hole_case_matrix.csv`，选择一个 case。
2. 在 board 上放置对象 `A` 与 `B`。
3. 按 case 指定设置：
   - object type
   - padstack
   - drill diameter
   - plating
   - slot / round
   - layer span
   - net
   - `B` 相对 `A` 的 `dx`, `dy`
4. 运行 DRC。
5. 导出 DRC report 到 `reports/<case_id>_drc.rpt`。
6. 观察 DRC marker，记录是否有 `DH` marker、marker 坐标、涉及对象。
7. 运行解析脚本，例如：

```powershell
python .\scripts\parse_drc_report.py .\reports\TC001_drc.rpt --csv .\results\TC001_dh.csv
```

8. 将人工观察和脚本结果填入 `results/dh_results_template.csv`。
9. 清除或隔离当前 case 对象，再执行下一个 case。

## 可选命令行 DRC/report

本机已确认 `C:\Cadence\SPB_24.1\tools\bin\dbdoctor.exe` 支持 `-drc_only`，`report.exe` 支持 `-v drc`。

如果 board 已保存，且已启用 `DUP_DRILL_HOLE_VMODE`，可以用：

```powershell
.\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_boundary_test.brd
```

脚本会生成一个 `.drc_only.brd` 副本并导出 DRC report。若只导出 report，不更新 DRC：

```powershell
.\scripts\run_drc_report.ps1 -BoardPath .\allegro\dh_boundary_test.brd -ReportOnly
```

## 推荐隔离方式

- 每个 case 放在不同坐标区，例如 X 方向每个 case 间隔 `500 mil`。
- 或每个 case 使用单独 board copy。
- 若多个 case 同时存在，report 中 marker 数量可能难以归因，需记录 case origin。

## 需要特别注意

- 坐标必须记录 UI 显示值和实际输入值。
- 微小偏差 case 应确认 Allegro 是否把输入坐标四舍五入到相同数据库坐标。
- 如果 report 中没有明显 `DH` 文本，但 GUI 有 marker，应截图或记录 marker property。
- 如果出现非 `DH` 的 DRC，应单独记录，避免误判。
