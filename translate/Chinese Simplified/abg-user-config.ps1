# 预设数值
# 如果想使用“多个耳机模式”，复制“true”到等于号后面。
# 在这个模式下，除了这个以外的所有数值都被忽略掉。
# （这个模式使用“json”文件来填写数值）
$behaviorMultiHeadphone = $false

# 你持有的耳机型号对应的数据存放位置
# 使用带分区号的完整路径和基于目前文件夹的短路径都可以，
# 这里用完整路径是因为通常我们从“Everything”软件中直接复制路径。
# 此处耳机型号仅作示范而没有别的特殊意义。
$inputFolder_default = "C:\AutoEq-master\oratory1990\data\onear\Philips SHP9500"

# 保存的结果位置
# 而这里使用短路径是方便。
$outputFolder_default = "myresults\9500"

# 耳机类型，选择其中之一就会自动跳过另外种类。
# （不同类型耳机之间不容易有好的结果，跳过那些可以加快软件运行时间）
# 可用选项：
# "OnEar" ——头戴式耳机，开放式与封闭式
# "InEar" ——入耳式耳机
# "Earbud" ——耳塞
# 仍然想尝试跨种类，使用这个
# "None"
$headphoneType_default = "None"

# Pip下载服务器
# 此处也可指定自定义的pip选项（试做功能，不按照说明乱填就会出错）。
#
# 这个示范命令展示如果你想使用一台中国网络的下载服务器（下载速度更快）。
#   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple virtualenv
# 在每个词组的后面必须添加一个英文空格（关掉你的输入法！）才能正确指示。
#   $pipCustomArgument = "-i https://pypi.tuna.tsinghua.edu.cn/simple "
#
# 什么都不写就使用外国服务器：
# 注意在这种情况下反而没有空格。
#   $pipCustomArgument = ""
#
# 提示：你正在使用中文版本，此处已为你优化，不必修改。
$pipCustomArgument = "-i https://pypi.tuna.tsinghua.edu.cn/simple "




# 即使为了方便起见这些数值可以修改，但是不推荐。
# 如果你想寻找帮助，你必须不修改这些数值才能帮你诊断问题，
# 否则不可能找到问题究竟发生在哪。

# AutoEq的解压位置
$autoEqInstallPath = "C:\AutoEq-master"

# 设置导出的快速启动文件保存位置
$CSTPW_SCRIPT_FILE = "$autoEqInstallPath\AutoEqBatch.cmd"

# 去除AutoEq默认的6分贝增益上限
# 我们不解释这是什么
$maxGain = "48.0"
$trebleMaxGain = $maxGain

# 当一个结果已经存在时是否覆盖掉
# 设为$false可在第二次以及以后运行中加快速度，
# 但修改后的数值不会对第一次保存的结果起作用。
# 想要覆盖，使用$true
$behaviorOverwriteExistResult = $false

# 导出快速启动文件后直接打开这个东西
$behaviorAutoRunSavedScript = $true