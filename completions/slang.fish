# AI 自动生成补全
# 目标工具版本: slang 11.0.0+7ddf4059f
# 参考来源: slang --help
# slang 是单命令编译器, 没有子命令.
# plus 选项 +incdir/+define/+libext 无法映射为 fish 原生选项, 这里只补全候选本身, 并用自定义条件补全空格分隔的取值.

function __slang_has_double_dash
    set -l tokens (commandline -opc)
    set -l current (commandline -ct)
    if test "$current" = '--'
        return 0
    end
    contains -- '--' $tokens
end

function __slang_no_double_dash
    not __slang_has_double_dash
end

function __slang_seen_plus_arg
    if __slang_has_double_dash
        return 1
    end
    set -l tokens (commandline -opc)
    contains -- $argv[1] $tokens
end

function __slang_can_suggest_plus
    __slang_no_double_dash
    and string match -q -- '+*' (commandline -ct)
end

function __slang_option_takes_value
    set -l token $argv[1]
    if string match -q -- '--*=*' $token
        return 1
    end
    switch $token
        case --std -I --include-directory +incdir --isystem -D --define-macro +define -U --undefine-macro --max-include-depth --translate-off-format --map-keyword-version --cmd-ignore --cmd-rename --ignore-directive --max-parse-depth --max-lexer-errors -j --threads -C --max-hierarchy-depth --max-generate-steps --max-constexpr-depth --max-constexpr-steps --max-constant-size --constexpr-backtrace-limit --max-instance-array --max-enum-values --max-udp-coverage-notes --compat -T --timing --timescale --top -G -L --defaultLibName --define-system-task -W --diag-column-unit --diag-hierarchy --diag-json --error-limit --suppress-warnings --suppress-macro-warnings -v --libfile --libmap -y --libdir --dir-prefix -Y --libext +libext --exclude-ext -f -F --Mall --all-deps --Minclude --include-deps --Mmodule --module-deps --ast-json --cst-json --cst-json-mode --ast-json-scope --time-trace --time-stats --memory-stats --max-case-analysis-steps --max-loop-analysis-steps
            return 0
    end
    if string match -qr '^-[A-Za-z].' -- $token
        return 0
    end
    return 1
end

function __slang_in_source_position
    if __slang_has_double_dash
        return 0
    end
    set -l tokens (commandline -opc)
    set -l current (commandline -ct)
    if string match -q -- '-*' $current
        return 1
    end
    if string match -q -- '+*' $current
        return 1
    end
    if set -q tokens[2]
        and __slang_option_takes_value $tokens[-1]
        return 1
    end
    return 0
end

# 源文件位置参数
complete -c slang -n '__slang_in_source_position' -F -d '源文件'

# 基本帮助与版本
complete -c slang -f -n '__slang_no_double_dash' -s h -l help -d '显示帮助'
complete -c slang -f -n '__slang_no_double_dash' -l version -d '显示版本信息'
complete -c slang -f -n '__slang_no_double_dash' -s q -l quiet -d '抑制非必要输出'

# 语言标准和 include 路径
complete -c slang -f -n '__slang_no_double_dash' -l std -x -a '1364-2005 1800-2017 1800-2023 latest' -d '选择 Verilog 或 SystemVerilog 标准'
complete -c slang -f -n '__slang_no_double_dash' -s I -l include-directory -r -a '(__fish_complete_directories)' -d '添加 include 搜索路径'
complete -c slang -f -n '__slang_no_double_dash' -l isystem -r -a '(__fish_complete_directories)' -d '添加系统 include 搜索路径'
complete -c slang -f -n '__slang_no_double_dash' -l disable-local-includes -d '禁用本地 include 路径查找'
complete -c slang -f -n '__slang_no_double_dash' -l incdir-first -d '优先搜索用户指定的 include 目录'

# 宏处理
complete -c slang -f -n '__slang_no_double_dash' -s D -l define-macro -x -d '定义宏 NAME=VALUE'
complete -c slang -f -n '__slang_no_double_dash' -s U -l undefine-macro -x -d '取消宏定义'
complete -c slang -f -n '__slang_no_double_dash' -l allow-macro-trailing-space -d '允许宏续行后存在尾随空格'

