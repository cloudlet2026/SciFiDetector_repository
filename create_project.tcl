# ============================================================================
#  Vivado 工程导入脚本
# 适用版本：Vivado 2018.x
# 用法：在 Vivado Tcl Console 中 cd 到脚本所在目录，执行 source ./create_project.tcl
# 说明：自动扫描当前目录下的 src、xdc、bd、ip、sim 文件夹，
#       将所有文件复制到新建工程内部，然后使用 add_files 添加，实现完全独立。
# ============================================================================

# 设置工程名和器件
set project_name "SciFiDetector"
set part "xc7z020clg400-2"

# 设置当前目录为 origin_dir
set origin_dir [file normalize "."]

# 创建新工程
create_project $project_name ../$project_name -part $part

# 获取新工程的绝对路径
set proj_dir [get_property directory [current_project]]

# ------------------------------------------------------------
# 处理 src 文件
# ------------------------------------------------------------
if {[string equal [get_filesets -quiet src] ""]} {
    create_fileset -srcset src
}
set srcset [get_filesets src]

# 复制所有 IP 核到工程内
set src_ip_dir "${origin_dir}/ip"
if {[file exists $src_ip_dir]} {
    set dest_ip_parent "${proj_dir}/${project_name}.srcs/sources_1/ip"
    file mkdir $dest_ip_parent
    # 复制源目录内容到目标目录
    set ip_items [glob -nocomplain -directory $src_ip_dir *]
    foreach item $ip_items {
        file copy -force $item $dest_ip_parent
    }
    # 设置 IP 仓库路径为 sources_1/ip
    set_property ip_repo_paths "${dest_ip_parent}" [current_fileset]
    update_ip_catalog -rebuild
    # 添加所有 .xci 文件到 sources_1
    set xci_files [glob -nocomplain -type f -directory "${dest_ip_parent}" "*.xci"]
    foreach f $xci_files {
        add_files -fileset sources_1 $f
    }
    puts "IP files added to sources_1"
}

# 复制所有源码文件到工程内
set src_src_dir "${origin_dir}/src"
if {[file exists $src_src_dir]} {
    set dest_src_parent "${proj_dir}/${project_name}.srcs/sources_1/src"
    file mkdir $dest_src_parent
    # 复制源目录内容到目标目录
    set src_items [glob -nocomplain -directory $src_src_dir *]
    foreach item $src_items {
        file copy -force $item $dest_src_parent
    }
    # 添加所有 .v 文件
    set src_files [glob -nocomplain -type f -directory "${dest_src_parent}" "*.v" "*.vh" "*.vhd" "*.vhdl"]
    foreach f $src_files {
        add_files -fileset sources_1 $f
    }
    puts "Source files added to sources_1"
}

# 复制 BD 目录并处理
set bd_name ""
set src_bd_dir "${origin_dir}/bd"
if {[file exists $src_bd_dir]} {
    set dest_bd_parent "${proj_dir}/${project_name}.srcs/sources_1/bd"
    file mkdir $dest_bd_parent
    # 复制源目录内容到目标目录
    set bd_items [glob -nocomplain -directory $src_bd_dir *]
    foreach item $bd_items {
        file copy -force $item $dest_bd_parent
    }

    # 查找 .bd 文件
    set bd_files [glob -nocomplain -type f -directory "${dest_bd_parent}" "*.bd"]
    if {[llength $bd_files] == 0} {
        set bd_files [glob -nocomplain -type f -directory "${dest_bd_parent}" "*/**.bd"]
    }
    if {[llength $bd_files] > 0} {
        set bd_file [lindex $bd_files 0]
        set bd_name [file rootname [file tail $bd_file]]
        puts "BD name: $bd_name"
    } else {
        puts "Warning: No .bd file found in ${dest_bd_parent}"
    }

    # 如果存在对应的重建 Tcl 脚本
    set bd_tcl_script "${dest_bd_parent}/${bd_name}.tcl"
    if {[file exists $bd_tcl_script]} {
        source $bd_tcl_script
    } else {
        # 如果没有 Tcl 脚本，则直接将 .bd 文件添加到工程
        if {[llength $bd_files] > 0} {
            foreach f $bd_files {
                add_files -fileset sources_1 $f
            }
        }
    }

    # 生成 wrapper
    set wrapper_file "${dest_bd_parent}/${bd_name}/hdl/${bd_name}_wrapper.v"
    if {[file exists $wrapper_file]} {
        # wrapper 已存在，直接添加
        add_files -fileset sources_1 $wrapper_file
    } else {
        # 尝试打开 BD 并生成 wrapper
        set bd_design_path "${dest_bd_parent}/${bd_name}/${bd_name}.bd"
        if {[file exists $bd_design_path]} {
            open_bd_design $bd_design_path
            make_wrapper -files [get_files ${bd_name}.bd] -top -import
            close_bd_design [current_bd_design]
            # 添加生成的 wrapper
            if {[file exists $wrapper_file]} {
                add_files -fileset sources_1 $wrapper_file
            }
        }
    }
}
# ------------------------------------------------------------
# 处理约束文件
# ------------------------------------------------------------
if {[string equal [get_filesets -quiet xdc] ""]} {
    create_fileset -constrset xdc
}
set constrset [get_filesets xdc]

