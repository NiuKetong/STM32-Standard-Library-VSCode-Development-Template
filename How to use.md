
1，从[NiuKetong/STM32-Standard-Library-VSCode-Development-Template: This template utilizes STM32 standard library functions and is designed specifically for development in the VS Code environment; please refer to the "How to use" file for usage instructions.](https://github.com/NiuKetong/STM32-Standard-Library-VSCode-Development-Template/tree/main)处下载文件夹

2，在Vscode中打开，2. 按 `Ctrl+Shift+P`，运行命令：

```
CMake: Delete Cache and Reconfigure
```

3，一般可以编译下载，使用debug预设

![[Pasted image 20260915125642.png]]

点击`运行任务`出现

![[Pasted image 20260915125713.png]]

选择第一个选项，编译并下载（如果有task button插件，可以用ai把下载做成可视化按钮）

4，新增文件和文件夹后导入CMake配置

（1）新增文件夹：
	在文件中找到`CMakeLists.txt`，添加新增的文件夹，这一步是为了可以使用该文件夹下的头文件
	![[Pasted image 20260915125947.png]]

（2）在已导入的文件夹下新增文件：
	在cmake文件夹下找到files.cmake文件，添加新增的C文件（头文件不用添加）
![[Pasted image 20260915130144.png|348]]

（3）导入后重复步骤2，重新配置Cmake信息即可