# plus 选项候选
complete -c slang -f -n '__slang_can_suggest_plus' -a '+incdir' -d '添加 include 搜索路径'
complete -c slang -f -n '__slang_can_suggest_plus' -a '+define' -d '定义宏 NAME=VALUE'
complete -c slang -f -n '__slang_can_suggest_plus' -a '+libext' -d '添加库文件扩展名'
complete -c slang -f -n '__slang_seen_plus_arg +incdir' -a '(__fish_complete_directories)' -d 'Include 目录'
complete -c slang -f -n '__slang_seen_plus_arg +define' -d '宏定义 NAME=VALUE'
complete -c slang -f -n '__slang_seen_plus_arg +libext' -d '库文件扩展名'

# 预处理和解析限制
complete -c slang -f -n '__slang_no_double_dash' -l max-include-depth -x -d '限制 include 文件嵌套深度'
complete -c slang -f -n '__slang_no_double_dash' -l libraries-inherit-macros -d '库文件继承源文件宏定义'
complete -c slang -f -n '__slang_no_double_dash' -l enable-legacy-protect -d '启用旧版 protect 指令'
complete -c slang -f -n '__slang_no_double_dash' -l translate-off-format -x -d '设置注释指令格式'
complete -c slang -f -n '__slang_no_double_dash' -l map-keyword-version -x -d '按文件模式指定关键字版本'
complete -c slang -f -n '__slang_no_double_dash' -l show-parsed-files -d '打印解析的文件名和类型'
complete -c slang -f -n '__slang_no_double_dash' -l allow-missing-protected-scope-end -d '允许受保护作用域缺少结束关键字'
complete -c slang -f -n '__slang_no_double_dash' -l cmd-ignore -x -d '忽略 vendor 命令及其参数'
complete -c slang -f -n '__slang_no_double_dash' -l cmd-rename -x -d '将 vendor 命令重命名'
complete -c slang -f -n '__slang_no_double_dash' -l ignore-directive -x -d '忽略预处理指令'
complete -c slang -f -n '__slang_no_double_dash' -l max-parse-depth -x -d '限制解析嵌套深度'
complete -c slang -f -n '__slang_no_double_dash' -l max-lexer-errors -x -d '限制词法错误数量'
complete -c slang -f -n '__slang_no_double_dash' -s j -l threads -x -d '并行解析线程数'
complete -c slang -n '__slang_no_double_dash' -s C -r -F -d '指定独立编译单元清单文件'

# 求值与资源限制
complete -c slang -f -n '__slang_no_double_dash' -l max-hierarchy-depth -x -d '限制设计层次深度'
complete -c slang -f -n '__slang_no_double_dash' -l max-generate-steps -x -d '限制 generate 块求值步数'
complete -c slang -f -n '__slang_no_double_dash' -l max-constexpr-depth -x -d '限制常量表达式调用深度'
complete -c slang -f -n '__slang_no_double_dash' -l max-constexpr-steps -x -d '限制常量表达式求值步数'
complete -c slang -f -n '__slang_no_double_dash' -l max-constant-size -x -d '限制常量位宽'
complete -c slang -f -n '__slang_no_double_dash' -l constexpr-backtrace-limit -x -d '限制常量表达式回溯帧数'
complete -c slang -f -n '__slang_no_double_dash' -l max-instance-array -x -d '限制实例数组大小'
complete -c slang -f -n '__slang_no_double_dash' -l max-enum-values -x -d '限制枚举成员数量'
complete -c slang -f -n '__slang_no_double_dash' -l max-udp-coverage-notes -x -d '限制 UDP coverage note 数量'
complete -c slang -f -n '__slang_no_double_dash' -l compat -x -a 'default vcs all' -d '兼容模式'
complete -c slang -f -n '__slang_no_double_dash' -s T -l timing -x -a 'min typ max' -d '选择 min:typ:max 取值'
complete -c slang -f -n '__slang_no_double_dash' -l timescale -x -d '设置默认时间尺度'

