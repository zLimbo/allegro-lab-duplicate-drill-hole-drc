# Duplicate Drill Hole DRC Test Plan

## 目标

验证 Allegro Duplicate Drill Hole DRC 是否仅在以下两个条件同时满足时触发：

1. 两个 drill hole 的 `XY` 坐标完全相同。
2. 两个 drill hole 的 `layer span` 完全相同。

并观察以下因素是否参与判定或只影响报错文本：

- padstack 名称是否相同
- finished / drill 孔径是否相同
- plated / non-plated 属性是否相同
- round drill 与 slot 是否互相触发
- object type 是否相同，例如 via、pin、mounting hole、mechanical hole
- net 是否相同
- 坐标微小偏差是否被容差吸收

## 总体方法

建立最小测试 board，使用可控对象对比。每个 case 中只改变一个变量，其余变量保持一致。

推荐基准对象：

- `A`: plated through via 或通孔 pin，坐标 `(1000.000, 1000.000)` mil。
- `B`: 与 `A` 叠放或按 case 偏移的第二个 drill object。
- 默认 layer span：`TOP-BOTTOM`。
- 默认 net：`NET_A`。
- 默认 hole shape：round。
- 默认 padstack：同一 padstack。

## 关键判定

每个 case 记录以下信息：

- Allegro 是否生成 `DH` DRC marker。
- marker 坐标是否接近两个孔的公共坐标。
- report 中是否出现 `DH` 或 `Duplicate Drill Hole`。
- report 中是否能区分 object pair。
- 如果没有 `DH`，是否出现其他 DRC。

## 坐标偏差测试建议

按数据库单位和 UI 单位分别理解偏差。建议偏差序列：

- `0`
- `0.000001 mil`
- `0.00001 mil`
- `0.0001 mil`
- `0.001 mil`
- `0.01 mil`
- `0.1 mil`

如果 Allegro UI 无法输入足够小的数值，应通过可用的精确输入方式或 SKILL 辅助创建。若 SKILL API 不确定，在脚本骨架中保持 TODO。

## Layer span 测试建议

至少覆盖：

- `TOP-BOTTOM` vs `TOP-BOTTOM`
- `TOP-INTERNAL1` vs `TOP-INTERNAL1`
- `TOP-BOTTOM` vs `TOP-INTERNAL1`
- `INTERNAL1-BOTTOM` vs `INTERNAL1-BOTTOM`
- `TOP-INTERNAL1` vs `INTERNAL1-BOTTOM`

若 board 只有两层，应新建四层测试 board，避免盲区。

## 预期结果模型

初始假设如下，最终以 Allegro 实测为准：

- 完全相同 `XY` + 完全相同 `layer span`：应触发 `DH`。
- 完全相同 `XY` + 不同 `layer span`：不应触发 `DH`。
- 坐标存在任意数据库可分辨偏差：不应触发 `DH`，除非 DRC 内部有容差或坐标归一化。
- padstack、孔径、plating、net 变化不应阻止 `DH`，如果 DRC 定义只看 drill hole 和 span。
- round drill 与 slot、不同 object type 是否互相触发属于待测重点。

## 结论输出

完成测试后，建议给出：

- `XY` 判定是否是 exact match，或存在实际容差。
- `layer span` 是否必须 exact match。
- 哪些变量影响 `DH` 触发。
- 哪些变量只影响 report 文本或 marker 属性。
- Allegro 版本、hotfix、database units、constraint setup 截图或导出信息。