set src_constr_dir "${origin_dir}/xdc"
if {[file exists $src_constr_dir]} {
    set dest_constr_parent "${proj_dir}/${project_name}.srcs/constrs_1"
    file mkdir $dest_constr_parent
    # 复制源目录内容到目标目录
    set constr_items [glob -nocomplain -directory $src_constr_dir *]
    foreach item $constr_items {
        file copy -force $item $dest_constr_parent
    }
    set xdc_files [glob -nocomplain -type f -directory "${dest_constr_parent}" "*.xdc"]
    foreach f $xdc_files {
        add_files -fileset constrs_1 $f
    }
    puts "Constraint files added to constrs_1"
}

# ------------------------------------------------------------
# 处理仿真文件
# ------------------------------------------------------------
if {[string equal [get_filesets -quiet sim] ""]} {
    create_fileset -simset sim
}
set simset [get_filesets sim]

set src_sim_dir "${origin_dir}/sim"
if {[file exists $src_sim_dir]} {
    set dest_sim_parent "${proj_dir}/${project_name}.srcs/sim_1"
    file mkdir $dest_sim_parent
    # 复制源目录内容到目标目录
    set sim_items [glob -nocomplain -directory $src_sim_dir *]
    foreach item $sim_items {
        file copy -force $item $dest_sim_parent
    }
    set sim_files [glob -nocomplain -type f -directory "${dest_sim_parent}" "*.v" "*.vh" "*.vhd" "*.vhdl"]
    foreach f $sim_files {
        add_files -fileset sim_1 $f
    }
    puts "Simulation files added to sim_1"
}
# ------------------------------------------------------------
# 设置顶层模块
# ------------------------------------------------------------
set_property top ${bd_name}_wrapper [current_fileset]

# ------------------------------------------------------------
# 复制 SDK 工程
# ------------------------------------------------------------
set src_sdk_dir "${origin_dir}/sdk"
if {[file exists $src_sdk_dir]} {
    set dest_sdk_dir "${proj_dir}/${project_name}.sdk"
    file mkdir $dest_sdk_dir
    set sdk_items [glob -nocomplain -directory $src_sdk_dir *]
    foreach item $sdk_items {
        file copy -force $item $dest_sdk_dir
    }
    puts "SDK files copied to ${dest_sdk_dir}"
}

# ------------------------------------------------------------
# 复制 UpperComputer 上位机工程
# ------------------------------------------------------------
set src_uppercomputer_dir "${origin_dir}/UpperComputer"
if {[file exists $src_uppercomputer_dir]} {
    set dest_uppercomputer_dir "${proj_dir}/UpperComputer"
    file mkdir $dest_uppercomputer_dir
    set uppercomputer_items [glob -nocomplain -directory $src_uppercomputer_dir *]
    foreach item $uppercomputer_items {
        file copy -force $item $dest_uppercomputer_dir
    }
    puts "UpperComputer files copied to ${dest_uppercomputer_dir}"
}

# ------------------------------------------------------------
# 创建默认的运行
# ------------------------------------------------------------
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $part -flow {Vivado Synthesis 2017} -strategy "Vivado Synthesis Defaults" -report_strategy {No Reports} -constrset constrs_1
}
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $part -flow {Vivado Implementation 2017} -strategy "Vivado Implementation Defaults" -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
}

puts "Project setup completed."