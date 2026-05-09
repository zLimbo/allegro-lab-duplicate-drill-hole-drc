# 统一 Lab 结果

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

本工程已通过 Allegro no-gui/batch 方式完成测试板生成、DRC 更新、report 导出与结果解析。本文作为项目统一结果文档，汇总 Duplicate Drill Hole 主实验、slot/multi-drill 边界实验，以及 DH 与其它 item-item DRC 的交互实验。

已验证命令链路：

1. `allegro.exe -expert -p . -nographic -s <script.scr> <board.brd>`
2. SKILL 生成 padstack、via、slot via、blind/buried via、package pin-via case、真实 through pin-via case。
3. SKILL 启用 `Duplicate_Drill_Hole` design mode。
4. `dbdoctor.exe -drc_only` 在 board copy 上重新生成 DRC。
5. `report.exe -v drc` 导出 DRC report。
6. `scripts/parse_drc_report.py` 解析 `Duplicate Drill Hole` 记录。
7. `scripts/parse_drc_report_all.py` 解析完整 detailed DRC rows，用于检查 DH 是否与其它 DRC 共存或互相覆盖。

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

item-item DRC 交互实验文件：

- `allegro/dh_item_item_interaction.dh_only.brd`
- `allegro/dh_item_item_interaction.dh_only.drc_only.brd`
- `allegro/dh_item_item_interaction.plus_item_item.brd`
- `allegro/dh_item_item_interaction.plus_item_item.drc_only.brd`
- `reports/dh_item_item_interaction.dh_only.drc.rpt`
- `reports/dh_item_item_interaction.plus_item_item.drc.rpt`
- `results/dh_item_item_interaction.dh_only.parsed_all.csv`
- `results/dh_item_item_interaction.plus_item_item.parsed_all.csv`
- `docs/item_item_interaction_lab.md`

## 展示板结果

当前展示板包含 81 个阵列 case，加 1 个 demo board 真实 through pin-via 对照。

最新 DRC report 结果：

- `Total DRC Errors = 47`
- 47 条详细 DRC 全部为 `Duplicate Drill Hole`
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
  via/padstack instance XY is the same after Allegro database coordinate storage/quantization
  and
  drill layer spans overlap with positive Z length
