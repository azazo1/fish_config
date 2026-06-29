function ramdisk -d "Create a macOS RAM disk (e.g., 200M, 1.5G, 2GB)"
    set -l disk_name "RAMDisk"

    # 1. 唯一性校验：检查是否已经存在同名内存盘，防止重复创建
    if test -d "/Volumes/$disk_name"
        echo "❌ 错误: 内存盘 '$disk_name' 已经存在！"
        echo "请先推出已有的内存盘再试: diskutil eject /Volumes/$disk_name"
        return 1
    end

    # 2. 默认输入为 200 (即 200MB)
    set -l input "200"
    if test (count $argv) -gt 0
        set input $argv[1]
    end

    # 3. 正则解析数值和单位 (支持整数/浮点数，单位支持 g/m/k，B/b 可选)
    set -l match (string match -r '^([0-9.]+)\s*([gGmMkK]?)[bB]?$' $input)

    # 如果无法解析，则报错提示
    if test (count $match) -lt 3
        echo "❌ 错误: 无法解析的容量格式 '$input'。"
        echo "支持的格式示例: 200, 500M, 1.5G, 2GB, 2gb"
        return 1
    end

    set -l value $match[2]
    set -l unit (string lower $match[3])

    # 4. 根据单位计算对应的扇区乘数 (1 扇区 = 512 字节)
    set -l multiplier 2048 # 默认单位 MB (1024 * 1024 / 512)
    set -l display_unit "MB"

    if test "$unit" = "g"
        set multiplier 2097152 # GB (1024 * 1024 * 1024 / 512)
        set display_unit "GB"
    else if test "$unit" = "k"
        set multiplier 2 # KB (1024 / 512)
        set display_unit "KB"
    end

    # 5. 计算最终扇区数 (math -s0 强制将浮点结果转为无小数的整数)
    set -l sectors (math -s0 "$value * $multiplier")

    # 安全防范：防止创建大小为 0 的盘
    if test "$sectors" -le 0
        echo "❌ 错误: 容量必须大于 0。"
        return 1
    end

    echo "正在创建大小为 $value $display_unit 的内存盘 ($disk_name)..."

    # 6. 执行挂载和格式化
    # 使用 string trim 去掉末尾的空格/制表符
    set -l dev_path (hdiutil attach -nomount ram://$sectors | string trim)
    
    if test $status -eq 0
        # 等待 0.5 秒让系统注册设备节点，防止时序冲突
        sleep 0.5
        
        diskutil erasevolume APFS $disk_name $dev_path
        echo "🎉 内存盘创建成功！挂载路径: /Volumes/$disk_name"
    else
        echo "❌ 创建失败，请检查系统内存是否充足。"
    end
end