# 放宽检查选项
complete -c slang -f -n '__slang_no_double_dash' -l allow-use-before-declare -d '允许名字先于声明使用'
complete -c slang -f -n '__slang_no_double_dash' -l ignore-unknown-modules -d '忽略未知模块实例'
complete -c slang -f -n '__slang_no_double_dash' -l relax-enum-conversions -d '允许整型隐式转换为枚举'
complete -c slang -f -n '__slang_no_double_dash' -l relax-string-conversions -d '允许字符串隐式转换为整型'
complete -c slang -f -n '__slang_no_double_dash' -l allow-hierarchical-const -d '允许常量表达式中的层次引用'
complete -c slang -f -n '__slang_no_double_dash' -l allow-toplevel-iface-ports -d '允许顶层模块使用接口端口'
complete -c slang -f -n '__slang_no_double_dash' -l allow-recursive-implicit-call -d '允许隐式递归函数调用'
complete -c slang -f -n '__slang_no_double_dash' -l allow-bare-value-param-assigment -d '允许省略参数赋值的括号'
complete -c slang -f -n '__slang_no_double_dash' -l allow-self-determined-stream-concat -d '允许自确定的流式拼接'
complete -c slang -f -n '__slang_no_double_dash' -l allow-merging-ansi-ports -d '允许合并 ANSI 端口声明'
complete -c slang -f -n '__slang_no_double_dash' -l lint-only -d '只执行 lint'
complete -c slang -f -n '__slang_no_double_dash' -l disable-instance-caching -d '禁用实例缓存'
complete -c slang -f -n '__slang_no_double_dash' -l disallow-refs-to-unknown-instances -d '禁止引用被忽略的模块实例'
complete -c slang -f -n '__slang_no_double_dash' -l allow-genblk-reference -d '允许引用未命名 generate 块'
complete -c slang -f -n '__slang_no_double_dash' -l allow-virtual-iface-with-override -d '允许虚接口作为 bind/defparam 目标'
complete -c slang -f -n '__slang_no_double_dash' -l allow-array-concat-assign-pattern -d '允许数组拼接赋值模式'
complete -c slang -f -n '__slang_no_double_dash' -l allow-lib-module-redef -d '允许库文件重复定义模块'

# 顶层和库
complete -c slang -f -n '__slang_no_double_dash' -l top -x -d '指定顶层模块'
complete -c slang -f -n '__slang_no_double_dash' -s G -x -d '顶层模块参数覆盖'
complete -c slang -f -n '__slang_no_double_dash' -s L -x -d '模块查找库顺序'
complete -c slang -f -n '__slang_no_double_dash' -l defaultLibName -x -d '设置默认库名'
complete -c slang -f -n '__slang_no_double_dash' -l define-system-task -x -d '定义自定义系统任务或函数'
complete -c slang -f -n '__slang_no_double_dash' -s W -x -d '控制指定 warning'

# 诊断输出
complete -c slang -f -n '__slang_no_double_dash' -l color-diagnostics -d '始终启用诊断颜色'
complete -c slang -f -n '__slang_no_double_dash' -l diag-column -d '显示诊断列号'
complete -c slang -f -n '__slang_no_double_dash' -l diag-column-unit -x -a 'byte display' -d '诊断列号单位'
complete -c slang -f -n '__slang_no_double_dash' -l diag-location -d '显示诊断位置'
complete -c slang -f -n '__slang_no_double_dash' -l diag-source -d '显示诊断源码行'
complete -c slang -f -n '__slang_no_double_dash' -l diag-option -d '显示诊断选项名'
complete -c slang -f -n '__slang_no_double_dash' -l diag-include-stack -d '显示 include 栈'
complete -c slang -f -n '__slang_no_double_dash' -l diag-macro-expansion -d '显示宏展开回溯'
complete -c slang -f -n '__slang_no_double_dash' -l diag-abs-paths -d '显示绝对路径'
complete -c slang -f -n '__slang_no_double_dash' -l diag-hierarchy -x -a 'auto always never' -d '显示层次位置'
complete -c slang -n '__slang_no_double_dash' -l diag-json -r -F -d '将诊断写入 JSON 文件'
complete -c slang -f -n '__slang_no_double_dash' -l error-limit -x -d '限制打印错误数量'
complete -c slang -n '__slang_no_double_dash' -l suppress-warnings -r -F -d '抑制指定路径 warning'
complete -c slang -n '__slang_no_double_dash' -l suppress-macro-warnings -r -F -d '抑制宏展开 warning'

