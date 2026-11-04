# Basys3 摄像头、云台与雷达 FPGA 源码

两块 Basys3，各跑一个工程：一块做摄像头、状态机和云台，一块做雷达处理。两块都是 XC7A35T-CPG236-1，各自有顶层和引脚约束。

| 目录 | 内容 |
| --- | --- |
| `01-camera-gimbal/` | OV7725、VGA、颜色检测、PWM、S0～S3 状态机与串口（2026-11-04 S3 板端版本） |
| `02-radar-fpga/` | N10P 数据解析、定点坐标转换、背景和运动点检测 |

## 摄像头与云台

顶层是 `01-camera-gimbal/srcs/top.v`。采集、VGA、RGB/HSV、颜色分割、形态学、云台 PWM 都在 FPGA 里做，`mode_control.v`、`mode_uart.v`、`mode_display.v` 管模式、串口和数码管。

- S0：FPGA 按颜色自主追踪。
- S1：外部给视觉坐标，FPGA 控制云台跟随。
- S2：外部给绝对脉宽，也能跟视觉目标。
- S3：只收绝对脉宽，红色目标识别和初始位置由泰山派做。

YOLO 推理、雷达引导、网页、无线图传、小车陀螺仪和编码器都在外部软件里，不在这两个目录。图传走 FPGA VGA → USB 采集卡 → 泰山派。

接口：JA1/J1 横向 PWM，JA2/L2 纵向 PWM；JA3/J2 串口收，JA4/G2 串口发；3.3V TTL、115200、8N1。引脚和按键见 `srcs/vo7725.xdc`。横向 500～2500 微秒，纵向 1250～2500 微秒，装上去还要标定。

## 雷达

顶层是 `02-radar-fpga/rtl/n10p_top.sv`。N10P 包解析与校验、回波选择、角度插值、距离筛选、正弦查表、XY 定点，输出带背景变化和径向运动的 V2 包。`sin_q16.mem` 是正弦表。

泰山派把雷达串口转给 FPGA，FPGA 回处理结果，921600 8N1。上电或按中央键复位后采背景，跟网页手动采背景不是一套。不含 YOLO 和聚类跟踪，约束见 `rtl/basys3.xdc`。

雷达板实机调过：网页能看到扫描，板端记录约 10 Hz、每圈 529～531 点，用于 S3 炮台方向显示。

## 构建

Vivado 2026.1，各自目录下：

```sh
cd 01-camera-gimbal
vivado -mode batch -source build.tcl
```

```sh
cd 02-radar-fpga
vivado -mode batch -source scripts/build.tcl
```

只构建，不连硬件不烧录。摄像头工程的两个 `.xci` 是重建 IP 用的，雷达工程的 `.mem` 是功能资源。。

## 版本



未指定许可证。