```

也就是说，判定核心更像是：

1. 两个 drill-bearing 对象的 via/padstack instance XY 在 Allegro 数据库存储/量化后相同。
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

## Drill offset 专项结论

新增 DO0-DO4 showcase cases 使用 `make_axlPadStackDrill(... ?offset ...)` 生成 drill center 相对 via/padstack instance origin 偏移的 padstack，用来区分 DH 到底看的是 instance origin 还是 offset 后的物理 drill center。

实测触发 DH：

- `+0.30` drill-offset padstack vs normal padstack，同 via origin
- 两个 `+0.30` drill-offset padstack，同 via origin
- `+0.30` vs `-0.30` drill-offset padstack，同 via origin

实测不触发 DH：

- `+0.30` drill-offset padstack vs normal padstack，normal via 放在 offset 后的物理 drill center 位置
- `+0.30` vs `-0.30` drill-offset padstack，两个 via origin 相隔 `X+0.60`，使 offset 后物理 drill center 对齐

结论：对这些生成的 via padstack，Allegro 24.1 Duplicate Drill Hole 的 XY 比较看起来使用 via/padstack instance origin，而不是应用 padstack `drillOffset` 后的物理 drill center。此前“effective drill origin”的表述需要收窄：在普通 round/slot case 中它与可见 drill origin 一致，但显式 `drillOffset` 不会移动 DH 比较坐标。

## Multi-drill 阵列专项结论

新增 R10/M/MDP showcase cases 使用 `multiDrillData(rows columns clearanceX clearanceY ["staggered"])` 生成 circular PTH multi-drill padstack，用来验证 UI 中 rows/columns、spacing/clearance、derived pitch、staggered 等参数对 DH 的影响。

注意：SKILL API 直接传入的是 `clearanceX/clearanceY`，对应 UI 的 spacing；UI 中的 pitch 由 `spacing + drill diameter` 派生，不是一个独立传入的 `multiDrillData` 参数。因此新增 MDP8-MDP11 使用 `0.20` drill diameter、`0.50` clearance，对应 derived pitch `0.70`，专门做 pitch-correct member-hole 对齐。

实测触发 DH：

- 1x2 multi-drill vs 同一个 1x2 multi-drill，padstack origin 相同
- 2x2 multi-drill vs 同一个 2x2 multi-drill，padstack origin 相同
- 1x2 multi-drill vs 另一个 padstack 名称不同但 multi-drill 参数完全相同的 1x2，padstack origin 相同
- 2x2 staggered multi-drill vs 同一个 2x2 staggered multi-drill，padstack origin 相同
- 2x2 non-staggered vs 2x2 staggered，rows/columns/clearance 相同且 padstack origin 相同
- 1x2 diameter-0.25 multi-drill vs 同一个 diameter-0.25 multi-drill，padstack origin 相同
- 1x2 diameter 0.20/clearance 0.50 vs 1x2 diameter 0.25/clearance 0.45，derived pitch 相同且 padstack origin 相同
- 2x2 diameter 0.20/clearance 0.50 vs 2x2 diameter 0.25/clearance 0.45，derived X/Y pitch 相同且 padstack origin 相同

实测不触发 DH：

- 1x2 multi-drill vs single round drill，single 放在 padstack origin
- 1x2 multi-drill vs single round drill，single 放到 derived pitch member-hole center
- 2x2 multi-drill vs single round drill，single 放到 derived pitch corner member-hole center
- 相同 1x2 multi-drill 阵列偏移一个 derived pitch，仅局部 member hole 重合
- 相同 2x2 multi-drill 阵列偏移一个 derived X pitch，仅局部 member hole 重合
- 2x2 multi-drill vs 1x2 multi-drill，同 padstack origin 但 pattern shape 不同
- 1x2 vs 1x3，同 padstack origin 但 column count 不同
- 1x2 vs 2x1，同 padstack origin 但 row/column orientation 不同
- 1x2 clearance-X 0.50 vs 1x2 clearance-X 0.60，同 padstack origin 但 column spacing/clearance 不同
- 2x2 clearance-Y 0.50 vs 2x2 clearance-Y 0.60，同 padstack origin 但 row spacing/clearance 不同
- 1x2 diameter 0.20/clearance 0.50 vs 1x2 diameter 0.25/clearance 0.50，同 clearance 但 derived pitch 不同

结论：当前证据更支持 Allegro 将 multi-drill padstack 作为“parameter-level drill definition”参与 DH 判定，而不是把 multi-drill 展开成多个独立 drill-hole point 后逐孔比较。也就是说，局部 member hole 重合不够；同 origin 也不够，multi-drill 的 rows/columns、row/column orientation、derived member-center pitch 等参数会影响兼容性。当前生成的 circular case 中，drill diameter 和 spacing/clearance 不需要分别一致；只要二者补偿后 derived pitch 一致，仍会报 DH。当前生成的 2x2 circular case 中，`staggered` flag 差异没有抑制 DH，因此它暂时应记为“已测不影响”而不是 parameter mismatch suppressor。

已测参数影响表：

| 参数 | 是否必须一致才报 DH | 证据 |
| --- | --- | --- |
| padstack 名称 | 否 | MDP0：名称不同但阵列几何相同，报 DH |
| rows | 是 | R10C7/MDP7：row/column 几何不同，不报 |
| columns | 是 | MDP1：1x2 vs 1x3，不报 |
| row/column orientation | 是 | MDP7：1x2 vs 2x1，不报 |
| derived column pitch | 是 | M1/MDP5 pitch 不同不报；MDP12 恢复 X pitch 后报 |
| derived row pitch | 是 | MDP2 Y pitch 不同不报；MDP13 恢复 X/Y pitch 后报 |
| drill diameter 本身 | 否 | MDP12/MDP13：孔径不同但 derived pitch 相同，报 DH |
| spacing/clearance 本身 | 否 | MDP12/MDP13：clearance 不同但 derived pitch 相同，报 DH |
| staggered flag | 否，限已测 2x2 circular case | MDP4：staggered vs non-staggered，报 DH |

## 多对象同点行为

当三个 drill-bearing 对象位于同一 XY 且 span 重叠时，Allegro 不是只产生一条聚合 marker，而是产生 pairwise markers。

当前 R3C0 中三个 via 同点，report 中生成 3 条 `Duplicate Drill Hole` 记录。

## 与其它 item-item DRC 的交互

本方向独立于主展示板，使用从 Cadence demo board 复制生成的两块新板：

- `dh_only`：只启用 `Duplicate_Drill_Hole`
- `plus_item_item`：启用 `Duplicate_Drill_Hole`、`via_via` spacing，以及 Physical `allow_padconnect = NOT_ALLOWED`

`Pad/Pad Direct Connect` 属于 Physical 规则。当前 Allegro 环境中 SKILL 暴露的 constraint 名称为 `allow_padconnect`，通过以下方式开启并设置为禁止直接连接：

```skill
(axlCNSSetPhysical nil nil 'allow_padconnect 'NOT_ALLOWED)
(axlCNSPhysicalModeSet 'allow_padconnect 'on)
```

Physical mode probe 结果显示：

```text
axlCNSPhysicalModeGet(nil) => allow_padconnect ...
```

最终 report 计数：

```text
dh_only:
  4 x Duplicate Drill Hole

