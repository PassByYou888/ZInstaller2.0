## ZInstaller2.0解决了TB级规模的大数据安装问题

- **ZInstaller2.0** 相比 [**https://github.com/PassByYou888/zInstaller**](https://github.com/PassByYou888/zInstaller) 使用了全新的ZDB2.0架构制作文件数据包
- 支持在100M内存条件下多线程解压安装超大体积的数据文件（可以支持到TB级规模）
- 打包工具支持多线程IO，可以快速打包数以万计的大规模目录和文件
- 安装程序运行端采用FMX编写
- ZAI工具链使用**ZInstaller2.0**打包制作，实现了高效展开单个10G体量的大数据文件
- **ZInstaller2.0** 支持高效率数据加密

## 简单使用入门

- 编译**ZInstaller2.0**需要ZDB2.0支持，[https://github.com/PassByYou888/ZDB2.0](https://github.com/PassByYou888/ZDB2.0)
- 制作安装程序包：使用 **zInstaller2BuildTool.exe** 对目标目录分批打包，生成 **zInstall2.conf**
- 运行安装程序：自己构建和编译**zInstaller2.exe**，定义好名字，将**zInstall2.conf**和数据包copy到同目录中
- 运行安装程序完成安装
- 系统卸载信息自己去编写注册表导入项


by.qq600585

2021-3-24
