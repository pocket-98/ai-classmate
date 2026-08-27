#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash pandoc

gdrive="/mnt/gdrive/Tech Social Impact Lab - Nasal Cannulas"
old_file="file_timestamps.csv"
sleep_loop_time=10

in_exts=(  ".docx" )
out_exts=( ".md" )
compile_scripts=( "_compile_docx" )


compile_file() {
    f="$1"
    inp=$(strip_gdrive "$f")
    outp=$(get_output_file "$f" | head -n 1)
    compile_script=$(get_output_file "$f" | tail -n 1)
    echo "  $inp -> ($compile_script) -> $outp"
    $compile_script "$f" "$outp"
}

_compile_docx() {
    pandoc "$1" -o "$2"
}

_copy() {
    cp "$1" "$2"
}

get_output_file() {
    f="$1"
    inp=$(strip_gdrive "$f")
    inext=".${inp##*.}"
    idx=-1
    compscr=""
    for j in ${!in_exts[@]}; do
        if [ "${inext}" = "${in_exts[$j]}" ]; then
            idx=$j
            break
        fi
    done
    if [ "${idx}" -lt 0 ]; then
        ext="${inext}"
        compscr="_copy"
    else
        ext="${out_exts[$idx]}"
        compscr="${compile_scripts[$idx]}"
    fi
    outp="${inp%.*}$ext"
    echo "$outp"
    echo "$compscr"
}

strip_gdrive() {
    echo "$1" | sed -E "s|^$gdrive/||"
}

load_old_list() {
    OLDIFS="$IFS"
    IFS=$'\n'
    old_list=( $(cat "${old_file}" | awk -F"," '{print $1}') )
    old_times=( $(cat "${old_file}" | awk -F"," '{print $2}') )
    IFS="$OLDIFS"
}

get_gdrive_times() {
    if [ -d "$gdrive" ]; then
        OLDIFS="$IFS"
        IFS=$'\n'
        flist=( $(find "$gdrive" -type f) )
        ftimes=( )
        for j in ${!flist[@]}; do
            t=$( stat -c "%X" "${flist[$j]}")
            ftimes+=( "$t" )
        done
        IFS="$OLDIFS"
    else
        flist=( ${old_list[@]} )
        ftimes=( ${old_times[@]} )
    fi
}

find_old_idx() {
    f="$1"
    found=0
    for k in ${!old_list[@]}; do
        if [ "${old_list[$k]}" = "$f" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 1 ]; then
        echo "$k"
    else
        echo -1
    fi
}

compare_file_times() {
    compile_list=( )
    found_list=( )
    remove_list=( )
    for j in ${!flist[@]}; do
        f="${flist[$j]}"
        t="${ftimes[$j]}"
        k=$(find_old_idx "$f")
        if [ "$k" -ge 0 ]; then
            of="${old_list[$k]}"
            ot="${old_times[$k]}"
            found_list+=( "$k" )
            if [ "$t" -gt "$ot" ]; then
                compile_list+=( "$j" )
            fi
            outp=$(get_output_file "$f" | head -n 1)
            if [ ! -f "${outp}" ]; then
                compile_list+=( "$j" )
            fi
        else
            compile_list+=( "$j" )
        fi
    done
    for j in ${!old_list[@]}; do
        found=0
        for k in ${found_list[@]}; do
            if [ "$j" -eq "$k" ]; then
                found=1
                break
            fi
        done
        if [ "$found" -eq 0 ]; then
            remove_list+=( "$j" )
        fi
    done
}

store_old_list() {
    echo -n "" > "${old_file}"
    for j in ${!flist[@]}; do
        found=0
        for k in ${compile_list[@]}; do
            if [ "$j" -eq "$k" ]; then
                found=1
                break
            fi
        done
        if [ "$found" -eq 0 ]; then
            echo "${flist[$j]},${ftimes[$j]}" >> "${old_file}"
        fi
    done
    for k in ${remove_list[@]}; do
        echo "${old_list[$k]},${old_times[$k]}" >> "${old_file}"
    done
}

compile_files() {
    for j_idx in ${!compile_list[@]}; do
        j=${compile_list[$j_idx]}
        compile_file "${flist[$j]}"
        if [ $? -eq 0 ]; then
            unset compile_list[$j_idx]
        else
            echo "  error: failed to compile ${flist[$j]}"
        fi
    done
}

remove_files() {
    for k_idx in ${!remove_list[@]}; do
        k=${remove_list[$k_idx]}
        f="${old_list[$k]}"
        outp=$(get_output_file "$f" | head -n 1)
        echo "  rm $outp"
        rm "$outp"
        if [ $? -eq 0 ]; then
            unset remove_list[$k_idx]
        else
            echo "  error: failed to remove ${old_list[$k]}"
        fi
    done
}

loop() {
    old_list=( )
    old_times=( )
    flist=( )
    ftimes=( )
    compile_list=( )
    remove_list=( )

    load_old_list
    get_gdrive_times
    compare_file_times

    if [ "${#compile_list[@]}" -gt 0 ]; then
        echo ""
        echo "compiling google drive files to local storage"
        compile_files
    fi

    if [ "${#remove_list[@]}" -gt 0 ]; then
        echo ""
        echo "removing old missing compiled gdrive files"
        remove_files
    fi

    store_old_list
}

main() {
    echo "watching for changes in gdrive folder to make local compilations:"
    while :; do
        echo -n "."
        loop
        sleep ${sleep_loop_time}
    done
}
main
