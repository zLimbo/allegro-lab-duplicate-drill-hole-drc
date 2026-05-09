# 自动化验证结果

运行日期：2026-05-09

Cadence 工具路径：

```text
C:\Cadence\SPB_24.1\tools\bin
```

实测 Allegro 版本：

```text
Allegro PCB Venture 24.1 S001 Windows SPB 64-bit Edition
```

## 自动化链路

本工程已通过 Allegro no-gui/batch 方式完成测试板生成、DRC 更新、report 导出与结果解析。

已验证命令链路：

1. `allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>`
2. SKILL 生成 padstack、via、slot via、blind/buried via、package pin-via case、真实 through pin-via case。
3. SKILL 启用 `Duplicate_Drill_Hole` design mode。
4. `dbdoctor.exe -drc_only` 在 board copy 上重新生成 DRC。
5. `report.exe -v drc` 导出 DRC report。
6. `scripts/parse_drc_report.py` 解析 `Duplicate Drill Hole` 记录。

## 生成的主要文件

- `allegro/dh_duplicate_drill_showcase.brd`
- `allegro/dh_duplicate_drill_showcase.drc_only.brd`
- `reports/dh_duplicate_drill_showcase.drc.rpt`
- `results/dh_duplicate_drill_showcase.parsed_dh.csv`
- `results/dh_showcase_objects.csv`
- `docs/showcase_case_analysis.md`

辅助验证文件：

- `allegro/dh_auto_via_cases.brd`
- `allegro/dh_auto_via_cases.drc_only.brd`
- `reports/dh_auto_via_cases.drc.rpt`
- `results/dh_auto_via_cases.parsed_dh.csv`
- `allegro/dh_auto_span_cases.brd`
- `allegro/dh_auto_span_cases.drc_only.brd`
- `reports/dh_auto_span_cases.drc.rpt`
- `results/dh_auto_span_cases.parsed_dh.csv`
- `allegro/dh_pin_probe.brd`
- `allegro/dh_pin_probe.drc_only.brd`
- `reports/dh_pin_probe.drc.rpt`
- `results/dh_pin_probe.parsed_dh.csv`

## 展示板结果

当前展示板包含 50 个阵列 case，加 1 个 demo board 真实 through pin-via 对照。

最新 DRC report 结果：

- `Total DRC Errors = 36`
- 36 条详细 DRC 全部为 `Duplicate Drill Hole`
- report 中没有残留 Route Keepin、Route Keepout、Spacing、Physical、Miscellaneous 等其它 DRC 项

展示板详细逐项分析见：

```text
docs/showcase_case_analysis.md
```

## 主要结论

初始假设“只有 drill hole 的 XY 完全相同且 layer span 完全相同时才报错”只对了一部分。

更接近 Allegro 实测行为的模型是：