plus_item_item:
  4 x Duplicate Drill Hole
  18 x Thru Via to Thru Via Spacing
  6 x Pad/Pad Direct Connect
```

逐项结果：

| Case | 几何 | 结果 |
| --- | --- | --- |
| IIC01 | same-net round via pair，同 XY | 只报 DH |
| IIC02 | different-net round via pair，同 XY | DH + 6 层 `Thru Via to Thru Via Spacing` |
| IIC03 | no-net slot via pair，同 XY | DH + 6 层 `Thru Via to Thru Via Spacing` |
| IIC04 | different-net round via pair，X 偏移 0.30 mm，pad overlap | 6 层 `Thru Via to Thru Via Spacing`，不报 DH |
| IIC05 | same-net round via pair，X 偏移 0.30 mm，pad overlap | 6 层 `Pad/Pad Direct Connect`，不报 DH |
| IIC06 | different-net round via pair，X 偏移 1.20 mm | clean control |
| IIC07 | same-net round via pair，X 偏移 0.0001 mm | 只报 DH |

结论：

- DH 不覆盖或抑制 different-net `Thru Via to Thru Via Spacing`。当同一对 vias 同时违反 DH 和 spacing 规则时，Allegro 同时报告 DH 与逐层 spacing marker。
- Physical `Pad/Pad Direct Connect` 通过 `allow_padconnect = NOT_ALLOWED` 确认可触发；same-net 可分辨偏移的 pad overlap 会报告该规则。
- 在当前 via-via duplicate 测试中，exact same XY 或经数据库量化后同 XY 的 same-net duplicate pair 只报 DH，没有同时报告 `Pad/Pad Direct Connect`。

## 推荐实现逻辑

如果要实现 Allegro-like Duplicate Drill Hole 检查，建议核心逻辑为：

```pseudo
for each pair of drill_objects:
    xy_a = quantize_to_database_xy(a.instance_origin)
    xy_b = quantize_to_database_xy(b.instance_origin)

    if xy_a == xy_b
       and layer_spans_overlap_with_positive_length(a.drill_span, b.drill_span)
       and multidrill_parameters_compatible(a, b):
           report_duplicate_drill_hole(a, b)
```

其中：

- `instance_origin` 是当前实测中更稳的 XY key；显式 padstack `drillOffset` 不应直接移动 DH 比较坐标。
- `quantize_to_database_xy` 应与 Allegro 数据库单位和坐标存储行为一致。
- `layer_spans_overlap_with_positive_length` 不应把仅端点相接视为重叠。
- `multidrill_parameters_compatible` 对普通 single drill 可视为 true；对 multi-drill 当前实测应要求 rows/columns、row/column orientation、derived member-center pitch 等参数兼容。drill diameter 与 spacing/clearance 本身不应分别作为 suppressor，因为二者补偿后 derived pitch 一致仍会报。已测 2x2 staggered flag 差异没有抑制 DH，不应先验当作 suppressor。
- 结果应按 object pair 产生 marker，而不是按坐标聚合成单条 marker。
- 不应使用 DH 覆盖或抑制其它 item-item DRC；至少 different-net via-via spacing 已实测会与 DH 共存。

## 残余限制

- Allegro 内部坐标量化规则没有从官方文档中完整反推，当前结论来自本机实测。
- slot 方向已覆盖生成的 X/Y padstack figure，但任意角度旋转 slot 和公司库生产对象尚未穷举。
- multi-drill 已覆盖生成的 1x2、1x3、2x1、2x2 circular PTH 阵列，以及 2x2 staggered flag 对照；slot multi-drill、生产库复杂机械孔对象尚未穷举。
- production-style mechanical mounting hole symbol 尚未作为公司库对象单独验证；当前覆盖包括 NPTH padstack、package pin、真实 through pin。
- 不同 Allegro 版本、不同 license、不同公司 template board 可能影响可用 SKILL API 或 constraint mode 名称。
- 当前结果基于 Cadence Allegro PCB Venture 24.1 S001 和 Cadence demo board stackup。