# 编译单元与库文件
complete -c slang -f -n '__slang_no_double_dash' -l single-unit -d '将所有输入视为单一编译单元'
complete -c slang -n '__slang_no_double_dash' -s v -l libfile -r -F -d '添加库文件'
complete -c slang -n '__slang_no_double_dash' -l libmap -r -F -d '添加库映射文件'
complete -c slang -f -n '__slang_no_double_dash' -s y -l libdir -r -a '(__fish_complete_directories)' -d '添加库搜索目录'
complete -c slang -n '__slang_no_double_dash' -l dir-prefix -r -F -d '添加源文件查找前缀'
complete -c slang -f -n '__slang_no_double_dash' -s Y -l libext -x -d '添加库文件扩展名'
complete -c slang -f -n '__slang_no_double_dash' -l exclude-ext -x -d '排除指定扩展名文件'
complete -c slang -n '__slang_no_double_dash' -s f -r -F -d '添加命令文件, 相对当前目录'
complete -c slang -n '__slang_no_double_dash' -s F -r -F -d '添加命令文件, 相对文件自身'

# 依赖输出
complete -c slang -f -n '__slang_no_double_dash' -l depfile-target -d '为 depfile 设置 make target'
complete -c slang -n '__slang_no_double_dash' -l Mall -l all-deps -r -F -d '生成全部依赖清单'
complete -c slang -n '__slang_no_double_dash' -l Minclude -l include-deps -r -F -d '生成 include 依赖清单'
complete -c slang -n '__slang_no_double_dash' -l Mmodule -l module-deps -r -F -d '生成模块依赖清单'
complete -c slang -f -n '__slang_no_double_dash' -l depfile-trim -d '裁剪未引用文件'
complete -c slang -f -n '__slang_no_double_dash' -l depfile-sort -d '拓扑排序依赖输出'

# 数据流与静态分析
complete -c slang -f -n '__slang_no_double_dash' -l dfa-unique-priority -d '数据流分析尊重 unique 和 priority'
complete -c slang -f -n '__slang_no_double_dash' -l dfa-four-state -d '数据流分析要求覆盖 X 和 Z'
complete -c slang -f -n '__slang_no_double_dash' -l allow-multi-driven-locals -d '允许多个 always 块驱动局部变量'
complete -c slang -f -n '__slang_no_double_dash' -l allow-dup-initial-drivers -d '允许 initial 块重复驱动信号'
complete -c slang -f -n '__slang_no_double_dash' -l max-case-analysis-steps -x -d '限制 case 分析步数'
complete -c slang -f -n '__slang_no_double_dash' -l max-loop-analysis-steps -x -d '限制循环分析步数'

# 预处理与中间表示输出
complete -c slang -f -n '__slang_no_double_dash' -s E -l preprocess -d '仅预处理并输出到 stdout'
complete -c slang -f -n '__slang_no_double_dash' -l macros-only -d '仅打印宏列表'
complete -c slang -f -n '__slang_no_double_dash' -l group-macros-by-file -d '按文件分组宏输出'
complete -c slang -f -n '__slang_no_double_dash' -l parse-only -d '解析后停止'
complete -c slang -f -n '__slang_no_double_dash' -l disable-analysis -d '禁用解析后分析'
complete -c slang -f -n '__slang_no_double_dash' -l comments -d '在预处理输出中包含注释'
complete -c slang -f -n '__slang_no_double_dash' -l directives -d '在预处理输出中包含指令'
complete -c slang -f -n '__slang_no_double_dash' -l obfuscate-ids -d '随机化标识符'
complete -c slang -f -n '__slang_no_double_dash' -l preprocess-source -d '显示预处理源码行信息'
complete -c slang -n '__slang_no_double_dash' -l ast-json -r -F -d '将 AST 写入 JSON 文件'
complete -c slang -n '__slang_no_double_dash' -l cst-json -r -F -d '将 CST 写入 JSON 文件'
complete -c slang -f -n '__slang_no_double_dash' -l cst-json-mode -x -a 'full no-whitespace simple-trivia no-trivia simple-tokens' -d 'CST JSON 输出模式'
complete -c slang -f -n '__slang_no_double_dash' -l ast-json-scope -x -d '仅导出指定作用域'
complete -c slang -f -n '__slang_no_double_dash' -l ast-json-source-info -d '包含源码位置信息'
complete -c slang -f -n '__slang_no_double_dash' -l ast-json-detailed-types -d '展开所有类型信息'
complete -c slang -n '__slang_no_double_dash' -l time-trace -r -F -d '输出性能分析 JSON'
complete -c slang -n '__slang_no_double_dash' -l time-stats -r -F -d '输出阶段耗时 JSON'
complete -c slang -n '__slang_no_double_dash' -l memory-stats -r -F -d '输出内存分析 JSON'