```text
report DH when:
  effective drill XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

也就是说，判定核心更像是：

1. 两个 drill-bearing 对象的有效 drill XY 在 Allegro 数据库存储/量化后相同。
2. 两个对象的 drill layer span 在 Z 向存在正长度重叠。

## XY 边界

DRC 看起来使用 Allegro 数据库中的存储坐标，而不是无限精度的浮点输入值。

在早期 2-layer mil board 测试中：

- `0.000001 mil`
- `0.00001 mil`
- `0.0001 mil`
- `0.001 mil`

这些偏移会被存储/显示到同一 `0.01 mil` 坐标，并触发 DH。

在当前 showcase board 中：

- `X+0.0001` 触发 DH。
- `X+0.001` 未触发 DH。
- `X+0.01` 未触发 DH。
- `Y+0.01` 未触发 DH。

因此实现等价规则时，不应直接使用任意浮点比较；更稳妥的方式是使用 Allegro 数据库坐标或与数据库精度一致的量化坐标。

## Layer Span 边界

实测显示 layer span 不要求完全相同。

会触发 DH 的情况：

- through via vs through via
- same blind/buried span
- through via vs blind/buried via，只要 Z 向有重叠
- TOP-GND vs TOP-INNER1 这类非完全相同但有重叠的 span
- GND-POWER vs INNER2-BOTTOM 这类有正长度重叠的 span

未触发 DH 的情况：

- 完全分离的 span
- 仅端点相接的 span，例如 TOP-INNER1 vs INNER1-BOTTOM
- 仅在 GND 或 INNER2 边界点相接的 span

因此，span 判断更接近“正长度重叠”，而不是“span 名称/端点完全相同”。

## 已验证不影响 DH 的因素

当有效 XY 相同且 drill span 有正长度重叠时，以下因素没有抑制 DH：

- padstack 名称不同
- copper pad 大小不同
- copper pad 形状不同，包括 round、square、oblong
- 不同层上的 copper pad 大小/形状组合不同
- drill diameter 不同
- plating 不同，包括 PTH vs NPTH、NPTH vs NPTH
- round drill vs slot
- slot vs slot
- slot 尺寸不同
- slot X/Y 方向不同
- net 不同
- 一个对象 no-net
- 两个对象都 no-net
- via vs package pin
- via vs demo board 真实 through pin

## Pad 大小和形状专项结论

新增的 R6/R7 showcase cases 专门隔离了 copper pad 几何变量，在 drill diameter、plating、through span 保持相同的情况下，只改变 pad 大小或 pad 形状。

实测均触发 DH：

- small round pad vs large round pad
- standard pad vs large custom pad
- standard pad vs small custom pad
- square pad vs round pad
- oblong pad vs round pad
- square pad vs oblong pad
- TOP-small/BOTTOM-large vs TOP-large/BOTTOM-small
- pad size mismatch + different net
- pad shape mismatch + both no-net

结论：Duplicate Drill Hole 判定不应把 copper pad 大小或 copper pad 形状作为 duplicate key。它们可以作为诊断上下文记录，但不应参与是否报 DH 的核心判断。

## Drill 形状和 slot 几何专项结论

新增 R8/R9 showcase cases 专门隔离了 slot 方向、slot 孔体重叠、round drill 落入 slot 孔体、cross-slot 偏移等变量。

实测触发 DH：

- X 方向 slot vs Y 方向 slot，origin 相同
- X 方向 slot vs Y 方向 slot，cross-slot 但 origin 相同

实测不触发 DH：

- 两个 X 方向 slot 的孔体有重叠，但 origin 分别偏移 `X+0.20`、`X+0.50`
- 两个 X 方向 slot 分离，origin 偏移 `X+0.80`
- round drill 位于或接近 slot 孔体范围内，但 round drill origin 与 slot origin 不同
- X/Y cross-slot 孔体可能相交，但 origin 偏移 `X+0.20,Y+0.20`
- X/Y cross-slot 在 `X+0.001` 偏移下不触发 DH

结论：当前实测不支持“只要 drill 几何实体相交就报 Duplicate Drill Hole”的模型。Allegro 更像是比较 drill-bearing object 的有效 drill origin，并结合 Z 向 layer span 是否有正长度重叠；slot 的形状、方向和实体 overlap 可以作为诊断上下文，但不应参与 duplicate key。

## 多对象同点行为

当三个 drill-bearing 对象位于同一 XY 且 span 重叠时，Allegro 不是只产生一条聚合 marker，而是产生 pairwise markers。

当前 R3C0 中三个 via 同点，report 中生成 3 条 `Duplicate Drill Hole` 记录。

## 推荐实现逻辑

如果要实现 Allegro-like Duplicate Drill Hole 检查，建议核心逻辑为：

```pseudo
for each pair of drill_objects:
    xy_a = quantize_to_database_xy(a.drill_origin)
    xy_b = quantize_to_database_xy(b.drill_origin)

    if xy_a == xy_b
       and layer_spans_overlap_with_positive_length(a.drill_span, b.drill_span):
           report_duplicate_drill_hole(a, b)
```

其中：

- `drill_origin` 对 slot 也应使用 Allegro padstack/drill 定义中的有效 origin，而不是 copper pad 外形中心或 drill 实体 overlap 推测值。
- `quantize_to_database_xy` 应与 Allegro 数据库单位和坐标存储行为一致。
- `layer_spans_overlap_with_positive_length` 不应把仅端点相接视为重叠。
- 结果应按 object pair 产生 marker，而不是按坐标聚合成单条 marker。

## 残余限制

- Allegro 内部坐标量化规则没有从官方文档中完整反推，当前结论来自本机实测。
- slot 方向已覆盖生成的 X/Y padstack figure，但任意角度旋转 slot 和公司库生产对象尚未穷举。
- production-style mechanical mounting hole symbol 尚未作为公司库对象单独验证；当前覆盖包括 NPTH padstack、package pin、真实 through pin。
- 不同 Allegro 版本、不同 license、不同公司 template board 可能影响可用 SKILL API 或 constraint mode 名称。
- 当前结果基于 Cadence Allegro PCB Venture 24.1 S001 和 Cadence demo board stackup。
